$MODMAX10

; ====================================================================
; CV-8052 SFR DEFINITIONS (for DE10-Lite)
; ====================================================================

; ====================================================================
; PIN DEFINITIONS
; ====================================================================

ABORT_BUTTON    EQU P1.6
START_BUTTON    EQU P1.7
SSR_CONTROL     EQU P3.7        ; ? CHANGED to P3.7 for PWM
STATUS_LED      EQU P2.1
BUZZER          EQU P2.2
LCD_RS_PIN      EQU P1.3
LCD_E           EQU P1.4
LCD_D4          EQU P0.0
LCD_D5          EQU P0.1
LCD_D6          EQU P0.2
LCD_D7          EQU P0.3

TEMP_ADC_CH     EQU 0

; ====================================================================
; CONSTANTS
; ====================================================================

TEMP_SOAK       EQU 150
TIME_SOAK       EQU 60
TEMP_REFLOW     EQU 220
TIME_REFLOW     EQU 45
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

; ====================================================================
; BIT VARIABLES
; ====================================================================

BSEG
mf:                 dbit 1
seconds_flag:       dbit 1      ; For PWM timing
oven_enabled:       dbit 1      ; For PWM control

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
undertemp_checked:  ds 1

; PWM variables (required by pwm.inc)
ticks_per_sec:      ds 2
pwm_tick_counter:   ds 1
pwm_on_ticks:       ds 1

; ====================================================================
; CODE
; ====================================================================

CSEG

org 0000H
    ljmp main

org 0003H
    reti
    
org 000BH
    ljmp Timer0_ISR
    
org 0013H
    reti
    
org 001BH
    reti
    
org 0023H
    reti

org 002BH
    ljmp Timer2_ISR         ; ? ADDED for PWM

$INCLUDE(math32.inc)
$INCLUDE(pwm.inc)           ; ? ADDED for PWM support

; ====================================================================
; MAIN
; ====================================================================

main:
    mov SP, #7FH
    
    ; Initialize port directions
    mov P1, #0xC0
    mov P3, #0xFF
    mov P3MOD, #10000000b    ; ? ADDED: P3.7 = output for PWM
    
    lcall Init_Variables
    lcall Timer0_Init
    lcall Timer2_Init        ; ? ADDED: Initialize PWM timer
    lcall LCD_Init
    lcall Wait50ms
    
    setb EA                  ; Enable interrupts
    
    mov dptr, #Startup_Msg
    lcall LCD_Print_String
    lcall Wait1s

Forever:
    lcall Check_Abort
    lcall Read_Temperature
    lcall Check_Sensor
    lcall FSM_Reflow
    lcall Update_PWM         ; Now uses real PWM from pwm.inc
    lcall Update_Display
    lcall Send_Serial_Data
    lcall Wait100ms
    sjmp Forever

; ====================================================================
; INIT
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
    mov undertemp_checked, #0
    
    ; Initialize PWM variables
    clr a
    mov pwm_tick_counter, a
    mov pwm_on_ticks, a
    clr seconds_flag
    setb oven_enabled        ; Enable PWM output
    ret

Timer0_Init:
    anl TMOD, #0xF0
    orl TMOD, #0x01
    mov TH0, #0xD5
    mov TL0, #0x90
    setb ET0
    setb TR0
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

; ====================================================================
; FSM
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
    mov pwm, #20             ; ? Now actually 20% with real PWM!
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
    mov pwm, #20             ; ? Now actually 20% with real PWM!
    
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
; ERROR HANDLER
; ====================================================================

Handle_Error:
    mov pwm, #0
    lcall Update_PWM         ; Turn off heater
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
; SIMULATED ADC (Replace with real ADC code later)
; ====================================================================

Read_Temperature:
    push acc
    
    ; Simulate temperature based on FSM state
    mov a, FSM_state
    
    cjne a, #0, Sim_State1
    mov temp, #25          ; State 0: Room temp
    sjmp Sim_Done
    
Sim_State1:
    cjne a, #1, Sim_State2
    mov a, sec
    add a, #25             ; State 1: Ramp up
    mov temp, a
    sjmp Sim_Done
    
Sim_State2:
    cjne a, #2, Sim_State3
    mov temp, #150         ; State 2: Soak
    sjmp Sim_Done
    
Sim_State3:
    cjne a, #3, Sim_State4
    mov a, sec
    add a, #150            ; State 3: Ramp to reflow
    mov temp, a
    sjmp Sim_Done
    
Sim_State4:
    cjne a, #4, Sim_State5
    mov temp, #220         ; State 4: Reflow
    sjmp Sim_Done
    
Sim_State5:
    mov a, #220            ; State 5: Cool down
    clr c
    subb a, sec
    mov temp, a
    
Sim_Done:
    pop acc
    ret

; ====================================================================
; PWM & DISPLAY
; ====================================================================
; Update_PWM is now handled by pwm.inc - just call it after setting pwm variable

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
; STRINGS
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

END
