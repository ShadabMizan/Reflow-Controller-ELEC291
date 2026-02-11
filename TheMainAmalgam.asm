

$NOLIST
$MODDE1SOC
$LIST

$NOLIST
$MODEFM8LB1
$LIST

BAUD           equ 115200
TIMER_2_RELOAD equ (0x10000-(CLK/(32*BAUD)))
CLK EQU 33333333
TIMER_10ms EQU (65536-(CLK/(12*100)))

; ====================================================================
; MISSING SFR DEFINITIONS
; ====================================================================

ADC0CF      DATA 0xBC


; ====================================================================
; PIN DEFINITIONS
; ====================================================================

;from fsm
ABORT_BUTTON    EQU P1.6
START_BUTTON    EQU P1.7
SSR_CONTROL     EQU P2.0
STATUS_LED      EQU P2.1
BUZZER          EQU P2.2
LCD_RS          EQU P1.3
LCD_E           EQU P1.4
LCD_D4          EQU P0.0
LCD_D5          EQU P0.1
LCD_D6          EQU P0.2
LCD_D7          EQU P0.3

;from keyboard code
PS2_DAT 		EQU P3.3



; ====================================================================
; CONSTANTS
; ====================================================================

;this should be commented out I believe, but the fsm code still has yet to correct for this, and still uses these constants instead of the variables.
	;TEMP_SOAK       EQU 150
	;TIME_SOAK       EQU 60
	;TEMP_REFLOW     EQU 220
	;TIME_REFLOW     EQU 45
;except for this one I believe
	TEMP_COOL       EQU 60


TEMP_MAX        EQU 240
TEMP_DROP_THRESHOLD EQU 10

ERR_NONE        EQU 0
ERR_ABORT       EQU 1
ERR_TEMP_DROP   EQU 2
ERR_OVERTEMP    EQU 3
ERR_SENSOR      EQU 4
ERR_TIMEOUT     EQU 5
ERR_UNDERTEMP   EQU 6
ERR_DOOR_OPEN   EQU 7
ERR_POWER       EQU 8

TEMP_ADC_CH     EQU 0

; ====================================================================
; OTHER: FROM KEYBOARD CODE
; ====================================================================

RELEASE_FLAG BIT 20h.0
SET_FLAG BIT 20h.1
MODE BIT 20h.2 ;0=Soak, 1=Reflow
PARAM BIT 20h.3;0=Temp, 1=Time
INVALID BIT 20h.4 ;Encountered invalid input
AWAIT BIT 20h.5
INPUTTING BIT 20h.6
PROMPT_PENDING BIT 20h.7 ; Flag to show prompt on next Enter
GET_PARAM BIT 21h.0 ; Flag to show parameter value on Enter

; ====================================================================
; BIT VARIABLES
; ====================================================================

BSEG
mf:                 dbit 1
; ====================================================================
; BYTE VARIABLES
; ====================================================================

DSEG at 30h

x:                  ds 4
y:                  ds 4
bcd:                ds 5
FSM_state:          ds 1
temp:               ds 1
temp_state_start:   ds 1
temp_max_state:     ds 1
temp_previous:      ds 1
sec:                ds 1
minutes:            ds 1
state_timer:        ds 1
ms_counter:         ds 1
pwm:                ds 1
error_code:         ds 1
tempsoak:           ds 1
timesoak:           ds 1
tempreflow:         ds 1
timereflow:         ds 1

; Data storage for parameters
SoakTemp:    ds 1  ; Soak temperature parameter
SoakTime:    ds 1  ; Soak time parameter
ReflowTemp:  ds 1  ; Reflow temperature parameter
ReflowTime:  ds 1  ; Reflow time parameter
InputBuffer: ds 3  ; 3-byte buffer for building the number (max 3 digits for 255)

; ====================================================================
; INTERRUPT FLAGS
; ====================================================================

cseg
    org 0000h       
    ljmp MainProgram
    
    ;Interrupt on keypress at address 0003h
    org 0003h
    ljmp PS2_Interrupt
    
    org 000BH
    ljmp Timer0_ISR
    
	org 0013H
    reti
    
	org 001BH
    reti
    
	org 0023H
    reti

$INCLUDE(math32.inc)

; ====================================================================
; INITIALIZATION
; ====================================================================

Init_Variables:
    mov FSM_state, #0
    mov temp, #25
    mov temp_state_start, #25
    mov temp_max_state, #25
    mov temp_previous, #25
    mov sec, #0
    mov minutes, #0
    mov state_timer, #0
    mov ms_counter, #0
    mov pwm, #0
    mov error_code, #ERR_NONE
    mov tempsoak, #TEMP_SOAK
    mov timesoak, #TIME_SOAK
    mov tempreflow, #TEMP_REFLOW
    mov timereflow, #TIME_REFLOW
    ret

Timer0_Init:
    anl TMOD, #0xF0
    orl TMOD, #0x01
    mov TH0, #0xD5
    mov TL0, #0x90
    setb ET0
    setb TR0
    setb EA
    ret

Check_Abort:
    jb ABORT_BUTTON, No_Abort
    lcall Wait50ms
    jb ABORT_BUTTON, No_Abort
    jnb ABORT_BUTTON, $
    mov error_code, #ERR_ABORT
    ljmp Handle_Error
No_Abort:
    ret

Check_Sensor:
    mov a, temp
    jz Sensor_Error
    cjne a, #255, Sensor_OK
Sensor_Error:
    mov error_code, #ERR_SENSOR
    ljmp Handle_Error
Sensor_OK:
    ret
	
org 0030h
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

InitSerialPort:
	mov RCAP2H, #HIGH(TIMER_2_RELOAD);
	mov RCAP2L, #LOW(TIMER_2_RELOAD);
	mov T2CON, #0x34 ; // #00110100B
	mov SCON, #0x52 ; // Serial port in mode 1, ren, txrdy, rxempty
	ret

putchar:
    JNB TI, putchar
    CLR TI
    MOV SBUF, a
    RET
    
SendString:
    CLR A
    MOVC A, @A+DPTR
    JZ SSDone
    LCALL putchar
    INC DPTR
    SJMP SendString
SSDone:
    ret

Initialize_PS2:
	;Configure serial protocol for PS/2
	setb PS2_DAT
	setb IT0         ;Setting IT0 makes external interrupts edge-triggered rather than state-triggered
	setb EX0         ;Enable external interrupts
	setb EA          ;Enable interrupts
	mov R0, #0		 ;Stores what bit we're reading
	mov R1, #0		 ;Stores values of data
	clr RELEASE_FLAG
	clr SET_FLAG
	clr INPUTTING
	clr PROMPT_PENDING
	clr GET_PARAM
	; Initialize input buffer
	mov InputBuffer, #0
	mov InputBuffer+1, #0
	mov InputBuffer+2, #0
	ret
	
; ====================================================================
; INITIALIZATION: STRINGS
; ====================================================================

Startup_Msg:
    DB 'Reflow Oven V1.0', 0

Error_Prefix:
    DB 'ERROR E0', 0

Error_Messages:
    DB 'User Abort     ', 0
    DB 'Temp Drop >=10C', 0
    DB 'Over Temp >240C', 0
    DB 'Sensor Failure ', 0
    DB 'State Timeout  ', 0
    DB 'Heater Fault   ', 0
    DB 'Door Opened    ', 0
    DB 'Power Issue    ', 0

State_Names:
    DB 'Ready   ', 0
    DB 'Ramp->S ', 0
    DB 'Soak    ', 0
    DB 'Ramp->R ', 0
    DB 'Reflow  ', 0
    DB 'Cooling ', 0

Time_Label:
    DB 'Time: ', 0
	
WarningStr: 
	db 'WARNING: CHANGES NOT APPLIED. TO ENTER SET MODE, BEGIN COMMAND WITH "C".\n\r>',0
	
ErrorStr:
   db 'ERROR: INVALID COMMAND.\n\r>', 0
   
InputErrorStr: 
	db '\n\rERROR: INVALID INPUT. ENTER A NUMBER 0-255.\n\r>', 0
	
SoakTempStr:
	db 'Param SOAK TEMP? =',0
	
SoakTimeStr:
	db 'Param SOAK TIME? =',0
	
ReflTempStr:
	db 'Param REFLOW TEMP? =',0
	
ReflTimeStr:
	db 'Param REFLOW TIME? =',0
	
SavedStr:   
	db '\n\rParameter saved.\n\r>',0	
	
	
; ====================================================================
; SUBROUTINE DEFINITIONS: KEYBOARD DEFINITIONS
; ====================================================================
	
	;the following comment text is from Theo's test.asm file, feb 10, 2026:
	
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

; Clear input buffer
ClearInputBuffer:
	mov InputBuffer, #0
	mov InputBuffer+1, #0
	mov InputBuffer+2, #0
	ret

; Add ASCII character to input buffer
; Input: A contains ASCII character
; Just stores it in the buffer, no validation
AddToBuffer:
	; Check if buffer already has 3 characters
	mov R2, InputBuffer+2
	cjne R2, #0, BufferFull
	mov R2, InputBuffer+1
	cjne R2, #0, AddThird
	mov R2, InputBuffer
	cjne R2, #0, AddSecond
	; First character
	mov InputBuffer, A
	ret
AddSecond:
	; Second character  
	mov InputBuffer+1, A
	ret
AddThird:
	; Third character
	mov InputBuffer+2, A
	ret
BufferFull:
	; Already have 3 characters, can't add more (will check on Enter)
	ret

; Validate and convert input buffer to number
; Returns: A = converted number (0-255), CY = 1 if error
ValidateAndConvert:
	; Check if buffer is empty
	mov A, InputBuffer
	jz EmptyInput
	
	; Check if first character is a digit
	mov A, InputBuffer
	lcall CheckDigit
	jc ValidationError
	mov R4, A              ; Save first digit value in R4
	
	; Check if there's a second character
	mov A, InputBuffer+1
	jz SingleDigit        ; Only one digit
	
	; Check if second character is a digit
	lcall CheckDigit
	jc ValidationError
	mov R5, A             ; Save second digit value in R5
	
	; Check if there's a third character
	mov A, InputBuffer+2
	jz TwoDigits          ; Only two digits
	
	; Check if third character is a digit
	lcall CheckDigit
	jc ValidationError
	mov R6, A             ; Save third digit value in R6
	
	; Calculate: first_digit * 100 + second_digit * 10 + third_digit
	mov A, R4             ; Get first digit
	mov B, #100
	mul AB                ; A = first_digit * 100, B = overflow
	; Check if multiplication overflowed (B should be 0 unless first_digit >= 3)
	mov R7, A             ; Save result (first * 100)
	mov A, B
	jnz CheckValid3Digit  ; If B != 0, need to validate carefully
	
Add2ndAnd3rdDigits:
	; Add second_digit * 10
	mov A, R5
	mov B, #10
	mul AB
	add A, R7             ; Add to running total
	jc ValidationError    ; Overflow
	mov R7, A
	
	; Add third digit
	mov A, R7
	add A, R6
	jc ValidationError    ; Overflow
	
	; Final result in A
	clr C
	ret

CheckValid3Digit:
	; First digit is >= 3, could be 200-299, need to validate
	; Only 200-255 are valid
	mov A, R4
	cjne A, #2, ValidationError  ; If first digit != 2, it's > 255
	; First digit is 2, check if 2XX <= 255
	; This means second_digit * 10 + third_digit <= 55
	mov A, R5
	mov B, #10
	mul AB
	add A, R6
	; A now has the last two digits as a number
	clr C
	subb A, #56           ; Check if > 55
	jnc ValidationError   ; If >= 56, then 2XX > 255
	; Valid! Calculate actual value
	sjmp Add2ndAnd3rdDigits

TwoDigits:
	; Calculate: first_digit * 10 + second_digit
	mov A, R4             ; Get first digit
	mov B, #10
	mul AB                ; A = first_digit * 10
	add A, R5             ; Add second digit
	jc ValidationError    ; Overflow (shouldn't happen with 2 digits)
	clr C
	ret

SingleDigit:
	mov A, R4             ; Single digit value
	clr C
	ret

EmptyInput:
ValidationError:
	setb C
	ret

; Check if ASCII character in A is a digit ('0'-'9')
; Returns: A = numeric value (0-9), CY = 1 if not a digit
CheckDigit:
	clr C
	subb A, #'0'
	jc NotDigit           ; Less than '0'
	; A now contains value 0-? 
	mov B, A
	clr C
	subb A, #10           ; Check if >= 10
	jnc NotDigit          ; If A >= 10, not a digit
	mov A, B              ; Restore numeric value (0-9)
	clr C
	ret
NotDigit:
	setb C
	ret

; Display number in A as decimal ASCII
; Input: A = number (0-255)
DisplayNumber:
	mov B, #100
	div AB                ; A = hundreds, B = remainder
	mov R2, B             ; Save remainder
	mov B, A              ; Save hundreds digit
	
	; Check if we need to display hundreds
	mov A, B
	jz SkipHundreds
	add A, #'0'
	lcall putchar
	
SkipHundreds:
	; Get tens digit
	mov A, R2             ; Get remainder
	mov B, #10
	div AB                ; A = tens, B = ones
	mov R3, B             ; Save ones digit
	
	; Display tens (if hundreds was shown, or if tens > 0)
	mov B, A              ; Save tens
	mov A, R2
	mov R2, #100
	clr C
	subb A, R2
	jnc ShowTens          ; If original remainder >= 100, show tens
	mov A, B
	jz SkipTens           ; If no hundreds and tens = 0, skip
	
ShowTens:
	mov A, B
	add A, #'0'
	lcall putchar
	
SkipTens:
	; Always display ones digit
	mov A, R3
	add A, #'0'
	lcall putchar
	ret

; Get the currently selected parameter value
; Returns: A = parameter value
GetCurrentParam:
	jb MODE, GetReflowParam
	; MODE = 0: Soak
	jb PARAM, GetSoakTime
	mov A, SoakTemp
	ret
GetSoakTime:
	mov A, SoakTime
	ret
GetReflowParam:
	; MODE = 1: Reflow
	jb PARAM, GetReflowTime
	mov A, ReflowTemp
	ret
GetReflowTime:
	mov A, ReflowTime
	ret

; Save the input buffer to the appropriate parameter variable
SaveInputToParam:
	; First validate and convert the input
	lcall ValidateAndConvert
	jc SaveError          ; If CY = 1, validation failed
	
	; A contains the valid number (0-255)
	mov R2, A             ; Save the value
	
	jb MODE, SaveReflowParam
	; MODE = 0: Soak
	jb PARAM, SaveSoakTime
	; Save to SoakTemp
	mov A, R2
	mov SoakTemp, A
	sjmp ParamSaved
SaveSoakTime:
	mov A, R2
	mov SoakTime, A
	sjmp ParamSaved
SaveReflowParam:
	; MODE = 1: Reflow
	jb PARAM, SaveReflowTime
	; Save to ReflowTemp
	mov A, R2
	mov ReflowTemp, A
	sjmp ParamSaved
SaveReflowTime:
	mov A, R2
	mov ReflowTime, A
ParamSaved:
	mov dptr, #SavedStr
	lcall SendString
	clr INPUTTING
	lcall ClearInputBuffer
	ret

SaveError:
	; Check if empty or invalid
	mov A, InputBuffer
	jz EmptyError
	; Invalid/overflow error
	mov dptr, #InputErrorStr
	lcall SendString
	lcall ClearInputBuffer
	ret
EmptyError:
	mov dptr, #InputErrorStr
	lcall SendString
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
	ljmp PS2_Done
	
jump:
	ljmp PS2_Done
	
CheckData:
	;Read data bits
	clr C
	subb A, #10      ;Carry if A < 10 (bits 2-9)
	jnc CheckIfDoneJump
	mov C, PS2_DAT   ;Read data line
	mov A, R1
	rrc A            ;Shift into R1
	mov R1, A
	mov A, R0
	cjne A, #9, jump
	mov A, R1
	cjne A, #0F0h, NotRelease
	setb RELEASE_FLAG ;stop code
	ljmp PS2_Done
CheckIfDoneJump:
	ljmp CheckIfDone
NotRelease:
	jb RELEASE_FLAG, ClearRelJump
	lcall Scancode_To_ASCII
	jz jump
	mov LEDRA, A  
	
	; Check if we're in number input mode
	jnb INPUTTING, NotInputtingNum
	; We're inputting a number - just accumulate characters
	cjne A, #0Ah, JustAddChar
	; Enter key pressed - validate and save the value
	lcall SaveInputToParam
	ljmp PS2_Done
	
ClearRelJump:
	ljmp ClearRel
JustAddChar:
	; Just echo the character and add to buffer (no validation yet)
	lcall putchar
	lcall AddToBuffer
	ljmp PS2_Done
	
NotInputtingNum:
	; Check if we need to show a prompt (Enter pressed after 't' or 'x')
	cjne A, #0Ah, NotEnterJump
	; Enter key pressed
	jnb PROMPT_PENDING, CheckGetParam
	; We need to show the parameter prompt
	mov A, #0Ah    
	lcall putchar
	mov A, #'\r'   
	lcall putchar
	; Show the appropriate prompt based on MODE and PARAM
	jb MODE, ShowReflowPrompt
	jb PARAM, ShowSoakTimePrompt
	mov dptr, #SoakTempStr
	lcall SendString
	sjmp StartInputMode
NotEnterJump:
	ljmp NotEnter
ShowSoakTimePrompt:
	mov dptr, #SoakTimeStr
	lcall SendString
	sjmp StartInputMode
ShowReflowPrompt:
	jb PARAM, ShowReflowTimePrompt
	mov dptr, #ReflTempStr
	lcall SendString
	sjmp StartInputMode
ShowReflowTimePrompt:
	mov dptr, #ReflTimeStr
	lcall SendString
StartInputMode:
	setb INPUTTING
	clr PROMPT_PENDING
	lcall ClearInputBuffer
	ljmp PS2_Done

CheckGetParam:
	; Check if we need to display current parameter value
	jnb GET_PARAM, NormalEnter
	; Display the current parameter
	mov A, #0Ah    
	lcall putchar
	mov A, #'\r'   
	lcall putchar
	; Show parameter name
	jb MODE, ShowReflowParamName
	jb PARAM, ShowSoakTimeName
	mov dptr, #SoakTempStr
	lcall SendString
	sjmp ShowParamValue
ShowSoakTimeName:
	mov dptr, #SoakTimeStr
	lcall SendString
	sjmp ShowParamValue
ShowReflowParamName:
	jb PARAM, ShowReflowTimeName
	mov dptr, #ReflTempStr
	lcall SendString
	sjmp ShowParamValue
ShowReflowTimeName:
	mov dptr, #ReflTimeStr
	lcall SendString
ShowParamValue:
	lcall GetCurrentParam
	lcall DisplayNumber
	mov A, #0Ah    
	lcall putchar
	mov A, #'\r'   
	lcall putchar
	mov A, #'>'
	lcall putchar
	clr GET_PARAM
	ljmp PS2_Done
	
NormalEnter:
	; Normal Enter handling (not after 't' or 'x')
	mov A, #0Ah    
	lcall putchar
	mov A, #'\r'   
	lcall putchar
	mov A, #'>'     
	lcall putchar
	jb INVALID, Error
	jnb SET_FLAG, Warning
	ljmp PS2_Done
	
Error:
	mov dptr, #ErrorStr
	lcall SendString
	clr INVALID
	sjmp PS2_Done
	
Warning:
	mov dptr, #WarningStr
	lcall SendString
	sjmp PS2_Done
	
NotEnter:
	lcall putchar
	cjne A, #'q', NotQ
	clr SET_FLAG
	sjmp PS2_Done

NotQ:
	setb AWAIT
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
	setb AWAIT
	sjmp PS2_Done
	
CheckT:
	cjne A, #'t', CheckX
	setb PARAM
	lcall Update_HEX_Display
	setb PROMPT_PENDING   ; Will prompt on next Enter
	sjmp PS2_Done
	
CheckX:
	cjne A, #'x', CheckG
	clr PARAM
	lcall Update_HEX_Display
	setb PROMPT_PENDING   ; Will prompt on next Enter
	sjmp PS2_Done

CheckG:
	cjne A, #'g', InvalidHandler
	setb GET_PARAM        ; Will display current parameter on next Enter
	sjmp PS2_Done

InvalidHandler:
	setb INVALID
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
	;Prevents from going out of sync (this was a problem because we're not explicitly checking the parity bit)
	clr C
	subb A, #12
	jc PS2_Done
	sjmp Reset
PS2_Done:
	pop PSW
	pop ACC
	reti
	
; ====================================================================
; SUBROUTINE DEFINITIONS: FSM DEFINITIONS
; ====================================================================

FSM_Reflow:
    mov a, FSM_state

FSM_State0:
    cjne a, #0, FSM_State1
    mov pwm, #0
    jb START_BUTTON, FSM_State0_Done
    lcall Wait50ms
    jb START_BUTTON, FSM_State0_Done
    jnb START_BUTTON, $
    mov FSM_state, #1
    mov sec, #0
    mov minutes, #0
    mov state_timer, #0
    mov a, temp
    mov temp_state_start, a
    mov temp_max_state, a
    mov temp_previous, a
FSM_State0_Done:
    ljmp FSM_Done

FSM_State1:
    cjne a, #1, FSM_State2
    mov pwm, #100
    
    mov a, temp
    clr c
    subb a, temp_max_state
    jc Check_Temp_Drop
    mov a, temp
    mov temp_max_state, a
    
Check_Temp_Drop:
    mov a, temp_max_state
    clr c
    subb a, temp
    clr c
    subb a, #TEMP_DROP_THRESHOLD
    jc Check_Door_Open
    mov error_code, #ERR_TEMP_DROP
    ljmp Handle_Error
    
Check_Door_Open:
    mov a, temp_previous
    clr c
    subb a, temp
    clr c
    subb a, #20
    jc Check_UnderTemp
    mov error_code, #ERR_DOOR_OPEN
    ljmp Handle_Error
    
Check_UnderTemp:
    mov a, state_timer
    cjne a, #30, Check_Soak_Temp
    mov a, temp
    clr c
    subb a, temp_state_start
    clr c
    subb a, #20
    jnc Check_Soak_Temp
    mov error_code, #ERR_UNDERTEMP
    ljmp Handle_Error
    
Check_Soak_Temp:
    mov a, tempsoak
    clr c
    subb a, temp
    jnc FSM_State1_Check_Timeout
    mov FSM_state, #2
    mov sec, #0
    mov state_timer, #0
    ljmp FSM_State1_Done
    
FSM_State1_Check_Timeout:
    mov a, state_timer
    cjne a, #120, FSM_State1_Done
    mov error_code, #ERR_TIMEOUT
    ljmp Handle_Error
FSM_State1_Done:
    ljmp FSM_Done

FSM_State2:
    cjne a, #2, FSM_State3
    mov pwm, #20
    mov a, timesoak
    clr c
    subb a, sec
    jnc FSM_State2_Done
    mov FSM_state, #3
    mov sec, #0
    mov state_timer, #0
    mov a, temp
    mov temp_max_state, a
FSM_State2_Done:
    ljmp FSM_Done

FSM_State3:
    cjne a, #3, FSM_State4
    mov pwm, #100
    
    mov a, temp
    clr c
    subb a, temp_max_state
    jc FSM_State3_Check_Reflow
    mov a, temp
    mov temp_max_state, a
    
FSM_State3_Check_Reflow:
    mov a, tempreflow
    clr c
    subb a, temp
    jnc FSM_State3_Check_Timeout
    mov FSM_state, #4
    mov sec, #0
    mov state_timer, #0
    ljmp FSM_State3_Done
    
FSM_State3_Check_Timeout:
    mov a, state_timer
    cjne a, #90, FSM_State3_Done
    mov error_code, #ERR_TIMEOUT
    ljmp Handle_Error
FSM_State3_Done:
    ljmp FSM_Done

FSM_State4:
    cjne a, #4, FSM_State5
    mov pwm, #100
    
    mov a, temp
    clr c
    subb a, #TEMP_MAX
    jnc Temp_Too_High
    sjmp Check_Reflow_Time
    
Temp_Too_High:
    mov error_code, #ERR_OVERTEMP
    ljmp Handle_Error
    
Check_Reflow_Time:
    mov a, timereflow
    clr c
    subb a, sec
    jnc FSM_State4_Done
    mov FSM_state, #5
    mov sec, #0
FSM_State4_Done:
    ljmp FSM_Done

FSM_State5:
    cjne a, #5, FSM_Done
    mov pwm, #0
    mov a, temp
    clr c
    subb a, #TEMP_COOL
    jnc FSM_State5_Done
    mov FSM_state, #0
FSM_State5_Done:

FSM_Done:
    mov a, temp
    mov temp_previous, a
    ret

; ====================================================================
; FSM ERROR HANDLER
; ====================================================================

Handle_Error:
    mov pwm, #0
    clr SSR_CONTROL
    setb BUZZER
    
    lcall LCD_Clear
    mov dptr, #Error_Prefix
    lcall LCD_Print_String
    mov a, error_code
    add a, #'0'
    lcall LCD_Write_Data
    
    mov a, #0xC0
    lcall LCD_Write_Command
    
    mov a, error_code
    dec a
    mov b, #16
    mul ab
    mov dptr, #Error_Messages
    add a, dpl
    mov dpl, a
    mov a, b
    addc a, dph
    mov dph, a
    lcall LCD_Print_String
    
    lcall Wait2s
    clr BUZZER
    
    mov FSM_state, #0
    mov error_code, #ERR_NONE
    ret

; ====================================================================
; ADC (gets temperature from adc)
; ====================================================================

Read_Temperature:
    anl REF0CN, #0b_1101_1111
    orl REF0CN, #0b_0000_0011
    
    anl ADC0CF, #0b_1111_1000
    orl ADC0CF, #0b_0000_0000
    
    mov ADC0MX, #TEMP_ADC_CH
    
    mov ADC0CN0, #0b_1001_0000
    
ADC_wait:
    mov a, ADC0CN0
    jnb acc.5, ADC_wait
    
    anl ADC0CN0, #0b_1101_1111
    
    mov a, ADC0L
    mov R0, a
    mov a, ADC0H
    mov R1, a
    
    ; TODO: Add your temperature calibration/conversion here
    ; Current: just use upper 8 bits
    mov temp, R1
    
    ret

; ====================================================================
; PWM & DISPLAY
; ====================================================================

Update_PWM:
    mov a, pwm
    jz PWM_Off
    setb SSR_CONTROL
    setb STATUS_LED
    ret
PWM_Off:
    clr SSR_CONTROL
    clr STATUS_LED
    ret

Update_Display:
    mov a, #0x80
    lcall LCD_Write_Command
    
    mov a, FSM_state
    mov b, #8
    mul ab
    mov dptr, #State_Names
    add a, dpl
    mov dpl, a
    mov a, b
    addc a, dph
    mov dph, a
    lcall LCD_Print_String
    
    mov a, #' '
    lcall LCD_Write_Data
    mov a, temp
    lcall SendToLCD
    mov a, #'C'
    lcall LCD_Write_Data
    
    mov a, #0xC0
    lcall LCD_Write_Command
    mov dptr, #Time_Label
    lcall LCD_Print_String
    mov a, minutes
    lcall SendToLCD
    mov a, #':'
    lcall LCD_Write_Data
    mov a, sec
    lcall SendToLCD
    ret

Send_Serial_Data:
    mov a, temp
    lcall SendToSerialPort
    mov a, #','
    lcall putchar
    mov a, FSM_state
    add a, #'0'
    lcall putchar
    mov a, #','
    lcall putchar
    mov a, pwm
    lcall SendToSerialPort
    mov a, #13
    lcall putchar
    mov a, #10
    lcall putchar
    ret

; ====================================================================
; BINARY TO DECIMAL (from slides)
; ====================================================================

SendToLCD:
    push acc
    push b
    mov b, #100
    div ab
    orl a, #0x30
    lcall LCD_Write_Data
    mov a, b
    mov b, #10
    div ab
    orl a, #0x30
    lcall LCD_Write_Data
    mov a, b
    orl a, #0x30
    lcall LCD_Write_Data
    pop b
    pop acc
    ret

SendToSerialPort:
    push acc
    push b
    mov b, #100
    div ab
    orl a, #0x30
    lcall putchar
    mov a, b
    mov b, #10
    div ab
    orl a, #0x30
    lcall putchar
    mov a, b
    orl a, #0x30
    lcall putchar
    pop b
    pop acc
    ret

; ====================================================================
; LCD
; ====================================================================

LCD_Print_String:
    push acc
LCD_Print_Loop:
    clr a
    movc a, @a+dptr
    jz LCD_Print_Done
    lcall LCD_Write_Data
    inc dptr
    sjmp LCD_Print_Loop
LCD_Print_Done:
    pop acc
    ret

LCD_Init:
    lcall Wait50ms
    mov a, #0x33
    lcall LCD_Write_Command
    lcall Wait5ms
    mov a, #0x32
    lcall LCD_Write_Command
    lcall Wait5ms
    mov a, #0x28
    lcall LCD_Write_Command
    lcall Wait2ms
    mov a, #0x0C
    lcall LCD_Write_Command
    lcall Wait2ms
    mov a, #0x01
    lcall LCD_Write_Command
    lcall Wait2ms
    mov a, #0x06
    lcall LCD_Write_Command
    lcall Wait2ms
    ret

LCD_Clear:
    mov a, #0x01
    lcall LCD_Write_Command
    lcall Wait2ms
    ret

LCD_Write_Command:
    clr LCD_RS
    lcall LCD_Write_Nibble_High
    lcall LCD_Write_Nibble_Low
    lcall Wait50us
    ret

LCD_Write_Data:
    setb LCD_RS
    lcall LCD_Write_Nibble_High
    lcall LCD_Write_Nibble_Low
    lcall Wait50us
    ret

LCD_Write_Nibble_High:
    push acc
    mov c, acc.7
    mov LCD_D7, c
    mov c, acc.6
    mov LCD_D6, c
    mov c, acc.5
    mov LCD_D5, c
    mov c, acc.4
    mov LCD_D4, c
    setb LCD_E
    lcall Wait5us
    clr LCD_E
    pop acc
    ret

LCD_Write_Nibble_Low:
    push acc
    mov c, acc.3
    mov LCD_D7, c
    mov c, acc.2
    mov LCD_D6, c
    mov c, acc.1
    mov LCD_D5, c
    mov c, acc.0
    mov LCD_D4, c
    setb LCD_E
    lcall Wait5us
    clr LCD_E
    pop acc
    ret

; ====================================================================
; UART
; ====================================================================

putchar:
    jnb TI, putchar
    clr TI
    mov SBUF, a
    ret

; ====================================================================
; DELAYS
; ====================================================================

Wait100ms:
    push acc
    mov R2, #5
Wait100ms_L1:
    lcall Wait10ms
    lcall Wait10ms
    djnz R2, Wait100ms_L1
    pop acc
    ret

Wait50ms:
    push acc
    mov R2, #5
Wait50ms_L1:
    lcall Wait10ms
    djnz R2, Wait50ms_L1
    pop acc
    ret

Wait10ms:
    push acc
    mov R2, #50
Wait10ms_L1:
    lcall Wait200us
    djnz R2, Wait10ms_L1
    pop acc
    ret

Wait5ms:
    push acc
    mov R2, #25
Wait5ms_L1:
    lcall Wait200us
    djnz R2, Wait5ms_L1
    pop acc
    ret

Wait2ms:
    push acc
    mov R2, #10
Wait2ms_L1:
    lcall Wait200us
    djnz R2, Wait2ms_L1
    pop acc
    ret

Wait200us:
    push acc
    mov R3, #250
Wait200us_L1:
    nop
    nop
    djnz R3, Wait200us_L1
    pop acc
    ret

Wait50us:
    push acc
    mov R3, #62
Wait50us_L1:
    nop
    djnz R3, Wait50us_L1
    pop acc
    ret

Wait5us:
    push acc
    mov R3, #6
Wait5us_L1:
    nop
    djnz R3, Wait5us_L1
    pop acc
    ret

Wait1s:
    push acc
    mov R4, #10
Wait1s_L1:
    lcall Wait100ms
    djnz R4, Wait1s_L1
    pop acc
    ret

Wait2s:
    lcall Wait1s
    lcall Wait1s
    ret

; ====================================================================
; TIMER ISR
; ====================================================================

Timer0_ISR:
    push acc
    push psw
    
    mov TH0, #0xD5
    mov TL0, #0x90
    
    inc ms_counter
    mov a, ms_counter
    cjne a, #100, Timer0_Done
    
    mov ms_counter, #0
    inc sec
    mov a, sec
    cjne a, #60, Timer0_Done
    mov sec, #0
    inc minutes
    inc state_timer
    
Timer0_Done:
    pop psw
    pop acc
    reti


	
; ====================================================================
; MAIN PROGRAM
; ====================================================================
	
MainProgram:

;MainProgram, for the keyboard:
	mov LEDRA, #0X00
	mov LEDRB, #0x00
	mov HEX0, #0xC6  ; Initialize to "C" (temperature)
    mov sp, #0x7f
    mov A, #'\r'
    lcall Initialize_PS2
    lcall InitSerialPort
    lcall putchar
 	mov A, #'\n'
 	lcall putchar
    mov A, #'>'
    lcall putchar
    
;MainProgram, for the FSM

    mov WDTCN, #0xDE
    mov WDTCN, #0xAD
    mov SP, #7FH
    
    mov XBR0, #0x00
    mov XBR1, #0x00
    mov XBR2, #0x40
    
    mov P0MDOUT, #0x0F
    mov P1MDOUT, #0x18
    mov P1, #0xC0
    mov P2MDOUT, #0x07
    mov P3MDOUT, #0x00
    mov P3, #0xFF
    
    lcall Timer0_Init
    lcall LCD_Init
    lcall Wait50ms
    mov dptr, #Startup_Msg
    lcall LCD_Print_String
    lcall Wait1s
    lcall Init_Variables
    
    
    
forever:
	;mostly just subroutine calls from for the fsm code
    lcall Check_Abort
    lcall Read_Temperature
    lcall Check_Sensor
    lcall FSM_Reflow
    lcall Update_PWM
    lcall Update_Display
    lcall Send_Serial_Data
    lcall Wait100ms
    
	sjmp forever
	
	

end