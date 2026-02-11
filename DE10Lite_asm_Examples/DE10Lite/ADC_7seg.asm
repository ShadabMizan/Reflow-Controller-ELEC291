;This program receives keyboard input from the PS/2 port on the DE1-SOC
;----------------------------------------;
;                  Workflow:             ;
;         1. Initialize PS/2 pins        ;
;         2. Wait for falling edge       ;
;                of PS/2 clock           ;
;         3. Read PS/2 data stream       ;
;----------------------------------------;
;|Start Bit|SCANCODE|Parity Bit|Stop Bit|;
;----------------------------------------;
;           ^^^^^^^^                     ;
;           8-bit val                    ;
;         4. If scancode == 0xF0,        ;
;            interpret as key release    ;
;         5. Else, interpret as          ;
;            key press                   ;
;----------------------------------------;
$NOLIST
$MODDE1SOC
$INCLUDE(uart.inc)
$LIST
dseg
uartbuf ds 30h
BAUD           equ 115200
TIMER_2_RELOAD equ (0x10000-(CLK/(32*BAUD)))
CLK EQU 33333333
TIMER_10ms EQU (65536-(CLK/(12*100)))
PS2_DAT EQU P3.3
RELEASE_FLAG BIT 20h.0
SET_FLAG BIT 20h.1
MODE BIT 20h.2 ;0=Soak, 1=Reflow
PARAM BIT 20h.3;0=Temp, 1=Time

cseg
	ljmp MainProgram
	
	;Interrupt on keypress at address 0003h
	org 0003h
	ljmp PS2_Interrupt
	
	;Scancode to ASCII lookup table
	org 0100h
ASCII_TABLE:
	DB 0, 0, 0, 0, 0, 0, 0, 0        ; 00-07
	DB 0, 0, 0, 0, 0, 0, '`', 0      ; 08-0F
	DB 0, 0, 0, 0, 0, 'q', '1', 0    ; 10-17
	DB 0, 0, 'z', 's', 'a', 'w', '2', 0  ; 18-1F
	DB 0, 'c', 'x', 'd', 'e', '4', '3', 0  ; 20-27
	DB 0, ' ', 'v', 'f', 't', 'r', '5', 0  ; 28-2F
	DB 0, 'n', 'b', 'h', 'g', 'y', '6', 0  ; 30-37
	DB 0, 0, 'm', 'j', 'u', '7', '8', 0    ; 38-3F
	DB 0, ',', 'k', 'i', 'o', '0', '9', 0  ; 40-47
	DB 0, '.', '/', 'l', ';', 'p', '-', 0  ; 48-4F
	DB 0, 0, 27h, 0, '[', '=', 0, 0        ; 50-57 (27h = apostrophe)
	DB 0, 0, 0Ah, ']', 0, 5Ch, 0, 0          ; 58-5F (0Ah = decimal 10 = Enter/newline key)
	DB 0, 0, 0, 0, 0, 0, 0, 0              ; 60-67
	DB 0, 0, 0, 0, 0, 0, 0, 0              ; 68-6F
	DB 0, 0, 0, 0, 0, 0, 0, 0              ; 70-77
	DB 0, 0, 0, 0, 0, 0, 0, 0              ; 78-7F

; Look-up table for 7-seg displays
SEG7_LUT:
    DB 0xC0, 0xF9, 0xA4, 0xB0, 0x99        ; 0 TO 4
    DB 0x92, 0x82, 0xF8, 0x80, 0x90        ; 4 TO 9
    DB 0x88, 0x83, 0xC6, 0xA1, 0x86, 0x8E  ; A to F

Initialize_PS2:
	;Configure serial protocol for PS/2
	setb PS2_DAT
	setb IT0         ;Setting IT0 makes external interrupts edge-triggered rather than state-triggered
	setb EX0         ;Enable external interrupts
	setb EA          ;Enable interrupts
	mov R0, #0		 ;Stores what bit we're reading
	mov R1, #0		 ;Stores values of data
	clr RELEASE_FLAG
	ret
	
Scancode_To_ASCII:
	mov DPTR, #ASCII_TABLE
	movc A, @A+DPTR
	ret

Update_HEX_Display:
	; Display "C" (0xC6) for temperature or "S" (0x92) for time
	jb PARAM, Show_S
	; Show "C" for temperature
	mov HEX0, #0xC6
	ret
Show_S:
	; Show "S" for time
	mov HEX0, #0x92
	ret
	
PS2_Interrupt:
	push ACC
	push PSW
	
	mov A, R0
	;If we're at the start of a frame, validate start bit before incrementing
	cjne A, #0, NotAtStart
	mov C, PS2_DAT
	jc jump    ;If start bit is 1, wait for valid start (should be 0)
	
NotAtStart:
	inc R0
	mov A, R0
	;Ignore start bit
	cjne A, #1, CheckData
	sjmp PS2_Done
	
jump:
	ljmp PS2_Done
	
CheckData:
	;Read data bits
	clr C
	subb A, #10      ;Carry if A < 10 (bits 2-9)
	jnc CheckIfDone
	mov C, PS2_DAT   ;Read data line
	mov A, R1
	rrc A            ;Shift into R1
	mov R1, A
	mov A, R0
	cjne A, #9, PS2_Done
	mov A, R1
	cjne A, #0F0h, NotRelease
	setb RELEASE_FLAG ;stop code
	sjmp PS2_Done
NotRelease:
	;We haven't let go
	lcall Scancode_To_ASCII
	jz PS2_Done
	mov LEDRA, A      
	cjne A, #'q', NotQ
	clr SET_FLAG
	clr MODE
	clr PARAM
	mov LEDRB, #0x00
	lcall Update_HEX_Display
	sjmp PS2_Done
	
NotQ:
	jb SET_FLAG, Setting
	cjne A, #'c', PS2_Done
	setb SET_FLAG
	sjmp PS2_Done
	
Setting:
	cjne A, #'s', CheckR
	clr MODE
	mov LEDRB, #0b10  ; Show 10 for Soak
	sjmp PS2_Done
	
CheckR:
	cjne A, #'r', CheckT
	setb MODE
	mov LEDRB, #0b01  ; Show 01 for Reflow
	sjmp PS2_Done
	
CheckT:
	cjne A, #'t', CheckX
	setb PARAM
	lcall Update_HEX_Display
	sjmp PS2_Done
	
CheckX:
	cjne A, #'x', PS2_Done
	clr PARAM
	lcall Update_HEX_Display
	sjmp PS2_Done

CheckEnter:
	cjne A, #0Ah, PS2_Done
ClearRel:
	clr RELEASE_FLAG 
	sjmp PS2_Done
CheckIfDone:
	;Wait for Stop Bit
	cjne A, #11, CheckOverflow
	sjmp Reset
	
Reset:
	;Resets so we're ready for next keypress
	mov R0, #0
	mov R1, #0
	sjmp PS2_Done
CheckOverflow:
	;Prevents from going out of sync (this was a problem because we're not explicitly checking the parity bit)
	clr C
	subb A, #12
	jc PS2_Done
	sjmp Reset
PS2_Done:
	pop PSW
	pop ACC
	reti
MainProgram:
	mov LEDRA, #0X00
	mov LEDRB, #0x00
	mov HEX0, #0xC6  ; Initialize to "C" (temperature)
    mov sp, #0x7f
    lcall Initialize_PS2
    lcall InitSerialPort
    mov DPTR, #string
    lcall SendString
forever:
	sjmp forever
	
	
string:
db '\rHi!\n', 0
end