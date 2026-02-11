$NOLIST
$MODDE1SOC
$LIST

; ====================================================================
; CONSTANTS
; ====================================================================
BAUD           EQU 115200
TIMER_2_RELOAD EQU (0x10000-(CLK/(32*BAUD)))
CLK            EQU 33333333

; Reflow oven temperature/time constants (defaults)
TEMP_SOAK           EQU 150
TIME_SOAK           EQU 60
TEMP_REFLOW         EQU 220
TIME_REFLOW         EQU 45
TEMP_COOL           EQU 60
TEMP_MAX            EQU 240
TEMP_DROP_THRESHOLD EQU 10

; Error codes
ERR_NONE        EQU 0
ERR_ABORT       EQU 1
ERR_TEMP_DROP   EQU 2
ERR_OVERTEMP    EQU 3
ERR_SENSOR      EQU 4
ERR_TIMEOUT     EQU 5
ERR_UNDERTEMP   EQU 6
ERR_DOOR_OPEN   EQU 7
ERR_POWER       EQU 8

; ====================================================================
; PIN DEFINITIONS
; ====================================================================
ABORT_BUTTON    EQU P1.6
START_BUTTON    EQU P1.7
SSR_CONTROL     EQU P2.0
STATUS_LED      EQU P2.1
BUZZER          EQU P2.2
LCD_RS_PIN      EQU P1.3
LCD_E           EQU P1.4
LCD_D4          EQU P0.0
LCD_D5          EQU P0.1
LCD_D6          EQU P0.2
LCD_D7          EQU P0.3
TEMP_ADC_CH     EQU 0
PS2_DAT         EQU P3.3

; ====================================================================
; BIT VARIABLES
; ====================================================================
BSEG
mf:             dbit 1
RELEASE_FLAG:   dbit 1
SET_FLAG:       dbit 1
MODE:           dbit 1
PARAM:          dbit 1
INVALID:        dbit 1
AWAIT:          dbit 1
INPUTTING:      dbit 1
PROMPT_PENDING: dbit 1
GET_PARAM:      dbit 1

; ====================================================================
; BYTE VARIABLES
; ====================================================================
DSEG at 30h
; Math32 variables
x:                  ds 4
y:                  ds 4
bcd:                ds 5

; FSM state variables
FSM_state:          ds 1
temp:               ds 1
temp_state_start:   ds 1
temp_max_state:     ds 1
temp_previous:      ds 1
sec:                ds 1
minutes:            ds 1
state_timer:        ds 1
ms_counter:         ds 1
serial_counter:     ds 1    ; Counter for 100ms serial output
pwm:                ds 1
error_code:         ds 1

; Reflow parameters (keyboard can modify these)
tempsoak:           ds 1
timesoak:           ds 1
tempreflow:         ds 1
timereflow:         ds 1
undertemp_checked:  ds 1

; PS/2 input buffer
InputBuffer:        ds 3

; Aliases for PS/2 code
SoakTemp    EQU tempsoak
SoakTime    EQU timesoak
ReflowTemp  EQU tempreflow
ReflowTime  EQU timereflow

; ====================================================================
; CODE
; ====================================================================
CSEG

org 0000H
    ljmp main

org 0003H
    ljmp PS2_Interrupt

org 000BH
    ljmp Timer0_ISR

org 0013H
    reti

org 001BH
    ljmp Timer1_ISR       ; Timer1 for serial monitoring

org 0023H
    reti

$INCLUDE(math32.inc)

; ====================================================================
; PS/2 KEYBOARD - SCANCODE TO ASCII TABLE
; ====================================================================
org 0030h
ASCII_TABLE:
    DB 0, 0, 0, 0, 0, 0, 0, 0
    DB 0, 0, 0, 0, 0, 0, '`', 0
    DB 0, 0, 0, 0, 0, 'q', '1', 0
    DB 0, 0, 'z', 's', 'a', 'w', '2', 0
    DB 0, 'c', 'x', 'd', 'e', '4', '3', 0
    DB 0, ' ', 'v', 'f', 't', 'r', '5', 0
    DB 0, 'n', 'b', 'h', 'g', 'y', '6', 0
    DB 0, 0, 'm', 'j', 'u', '7', '8', 0
    DB 0, ',', 'k', 'i', 'o', '0', '9', 0
    DB 0, '.', '/', 'l', ';', 'p', '-', 0
    DB 0, 0, 27h, 0, '[', '=', 0, 0
    DB 0, 0, 0Ah, ']', 0, 5Ch, 0, 0
    DB 0, 0, 0, 0, 0, 0, 0, 0
    DB 0, 0, 0, 0, 0, 0, 0, 0
    DB 0, 0, 0, 0, 0, 0, 0, 0
    DB 0, 0, 0, 0, 0, 0, 0, 0

; ====================================================================
; STRING CONSTANTS
; ====================================================================
WarningStr:     db 'WARNING: CHANGES NOT APPLIED. TO ENTER SET MODE, BEGIN COMMAND WITH "C".\n\r>',0
ErrorStr:       db 'ERROR: INVALID COMMAND.\n\r>', 0
InputErrorStr:  db '\n\rERROR: INVALID INPUT. ENTER A NUMBER 0-255.\n\r>', 0
SoakTempStr:    db 'Param SOAK TEMP? =',0
SoakTimeStr:    db 'Param SOAK TIME? =',0
ReflTempStr:    db 'Param REFLOW TEMP? =',0
ReflTimeStr:    db 'Param REFLOW TIME? =',0
SavedStr:       db '\n\rParameter saved.\n\r>',0
MonitorOnStr:   db '\n\rMonitoring ENABLED.\n\r>',0
MonitorOffStr:  db '\n\rMonitoring DISABLED.\n\r>',0
Startup_Msg:    DB 'Reflow Oven V1.0', 0
Error_Prefix:   DB 'ERROR E', 0
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
    DB 'Ready  ', 0
    DB 'Ramp->S', 0
    DB 'Soak   ', 0
    DB 'Ramp->R', 0
    DB 'Reflow ', 0
    DB 'Cooling', 0
Time_Label:
    DB 'Time: ', 0

; ====================================================================
; MAIN
; ====================================================================
main:
    mov SP, #7FH
    
    ; Initialize port directions
    mov P1, #0xC0
    mov P3, #0xFF
    
    ; Initialize all subsystems
    lcall Timer0_Init
    lcall Timer1_Init
    lcall InitSerialPort
    lcall Initialize_PS2
    lcall LCD_Init
    lcall Wait50ms
    
    ; Show startup message on LCD
    mov dptr, #Startup_Msg
    lcall LCD_Print_String
    lcall Wait1s
    
    ; Initialize variables
    lcall Init_Variables
    
    ; Show prompt on serial terminal
    mov A, #'\r'
    lcall putchar
    mov A, #'\n'
    lcall putchar
    mov A, #'>'
    lcall putchar
    
Forever:
    lcall Check_Abort
    lcall Read_Temperature
    lcall Check_Sensor
    lcall FSM_Reflow
    lcall Update_PWM
    lcall Update_Display
    lcall Wait100ms
    sjmp Forever

; ====================================================================
; INITIALIZATION ROUTINES
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
    mov serial_counter, #0
    mov pwm, #0
    mov error_code, #ERR_NONE
    mov tempsoak, #TEMP_SOAK
    mov timesoak, #TIME_SOAK
    mov tempreflow, #TEMP_REFLOW
    mov timereflow, #TIME_REFLOW
    mov undertemp_checked, #0
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

Timer1_Init:
    ; Configure Timer1 in 16-bit mode (same timing as Timer0: 10ms)
    anl TMOD, #0x0F
    orl TMOD, #0x10    ; Timer1 mode 1 (16-bit)
    mov TH1, #0xD5
    mov TL1, #0x90
    ; Don't enable ET1 yet (monitoring off by default)
    clr ET1
    setb TR1           ; Start Timer1 running
    ret

InitSerialPort:
    mov RCAP2H, #HIGH(TIMER_2_RELOAD)
    mov RCAP2L, #LOW(TIMER_2_RELOAD)
    mov T2CON, #0x34
    mov SCON, #0x52
    ret

Initialize_PS2:
    setb PS2_DAT
    setb IT0
    setb EX0
    setb EA
    mov R0, #0
    mov R1, #0
    clr RELEASE_FLAG
    clr SET_FLAG
    clr INPUTTING
    clr PROMPT_PENDING
    clr GET_PARAM
    mov InputBuffer, #0
    mov InputBuffer+1, #0
    mov InputBuffer+2, #0
    ret

; ====================================================================
; SERIAL PORT ROUTINES
; ====================================================================
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

; ====================================================================
; PS/2 HELPER ROUTINES
; ====================================================================
Scancode_To_ASCII:
    mov DPTR, #ASCII_TABLE
    movc A, @A+DPTR
    ret

Update_HEX_Display:
    jb PARAM, Show_S
    mov HEX0, #0xC6
    ret
Show_S:
    mov HEX0, #0x92
    ret

ClearInputBuffer:
    mov InputBuffer, #0
    mov InputBuffer+1, #0
    mov InputBuffer+2, #0
    ret

AddToBuffer:
    mov R2, InputBuffer+2
    cjne R2, #0, BufferFull
    mov R2, InputBuffer+1
    cjne R2, #0, AddThird
    mov R2, InputBuffer
    cjne R2, #0, AddSecond
    mov InputBuffer, A
    ret
AddSecond:
    mov InputBuffer+1, A
    ret
AddThird:
    mov InputBuffer+2, A
    ret
BufferFull:
    ret

ValidateAndConvert:
    mov A, InputBuffer
    jz EmptyInput
    
    mov A, InputBuffer
    lcall CheckDigit
    jc ValidationError
    mov R4, A
    
    mov A, InputBuffer+1
    jz SingleDigit
    
    lcall CheckDigit
    jc ValidationError
    mov R5, A
    
    mov A, InputBuffer+2
    jz TwoDigits
    
    lcall CheckDigit
    jc ValidationError
    mov R6, A
    
    mov A, R4
    mov B, #100
    mul AB
    mov R7, A
    mov A, B
    jnz CheckValid3Digit
    
Add2ndAnd3rdDigits:
    mov A, R5
    mov B, #10
    mul AB
    add A, R7
    jc ValidationError
    mov R7, A
    
    mov A, R7
    add A, R6
    jc ValidationError
    
    clr C
    ret

CheckValid3Digit:
    mov A, R4
    cjne A, #2, ValidationError
    mov A, R5
    mov B, #10
    mul AB
    add A, R6
    clr C
    subb A, #56
    jnc ValidationError
    sjmp Add2ndAnd3rdDigits

TwoDigits:
    mov A, R4
    mov B, #10
    mul AB
    add A, R5
    jc ValidationError
    clr C
    ret

SingleDigit:
    mov A, R4
    clr C
    ret

EmptyInput:
ValidationError:
    setb C
    ret

CheckDigit:
    clr C
    subb A, #'0'
    jc NotDigit
    mov B, A
    clr C
    subb A, #10
    jnc NotDigit
    mov A, B
    clr C
    ret
NotDigit:
    setb C
    ret

DisplayNumber:
    mov B, #100
    div AB
    mov R2, B
    mov B, A
    
    mov A, B
    jz SkipHundreds
    add A, #'0'
    lcall putchar
    
SkipHundreds:
    mov A, R2
    mov B, #10
    div AB
    mov R3, B
    
    mov B, A
    mov A, R2
    mov R2, #100
    clr C
    subb A, R2
    jnc ShowTens
    mov A, B
    jz SkipTens
    
ShowTens:
    mov A, B
    add A, #'0'
    lcall putchar
    
SkipTens:
    mov A, R3
    add A, #'0'
    lcall putchar
    ret

GetCurrentParam:
    jb MODE, GetReflowParam
    jb PARAM, GetSoakTime
    mov A, SoakTemp
    ret
GetSoakTime:
    mov A, SoakTime
    ret
GetReflowParam:
    jb PARAM, GetReflowTime
    mov A, ReflowTemp
    ret
GetReflowTime:
    mov A, ReflowTime
    ret

SaveInputToParam:
    lcall ValidateAndConvert
    jc SaveError
    
    mov R2, A
    
    jb MODE, SaveReflowParam
    jb PARAM, SaveSoakTime
    mov A, R2
    mov SoakTemp, A
    sjmp ParamSaved
SaveSoakTime:
    mov A, R2
    mov SoakTime, A
    sjmp ParamSaved
SaveReflowParam:
    jb PARAM, SaveReflowTime
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
    mov A, InputBuffer
    jz EmptyError
    mov dptr, #InputErrorStr
    lcall SendString
    lcall ClearInputBuffer
    ret
EmptyError:
    mov dptr, #InputErrorStr
    lcall SendString
    ret

; ====================================================================
; PS/2 INTERRUPT HANDLER
; ====================================================================
PS2_Interrupt:
    push ACC
    push PSW
    
    mov A, R0
    cjne A, #0, NotAtStart
    mov C, PS2_DAT
    jc jump
    
NotAtStart:
    inc R0
    mov A, R0
    cjne A, #1, CheckData
    ljmp PS2_Done
    
jump:
    ljmp PS2_Done
    
CheckData:
    clr C
    subb A, #10
    jnc CheckIfDoneJump
    mov C, PS2_DAT
    mov A, R1
    rrc A
    mov R1, A
    mov A, R0
    cjne A, #9, jump
    mov A, R1
    cjne A, #0F0h, NotRelease
    setb RELEASE_FLAG
    ljmp PS2_Done

CheckIfDoneJump:
    ljmp CheckIfDone

NotRelease:
    jb RELEASE_FLAG, ClearRelJump
    lcall Scancode_To_ASCII
    jz jump
    mov LEDRA, A
    
    jnb INPUTTING, NotInputtingNum
    cjne A, #0Ah, JustAddChar
    lcall SaveInputToParam
    ljmp PS2_Done
    
ClearRelJump:
    ljmp ClearRel

JustAddChar:
    lcall putchar
    lcall AddToBuffer
    ljmp PS2_Done
    
NotInputtingNum:
    cjne A, #0Ah, NotEnterJump
    jnb PROMPT_PENDING, CheckGetParam
    
    mov A, #0Ah
    lcall putchar
    mov A, #'\r'
    lcall putchar
    
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
    jnb GET_PARAM, NormalEnter
    
    mov A, #0Ah
    lcall putchar
    mov A, #'\r'
    lcall putchar
    
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
    mov LEDRB, #0b10
    sjmp PS2_Done
    
CheckR:
    cjne A, #'r', CheckT
    setb MODE
    mov LEDRB, #0b01
    setb AWAIT
    sjmp PS2_Done
    
CheckT:
    cjne A, #'t', CheckX
    setb PARAM
    lcall Update_HEX_Display
    setb PROMPT_PENDING
    sjmp PS2_Done
    
CheckX:
    cjne A, #'x', CheckG
    clr PARAM
    lcall Update_HEX_Display
    setb PROMPT_PENDING
    sjmp PS2_Done

CheckG:
    cjne A, #'g', CheckM
    setb GET_PARAM
    sjmp PS2_Done

CheckM:
    cjne A, #'m', CheckN
    ; Enable monitoring - turn on Timer1 interrupt
    setb ET1
    mov serial_counter, #0
    mov dptr, #MonitorOnStr
    lcall SendString
    sjmp PS2_Done

CheckN:
    cjne A, #'n', InvalidHandler
    ; Disable monitoring - turn off Timer1 interrupt
    clr ET1
    mov dptr, #MonitorOffStr
    lcall SendString
    sjmp PS2_Done

InvalidHandler:
    setb INVALID
    sjmp PS2_Done
    
ClearRel:
    clr RELEASE_FLAG
    sjmp PS2_Done

CheckIfDone:
    cjne A, #11, CheckOverflow
    sjmp Reset
    
Reset:
    mov R0, #0
    mov R1, #0
    sjmp PS2_Done

CheckOverflow:
    clr C
    subb A, #12
    jc PS2_Done
    sjmp Reset

PS2_Done:
    pop PSW
    pop ACC
    reti

; ====================================================================
; FSM LOGIC
; ====================================================================
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
    mov undertemp_checked, #0
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
    mov a, undertemp_checked
    jnz Check_Soak_Temp
    mov a, state_timer
    cjne a, #1, Check_Soak_Temp
    mov undertemp_checked, #1
    mov a, temp
    clr c
    subb a, #50
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
    mov pwm, #20
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

Read_Temperature:
    push acc
    mov a, FSM_state
    cjne a, #0, Sim_State1
    mov temp, #25
    sjmp Sim_Done
Sim_State1:
    cjne a, #1, Sim_State2
    mov a, sec
    add a, #25
    mov temp, a
    sjmp Sim_Done
Sim_State2:
    cjne a, #2, Sim_State3
    mov temp, #150
    sjmp Sim_Done
Sim_State3:
    cjne a, #3, Sim_State4
    mov a, sec
    add a, #150
    mov temp, a
    sjmp Sim_Done
Sim_State4:
    cjne a, #4, Sim_State5
    mov temp, #220
    sjmp Sim_Done
Sim_State5:
    mov a, #220
    clr c
    subb a, sec
    mov temp, a
Sim_Done:
    pop acc
    ret

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
    ; This is now called from Timer1 ISR only
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
; LCD ROUTINES
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
    clr LCD_RS_PIN
    lcall LCD_Write_Nibble_High
    lcall LCD_Write_Nibble_Low
    lcall Wait50us
    ret

LCD_Write_Data:
    setb LCD_RS_PIN
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
; DELAY ROUTINES
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
; TIMER INTERRUPTS
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

Timer1_ISR:
    push acc
    push psw
    ; Reload Timer1 for next 10ms
    mov TH1, #0xD5
    mov TL1, #0x90
    
    ; Count 10 interrupts to get 100ms
    inc serial_counter
    mov a, serial_counter
    cjne a, #10, Timer1_Done
    mov serial_counter, #0
    
    ; Send serial data (only happens if ET1 is enabled)
    lcall Send_Serial_Data
    
Timer1_Done:
    pop psw
    pop acc
    reti

END
