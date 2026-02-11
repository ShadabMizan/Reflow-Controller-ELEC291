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
BAUD           equ 115200
TIMER_2_RELOAD equ (0x10000-(CLK/(32*BAUD)))
CLK EQU 33333333
TIMER_10ms EQU (65536-(CLK/(12*100)))
PS2_DAT EQU P3.3
TRANSMIT_MODE EQU P0.0
TRANSMIT_PARAM EQU P0.2
TRANSMIT_SET EQU P0.4

BIT1 EQU P1.3
BIT2 EQU P1.5
BIT3 EQU P1.7
BIT4 EQU P2.1
BIT5 EQU P2.3
BIT6 EQU P2.5
BIT7 EQU P2.7
BIT8 EQU P3.1

RELEASE_FLAG BIT 20h.0
SET_FLAG BIT 20h.1
MODE BIT 20h.2 ;0=Soak, 1=Reflow
PARAM BIT 20h.3;0=Temp, 1=Time
INVALID BIT 20h.4 ;Encountered invalid input
AWAIT BIT 20h.5
INPUTTING BIT 20h.6
PROMPT_PENDING BIT 20h.7 ; Flag to show prompt on next Enter
GET_PARAM BIT 21h.0 ; Flag to show parameter value on Enter

; Data storage for parameters
dseg at 30h
SoakTemp:    ds 1  ; Soak temperature parameter
SoakTime:    ds 1  ; Soak time parameter
ReflowTemp:  ds 1  ; Reflow temperature parameter
ReflowTime:  ds 1  ; Reflow time parameter
InputBuffer: ds 3  ; 3-byte buffer for building the number (max 3 digits for 255)

cseg
    org 0000h       
    ljmp MainProgram
    
    ;Interrupt on keypress at address 0003h
    org 0003h
    ljmp PS2_Interrupt
	
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
WarningStr: db 'WARNING: CHANGES NOT APPLIED. TO ENTER SET MODE, BEGIN COMMAND WITH "C".\n\r>',0
ErrorStr:   db 'ERROR: INVALID COMMAND.\n\r>', 0
InputErrorStr: db '\n\rERROR: INVALID INPUT. ENTER A NUMBER 0-255.\n\r>', 0
SoakTempStr:db 'Param SOAK TEMP? =',0
SoakTimeStr:db 'Param SOAK TIME? =',0
ReflTempStr:db 'Param REFLOW TEMP? =',0
ReflTimeStr:db 'Param REFLOW TIME? =',0
SavedStr:   db '\n\rParameter saved.\n\r>',0

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

; Update output pins with current state
UpdateOutputs:
	; Update TRANSMIT_MODE (P0.0) with MODE bit
	jb MODE, SetMode1
	clr TRANSMIT_MODE
	sjmp DoneMode
SetMode1:
	setb TRANSMIT_MODE
DoneMode:
	
	; Update TRANSMIT_PARAM (P0.2) with PARAM bit
	jb PARAM, SetParam1
	clr TRANSMIT_PARAM
	sjmp DoneParam
SetParam1:
	setb TRANSMIT_PARAM
DoneParam:
	
	; Update TRANSMIT_SET (P0.4) with SET_FLAG bit
	jb SET_FLAG, SetFlag1
	clr TRANSMIT_SET
	sjmp DoneSet
SetFlag1:
	setb TRANSMIT_SET
DoneSet:
	
	; Get current parameter value
	lcall GetCurrentParam  ; Returns value in A
	mov R2, A             ; Save in R2
	
	; Output the 8-bit value to BIT1-BIT8
	; Bit 0 -> BIT1 (P1.3)
	mov A, R2
	jb ACC.0, SetBit1
	clr BIT1
	sjmp DoneBit1
SetBit1:
	setb BIT1
DoneBit1:
	
	; Bit 1 -> BIT2 (P1.5)
	mov A, R2
	jb ACC.1, SetBit2
	clr BIT2
	sjmp DoneBit2
SetBit2:
	setb BIT2
DoneBit2:
	
	; Bit 2 -> BIT3 (P1.7)
	mov A, R2
	jb ACC.2, SetBit3
	clr BIT3
	sjmp DoneBit3
SetBit3:
	setb BIT3
DoneBit3:
	
	; Bit 3 -> BIT4 (P2.1)
	mov A, R2
	jb ACC.3, SetBit4
	clr BIT4
	sjmp DoneBit4
SetBit4:
	setb BIT4
DoneBit4:
	
	; Bit 4 -> BIT5 (P2.3)
	mov A, R2
	jb ACC.4, SetBit5
	clr BIT5
	sjmp DoneBit5
SetBit5:
	setb BIT5
DoneBit5:
	
	; Bit 5 -> BIT6 (P2.5)
	mov A, R2
	jb ACC.5, SetBit6
	clr BIT6
	sjmp DoneBit6
SetBit6:
	setb BIT6
DoneBit6:
	
	; Bit 6 -> BIT7 (P2.7)
	mov A, R2
	jb ACC.6, SetBit7
	clr BIT7
	sjmp DoneBit7
SetBit7:
	setb BIT7
DoneBit7:
	
	; Bit 7 -> BIT8 (P3.1)
	mov A, R2
	jb ACC.7, SetBit8
	clr BIT8
	sjmp DoneBit8
SetBit8:
	setb BIT8
DoneBit8:
	
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

MainProgram:
	mov P0MOD, #0b11111111
	mov P1MOD, #0b11111111
	mov P2MOD, #0b11111111
	mov P3MOD, #0b1
	mov LEDRA, #0X00
	mov LEDRB, #0x00
	mov HEX0, #0xC6  ; Initialize to "C" (temperature)
	
	; Initialize parameters to default values
	mov SoakTemp, #0
	mov SoakTime, #0
	mov ReflowTemp, #0
	mov ReflowTime, #0
	
    mov sp, #0x7f
    mov A, #'\r'
    lcall Initialize_PS2
    lcall InitSerialPort
    lcall putchar
 	mov A, #'\n'
 	lcall putchar
    mov A, #'>'
    lcall putchar
    
    ; Initial output update
    lcall UpdateOutputs
    
forever:
	; Continuously update outputs
	lcall UpdateOutputs
	sjmp forever
	
end