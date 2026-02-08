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
$LIST
CLK EQU 33333333
TIMER_10ms EQU (65536-(CLK/(12*100)))
PS2_DAT BIT P3.3
RELEASE_FLAG BIT 20h
cseg
	ljmp MainProgram
	
	;Interrupt on keypress at address 0003h
	org 0003h
	ljmp PS2_Interrupt
Initialize_PS2:
	; Configure serial protocol for PS/2
	setb PS2_DAT
	setb IT0         ;Setting IT0 makes external interrupts edge-triggered rather than state-triggered
	setb EX0         ;Enable external interrupts
	setb EA          ;Enable interrupts
	mov R0, #0		 ;Stores what bit we're reading
	mov R1, #0		 ;Stores values of data
	clr RELEASE_FLAG
	ret
PS2_Interrupt:
	push ACC
	push PSW
	
	mov A, R0
	;If we're at the start of a frame, validate start bit before incrementing
	cjne A, #0, NotAtStart
	mov C, PS2_DAT
	jc PS2_Done    ;If start bit is 1, wait for valid start (should be 0)
	
NotAtStart:
	inc R0
	mov A, R0
	;Ignore start bit
	cjne A, #1, CheckData
	sjmp PS2_Done
CheckData:
	;Read data bits
	clr C
	subb A, #10      ; Carry set if A < 10 (bits 2-9)
	jnc CheckIfDone
	mov C, PS2_DAT   ; Read data line
	mov A, R1
	rrc A            ; Shift into R1
	mov R1, A
	mov A, R0
	cjne A, #9, PS2_Done
	mov A, R1
	cjne A, #0F0h, NotRelease
	setb RELEASE_FLAG ; stop code
	sjmp PS2_Done
NotRelease:
	;We haven't let g
	jb RELEASE_FLAG, ClearRel
	mov LEDRA, A      
	sjmp PS2_Done
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
	;Prevents from going out of sync
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
    mov sp, #0x7f
    lcall Initialize_PS2
forever:
	sjmp forever
end