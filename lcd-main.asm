	$MODMAX10

; The Special Function Registers below were added to 'MODMAX10' recently.
; If you are getting an error, uncomment the three lines below.

; ADC_C DATA 0xa1
; ADC_L DATA 0xa2
; ADC_H DATA 0xa3

org 0000h
    ljmp mycode

org 002Bh
    ljmp Timer2_ISR

dseg at 30h
; Math32 variables
x:		ds	4
y:		ds	4
bcd:	ds	5

; PWM variables
ticks_per_sec:    ds 2        ; Tick counter for seconds
pwm_tick_counter: ds 1
pwm_on_ticks:     ds 1
pwm:              ds 1    ; 0–100 (% duty cycle)

; Tmp variables
ref4040: ds 4
coldj_tmp: ds 4

; FSM Variables
fsm_state: ds 1

current_tmp: ds 1
current_time: ds 1

; Time and display state
total_time_lo: ds 1      ; total elapsed time in seconds (low byte)
total_time_hi: ds 1      ; total elapsed time in seconds (high byte)
lcd_screen:    ds 1      ; 0 or 1: which Row1 screen to show

; Helpers for time-to-decimal conversion
time_tmp_lo:   ds 1
time_tmp_hi:   ds 1
time_thou:     ds 1
time_hund:     ds 1
time_tens:     ds 1
time_ones:     ds 1

state1_start_tmp: ds 1   ; temperature at entry to state 1

soaktmp: ds 1
soaktime: ds 1

reflowtmp: ds 1
reflowtime: ds 1


bseg
; math32 bit
mf:		dbit 1

; PWM bit
seconds_flag: dbit 1
oven_enabled:     dbit 1      ; PWM state
timer_running:    dbit 1      ; total-time seconds are running
heat_error_flag:  dbit 1      ; 1 = show "HEAT INCORRECT" on row 1 until next start

CLK              EQU 33333333    ; DE10-Lite CV-8052 = 33.333 MHz
TIMER2_RATE      EQU 2048        ; 2048 Hz for a 488 u-sec period/per tick
TIMER2_RELOAD    EQU ((65536-(CLK/(12*TIMER2_RATE))))
PWM_PERIOD_TICKS EQU 20          ; 20 ticks = 9.77ms period = 102 Hz PWM

SSR_PIN         EQU P3.7
START_BUTTON    EQU P2.0      ; Start button on P2.0 (active-low to GND)

VREF_VALUE      EQU 4116


CSEG

InitSerialPort:
    mov TMOD, #20H        ; Timer1 mode 2
    mov TH1, #0F7H          ; 9600 baud @ 33.333MHz
    mov TL1, #0F7H
    setb TR1              ; Start Timer1
    mov SCON, #50H        ; Mode 1, REN enabled
    setb TI               ; Set TI so first transmit works
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

$include(math32.asm)

cseg
; These 'equ' must match the wiring between the DE10Lite board and the LCD!
; P0 is in connector JPIO.  Check "CV-8052 Soft Processor in the DE10Lite Board: Getting
; Started Guide" for the details.
ELCD_RS equ P1.7
; ELCD_RW equ Px.x ; Not used.  Connected to ground 
ELCD_E  equ P1.1
ELCD_D4 equ P0.7
ELCD_D5 equ P0.5
ELCD_D6 equ P0.3
ELCD_D7 equ P0.1
$NOLIST
$include(LCD_4bit_DE10Lite_no_RW.inc) ; A library of LCD related functions and utility macros
$include(pwm.inc)
$include(hex.inc)
$LIST

Wait50ms:
;33.33MHz, 1 clk per cycle: 0.03us
	mov R0, #30
Wait50ms_L3:
	mov R1, #74
Wait50ms_L2:
	mov R2, #250
Wait50ms_L1:
	djnz R2, Wait50ms_L1 ;3*250*0.03us=22.5us
    djnz R1, Wait50ms_L2 ;74*22.5us=1.665ms
    djnz R0, Wait50ms_L3 ;1.665ms*30=50ms
    ret

Initial_Message:  db 'Voltmeter test', 0

mycode:
	mov SP, #0x7F
	clr a
	mov LEDRA, a
	mov LEDRB, a
	
	lcall InitSerialPort
    lcall Timer2_Init
	
	; COnfigure the pins connected to the LCD as outputs
	mov P0MOD, #10101010b ; P0.1, P0.3, P0.5, P0.7 are outputs.  ('1' makes the pin output)
    mov P1MOD, #10000010b ; P1.7 and P1.1 are outputs

    ; Initial PWM output
    mov P3MOD, #10000000b   ; P3.7

    mov ADC_C, #0x80 ; Reset ADC
	lcall Wait50ms

    clr a
    mov pwm_tick_counter, a
    mov pwm_on_ticks, a

    ; Configure LCD in 4-bit mode
    lcall ELCD_4BIT
    
    setb EA              ; Enable global interrupts
    
    ; Set initial 0% and apply
    mov pwm, #0
    lcall Update_PWM        
	
	mov dptr, #Initial_Message
	lcall SendString
	mov a, #'\r'
	lcall putchar
	mov a, #'\n'
	lcall putchar

    ; Test UART
    mov a, #'T'
    lcall putchar
    mov a, #'E'
    lcall putchar
    mov a, #'S'
    lcall putchar
    mov a, #'T'
    lcall putchar
    mov a, #'\r'
    lcall putchar
    mov a, #'\n'
    lcall putchar
    
    mov pwm, #0
    lcall Update_PWM
    
    mov current_time, #0
    mov fsm_state, #0

    mov soaktime, #60
    mov soaktmp, #150

    mov reflowtime, #45
    mov reflowtmp, #220

    ; Initialize total elapsed time and LCD state
    mov total_time_lo, #0
    mov total_time_hi, #0
    mov lcd_screen,   #0
    clr timer_running

    lcall Wait50ms

forever:
    lcall Read_Temperature_Simple
    
    lcall FSM_Reflow

    ; Once-per-second tasks (time and LCD update)
    jb  seconds_flag, One_Second_Tasks
    sjmp After_Second_Tasks

One_Second_Tasks:
    clr seconds_flag

    ; total_time and current_time are incremented in Timer2_ISR (once per second)
Skip_Time_Increment:
    ; Toggle LCD Row1 screen (scroll between the two header screens)
    mov a, lcd_screen
    jz Set_Screen1
    mov lcd_screen, #0
    sjmp After_Screen_Toggle
Set_Screen1:
    mov lcd_screen, #1
After_Screen_Toggle:

    ; Update status information on LCD
    lcall Update_LCD_Status

After_Second_Tasks:

    lcall Wait50ms
	ljmp forever

;

Update_LCD_Status:
    ; When in heat-error state, screen already shows only "HEAT INCORRECT" - do not overwrite
    jnb heat_error_flag, Update_LCD_Status_Skip
    ljmp Update_LCD_Status_Done
Update_LCD_Status_Skip:
    push acc
    push b
    push ar0
    push ar1
    push ar2
    push ar3

    ; ---------------- Row 1
    Set_Cursor(1, 1)

Row1_Normal:
    ; Normal: scroll between two screens
    ; Screen A: "R xxxC S xxxC #x"  (temperatures)
    ; Screen B: "R xxxs S xxxs #x"  (times in seconds)
    mov a, lcd_screen
    jz Row1_ScreenA        ; 0 = temps, 1 = times

Row1_ScreenB:
    ; "R xxxs S xxxs #x"  (reflow & soak times in seconds)
    ; 'R '
    mov a, #'R'
    lcall ?WriteData
    mov a, #' '
    lcall ?WriteData

    ; Reflow time: 3-digit seconds
    mov r0, #reflowtime
    lcall Print_3Digit_From_RAM

    ; 's '
    mov a, #'s'
    lcall ?WriteData
    mov a, #' '
    lcall ?WriteData

    ; 'S '
    mov a, #'S'
    lcall ?WriteData
    mov a, #' '
    lcall ?WriteData

    ; Soak time: 3-digit seconds
    mov r0, #soaktime
    lcall Print_3Digit_From_RAM

    ; 's '
    mov a, #'s'
    lcall ?WriteData
    mov a, #' '
    lcall ?WriteData

    ; '#x' (state number)
    mov a, #'#'
    lcall ?WriteData
    mov a, fsm_state
    add a, #'0'
    lcall ?WriteData

    sjmp Row1_Done

Row1_ScreenA:
    ; "R xxxC S xxxC #x"  (reflow & soak temperatures)
    ; 'R '
    mov a, #'R'
    lcall ?WriteData
    mov a, #' '
    lcall ?WriteData

    ; Reflow temperature: 3 digits and 'C'
    mov r0, #reflowtmp
    lcall Print_3Digit_From_RAM
    mov a, #'C'
    lcall ?WriteData

    ; Space
    mov a, #' '
    lcall ?WriteData

    ; 'S '
    mov a, #'S'
    lcall ?WriteData
    mov a, #' '
    lcall ?WriteData

    ; Soak temperature: 3 digits and 'C'
    mov r0, #soaktmp
    lcall Print_3Digit_From_RAM
    mov a, #'C'
    lcall ?WriteData

    ; Space
    mov a, #' '
    lcall ?WriteData

    ; '#x' (state number)
    mov a, #'#'
    lcall ?WriteData
    mov a, fsm_state
    add a, #'0'
    lcall ?WriteData

    sjmp Row1_Done

Row1_Done:

    ; ---------------- Row 2: "T xxx.x xxxx sec"
    Set_Cursor(2, 1)

    ; 'T '
    mov a, #'T'
    lcall ?WriteData
    mov a, #' '
    lcall ?WriteData

    ; Current temperature from BCD: xxx.x
    ; Hundreds digit (bcd+1 upper nibble)
    mov a, bcd+1
    swap a
    anl a, #0x0F
    jz Temp2_Hund_Space
    add a, #'0'
    sjmp Temp2_Hund_Out
Temp2_Hund_Space:
    mov a, #' '
Temp2_Hund_Out:
    lcall ?WriteData

    ; Tens digit (bcd+1 lower nibble)
    mov a, bcd+1
    anl a, #0x0F
    add a, #'0'
    lcall ?WriteData

    ; Ones digit (bcd+0 upper nibble)
    mov a, bcd+0
    swap a
    anl a, #0x0F
    add a, #'0'
    lcall ?WriteData

    ; Decimal point '.'
    mov a, #'.'
    lcall ?WriteData

    ; Tenths digit (bcd+0 lower nibble)
    mov a, bcd+0
    anl a, #0x0F
    add a, #'0'
    lcall ?WriteData

    ; Space
    mov a, #' '
    lcall ?WriteData

    ; Total elapsed seconds as 4 digits (0-2000) from total_time_lo/hi
    lcall Print_4Digit_From_RAM16

    ; ' sec'
    mov a, #' '
    lcall ?WriteData
    mov a, #'s'
    lcall ?WriteData
    mov a, #'e'
    lcall ?WriteData
    mov a, #'c'
    lcall ?WriteData

    pop ar3
    pop ar2
    pop ar1
    pop ar0
    pop b
    pop acc
Update_LCD_Status_Done:
    ret

; Print 3-digit unsigned value from RAM (address in R0)
; Output: hundreds, tens, ones (with leading spaces for unused higher digits)
Print_3Digit_From_RAM:
    push acc
    push b
    push ar1
    push ar2

    mov a, @r0          ; value 0-255
    mov b, #100
    div ab              ; A = hundreds, B = remainder
    mov r1, a           ; hundreds
    mov a, b
    mov b, #10
    div ab              ; A = tens, B = ones
    mov r2, a           ; tens
    ; B = ones

    ; Hundreds digit: space if zero, otherwise '0'+digit
    mov a, r1
    jz P3_Hund_Space
    add a, #'0'
    sjmp P3_Hund_Out
P3_Hund_Space:
    mov a, #' '
P3_Hund_Out:
    lcall ?WriteData

    ; Tens digit: space if both hundreds and tens are zero
    mov a, r1
    jnz P3_Tens_Print
    mov a, r2
    jz P3_Tens_Space
P3_Tens_Print:
    mov a, r2
    add a, #'0'
    sjmp P3_Tens_Out
P3_Tens_Space:
    mov a, #' '
P3_Tens_Out:
    lcall ?WriteData

    ; Ones digit: always printed
    mov a, b
    add a, #'0'
    lcall ?WriteData

    pop ar2
    pop ar1
    pop b
    pop acc
    ret

; Print 4-character seconds field from 16-bit total_time_hi:total_time_lo
; Simple 16-bit to decimal conversion (0..2000), right-justified with spaces.
Print_4Digit_From_RAM16:
    push acc
    push b

    ; Initialize temporary copy of total_time
    mov a, total_time_lo
    mov time_tmp_lo, a
    mov a, total_time_hi
    mov time_tmp_hi, a

    ; Clear digit counters
    mov time_thou, #0
    mov time_hund, #0
    mov time_tens, #0
    mov time_ones, #0

    ; ---------------- Thousands (1000s)
P4_Thou_Loop:
    ; Try subtracting 1000 (0x03E8)
    mov a, time_tmp_lo
    clr c
    subb a, #0E8h
    mov b, a              ; temp low
    mov a, time_tmp_hi
    subb a, #03h
    jc P4_Thou_Done       ; if borrow, value < 1000

    ; Commit subtraction and increment thousands
    mov time_tmp_lo, b
    mov time_tmp_hi, a
    mov a, time_thou
    inc a
    mov time_thou, a
    sjmp P4_Thou_Loop

P4_Thou_Done:

    ; ---------------- Hundreds (100s)
P4_Hund_Loop:
    ; Try subtracting 100 (0x0064)
    mov a, time_tmp_lo
    clr c
    subb a, #064h
    mov b, a              ; temp low
    mov a, time_tmp_hi
    subb a, #00h
    jc P4_Hund_Done       ; if borrow, value < 100

    ; Commit subtraction and increment hundreds
    mov time_tmp_lo, b
    mov time_tmp_hi, a
    mov a, time_hund
    inc a
    mov time_hund, a
    sjmp P4_Hund_Loop

P4_Hund_Done:

    ; ---------------- Tens (10s)
P4_Tens_Loop:
    ; Try subtracting 10 (0x000A)
    mov a, time_tmp_lo
    clr c
    subb a, #0Ah
    mov b, a              ; temp low
    mov a, time_tmp_hi
    subb a, #00h
    jc P4_Tens_Done       ; if borrow, value < 10

    ; Commit subtraction and increment tens
    mov time_tmp_lo, b
    mov time_tmp_hi, a
    mov a, time_tens
    inc a
    mov time_tens, a
    sjmp P4_Tens_Loop

P4_Tens_Done:

    ; Remaining low byte is ones (0-9)
    mov a, time_tmp_lo
    mov time_ones, a

    ; Now print digits with leading spaces
    ; Thousands (space if zero)
    mov a, time_thou
    jz P4_Out_Thou_Space
    add a, #'0'
    sjmp P4_Out_Thou
P4_Out_Thou_Space:
    mov a, #' '
P4_Out_Thou:
    lcall ?WriteData

    ; Hundreds (space if thousands and hundreds are zero)
    mov a, time_thou
    jnz P4_Out_Hund_Print
    mov a, time_hund
    jz P4_Out_Hund_Space
P4_Out_Hund_Print:
    mov a, time_hund
    add a, #'0'
    sjmp P4_Out_Hund
P4_Out_Hund_Space:
    mov a, #' '
P4_Out_Hund:
    lcall ?WriteData

    ; Tens (space if thousands, hundreds, tens are zero)
    mov a, time_thou
    jnz P4_Out_Tens_Print
    mov a, time_hund
    jnz P4_Out_Tens_Print
    mov a, time_tens
    jz P4_Out_Tens_Space
P4_Out_Tens_Print:
    mov a, time_tens
    add a, #'0'
    sjmp P4_Out_Tens
P4_Out_Tens_Space:
    mov a, #' '
P4_Out_Tens:
    lcall ?WriteData

    ; Ones (always printed)
    mov a, time_ones
    add a, #'0'
    lcall ?WriteData

    pop b
    pop acc
    ret

; ----------------------------------------
; TEMPERATURE ROUTINES
; ----------------------------------------
Read_Temperature:    
    ; Load LM335 ADC
    mov ADC_C, #0x01
    lcall Wait5ms

	mov x+3, #0
	mov x+2, #0
	mov x+1, ADC_H
	mov x+0, ADC_L

    Load_y(VREF_VALUE)
    lcall mul32     ; x = VREF * ADCLM335

    ; Load Reference ADC 
    mov ADC_C, #0x00 
    lcall Wait5ms

    mov y+3, #0
	mov y+2, #0
	mov y+1, ADC_H
	mov y+0, ADC_L

    lcall div32
    ; x = (VREF(mV) * ADCLM335)/ADCREF = VLM335 (mV)

    Load_y(2730)
    lcall sub32 
    ; x = (VLM335 - 2730mV)

    Load_y(10)
    lcall div32
    ; x = (VLM335 -2730mV)/(10mV/C)

    mov coldj_tmp+3, x+3
    mov coldj_tmp+2, x+2
    mov coldj_tmp+1, x+1
    mov coldj_tmp+0, x+0

    ; coldj_tmp = TC

    mov ADC_C, #0x02
    lcall Wait5ms

	mov x+3, #0
	mov x+2, #0
	mov x+1, ADC_H
	mov x+0, ADC_L

    Load_y(330) ; (4096mV)/(0.041mV) * (1/303)
    lcall mul32
    ; x = (4096mV/0.041mV)*(1/303)*ADCOp

    mov ADC_C, #0x00
    lcall Wait5ms

    mov y+3, #0
	mov y+2, #0
	mov y+1, ADC_H
	mov y+0, ADC_L
    lcall div32
    ; x = ((4096mV/0.041mV)*(1/303)*ADCOp)/ADCref

    ; x = TH

    mov y+3, coldj_tmp+3
	mov y+2, coldj_tmp+2
	mov y+1, coldj_tmp+1
	mov y+0, coldj_tmp+0
    ; y = TC

    lcall add32
    ; x = TH + TC

    Load_y(1000)
    lcall mul32
    
	lcall hex2bcd

    lcall Display_Temp_Serial ;sending this ts to the serial port

    lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
    ret

Read_Temperature_Simple:
    mov ADC_C, #0x02
    lcall Wait5ms
	
	; Load 32-bit 'x' with 12-bit adc result
	mov x+3, #0
	mov x+2, #0
	mov x+1, ADC_H
	mov x+0, ADC_L
	
	; Convert to voltage by multiplying by 5.000 and dividing by 4096
	Load_y(5000)
	lcall mul32
	Load_y(4096)
	lcall div32
	
    Load_y(1000) ; convert to microvolts
    lcall mul32
    Load_y(12300) ; 41 * 300
    lcall div32

    Load_y(22) ; add cold junction temperature
    lcall add32

    mov current_tmp, x+0

    ; Scale to tenths of a degree for BCD (temp * 10)
    Load_y(10)
    lcall mul32

    lcall hex2bcd
    ; lcall Display_Temp_Serial
    ; Display temperature on HEX using BCD (xxx.xC)
    lcall Display_BCD_HEX
    ret


Display_Temp_Serial:
	; mov a, #'T'
	; lcall putchar
	; mov a, #'='
	; lcall putchar
	
	mov a, bcd+3
	swap a
	anl a, #0FH
	orl a, #'0'
	lcall putchar
	
	mov a, bcd+3
	anl a, #0FH
	orl a, #'0'
	lcall putchar

	mov a, bcd+2
	swap a
	anl a, #0FH
	orl a, #'0'
	lcall putchar
	
	mov a, bcd+2
	anl a, #0FH
	orl a, #'0'
	lcall putchar

	mov a, bcd+1
	swap a
	anl a, #0FH
	orl a, #'0'
	lcall putchar
	
	mov a, #'.'
	lcall putchar
	
	mov a, bcd+1
	anl a, #0FH
	orl a, #'0'
	lcall putchar

	mov a, bcd+0
	swap a
	anl a, #0FH
	orl a, #'0'
	lcall putchar
	
	mov a, bcd+0
	anl a, #0FH
	orl a, #'0'
	lcall putchar

	mov a, #'\r'
	lcall putchar
	mov a, #'\n'
	lcall putchar
	
	ret

Wait5ms:
    push acc
    mov R2, #25
Wait5ms_L1:
    lcall Wait200us
    djnz R2, Wait5ms_L1
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

; ====================================================================
; FSM
; ====================================================================
FSM_STATE_MSG:
    DB 'FSM State: ', 0

Heat_Error_Msg:
    DB 'HEAT INCORRECT', 0


FSM_Reflow:
    push ACC
    push PSW

    mov a, fsm_state
    ; If we are in any active state (1-5) and the button is pressed,
    ; abort reflow and stop the overall timer.
    jz FSM_State0
    jb START_BUTTON, FSM_Check_States   ; not pressed (high) -> normal FSM
    ljmp FSM_Abort_Stop

FSM_Check_States:
FSM_State0:
    cjne a, #0, FSM_State1
    mov pwm, #0
    lcall Update_PWM

    jb START_BUTTON, FSM_State0_Done
    lcall Wait50ms
    jb START_BUTTON, FSM_State0_Done
    jnb START_BUTTON, $
    
    mov dptr, #FSM_STATE_MSG
    lcall SendString
    mov a, #'1'
    lcall putchar
    mov a, #'\r'
    lcall putchar
    mov a, #'\n'
    lcall putchar

    mov fsm_state, #1

    ; Start overall timer when entering state 1
    mov total_time_lo, #0
    mov total_time_hi, #0
    mov lcd_screen,   #0
    setb timer_running
    clr heat_error_flag       ; clear any previous heat error

    ; Reset per-state timer and record starting temperature for heat check
    mov current_time, #0
    mov a, current_tmp
    mov state1_start_tmp, a

    ; mov a, temp
    ; mov temp_state_start, a
    ; mov temp_max_state, a
    ; mov temp_previous, a
    ; mov undertemp_checked, #0
FSM_State0_Done:
    ljmp FSM_Done

FSM_State1:
    cjne a, #1, FSM_State2
    mov pwm, #100
    lcall Update_PWM

    ; First: 60-second heat check (must have +50C rise by 60 sec)
    mov a, current_time
    cjne a, #60, FSM_State1_Check_Soak
    ; At 60 sec: check if we gained at least 50C since start of state 1
    mov a, current_tmp
    clr c
    subb a, state1_start_tmp
    clr c
    subb a, #50
    jnc FSM_State1_Check_Soak   ; delta >= 50 -> OK, continue
    ; Not enough heating -> error
    lcall Heat_Incorrect_Error
    ljmp FSM_Done

FSM_State1_Check_Soak:
    ; Reached soak temperature? (soaktmp value, not address)
    mov a, soaktmp
    clr c
    subb a, current_tmp
    jnc FSM_State1_Done         ; current_tmp < soaktmp -> stay in state 1

    mov dptr, #FSM_STATE_MSG
    lcall SendString
    mov a, #'2'
    lcall putchar
    mov a, #'\r'
    lcall putchar
    mov a, #'\n'
    lcall putchar

    mov fsm_state, #2

    ; jc Check_Temp_Drop
    ; mov a, temp
    ; mov temp_max_state, a
; Check_Temp_Drop:
;     mov a, temp_max_state
;     clr c
;     subb a, temp
;     clr c
;     subb a, #TEMP_DROP_THRESHOLD
;     jc Check_Door_Open
;     mov error_code, #ERR_TEMP_DROP
;     ljmp Handle_Error
    
; Check_Door_Open:
;     mov a, temp_previous
;     clr c
;     subb a, temp
;     clr c
;     subb a, #20
;     jc Check_UnderTemp
;     mov error_code, #ERR_DOOR_OPEN
;     ljmp Handle_Error
    
; Check_UnderTemp:
;     mov a, undertemp_checked
;     jnz Check_Soak_Temp
;     mov a, state_timer
;     cjne a, #1, Check_Soak_Temp
;     mov undertemp_checked, #1
;     mov a, temp
;     clr c
;     subb a, #50
;     jnc Check_Soak_Temp
;     mov error_code, #ERR_UNDERTEMP
;     ljmp Handle_Error
    
; Check_Soak_Temp:
;     mov a, tempsoak
;     clr c
;     subb a, temp
;     jnc FSM_State1_Check_Timeout
;     mov FSM_state, #2
;     mov sec, #0
;     mov state_timer, #0
;     ljmp FSM_State1_Done
    
; FSM_State1_Check_Timeout:
;     mov a, state_timer
;     cjne a, #120, FSM_State1_Done
;     mov error_code, #ERR_TIMEOUT
;     ljmp Handle_Error

FSM_State1_Done:
    ljmp FSM_Done

FSM_State2:
    cjne a, #2, FSM_State3
    mov pwm, #20
    lcall Update_PWM

    mov a, soaktime
    clr c

    subb a, current_time
    jnc FSM_State2_Done

    mov dptr, #FSM_STATE_MSG
    lcall SendString
    mov a, #'3'
    lcall putchar
    mov a, #'\r'
    lcall putchar
    mov a, #'\n'
    lcall putchar

    mov FSM_state, #3

    ; mov sec, #0
    ; mov state_timer, #0
    ; mov a, temp
    ; mov temp_max_state, a
FSM_State2_Done:
    ljmp FSM_Done

FSM_State3:
    cjne a, #3, FSM_State4
    mov pwm, #100
    lcall Update_PWM

    mov current_time, #0
    
    mov a, reflowtmp
    clr c
    subb a, current_tmp

    jnc FSM_State3_Done

    mov dptr, #FSM_STATE_MSG
    lcall SendString
    mov a, #'4'
    lcall putchar
    mov a, #'\r'
    lcall putchar
    mov a, #'\n'
    lcall putchar

    mov fsm_state, #4

;     jc FSM_State3_Check_Reflow
;     mov a, temp
;     mov temp_max_state, a
    
; FSM_State3_Check_Reflow:
;     mov a, tempreflow
;     clr c
;     subb a, temp
;     jnc FSM_State3_Check_Timeout
;     mov FSM_state, #4
;     mov sec, #0
;     mov state_timer, #0
;     ljmp FSM_State3_Done
    
; FSM_State3_Check_Timeout:
;     mov a, state_timer
;     cjne a, #90, FSM_State3_Done
;     mov error_code, #ERR_TIMEOUT
;     ljmp Handle_Error
FSM_State3_Done:
    ljmp FSM_Done

FSM_State4:
    cjne a, #4, FSM_State5
    mov pwm, #20             ; ? Now actually 20% with real PWM!
    lcall Update_PWM
    
    mov a, reflowtime
    clr c
    subb a, current_time

    jnc FSM_State4_Done

    mov dptr, #FSM_STATE_MSG
    lcall SendString
    mov a, #'5'
    lcall putchar
    mov a, #'\r'
    lcall putchar
    mov a, #'\n'
    lcall putchar

    mov fsm_state, #5

; Temp_Too_High:
;     mov error_code, #ERR_OVERTEMP
;     ljmp Handle_Error
    
; Check_Reflow_Time:
;     mov a, timereflow
;     clr c
;     subb a, sec
;     jnc FSM_State4_Done
;     mov FSM_state, #5
;     mov sec, #0
FSM_State4_Done:
    ljmp FSM_Done

FSM_State5:
    cjne a, #5, FSM_Done
    mov pwm, #0
    lcall Update_PWM

    mov a, current_tmp
    clr c
    subb a, #60
    jnc FSM_State5_Done

    mov dptr, #FSM_STATE_MSG
    lcall SendString
    mov a, #'0'
    lcall putchar
    mov a, #'\r'
    lcall putchar
    mov a, #'\n'
    lcall putchar

    mov FSM_state, #0
    clr timer_running
FSM_State5_Done:
FSM_Done:
    ; mov a, temp
    ; mov temp_previous, a

    pop PSW
    pop ACC
    ret

; Abort reflow cycle when stop button is pressed during active states
FSM_Abort_Stop:
    mov pwm, #0
    lcall Update_PWM
    mov fsm_state, #0
    clr timer_running
    sjmp FSM_Done

; Handle insufficient heating error (heat incorrect)
Heat_Incorrect_Error:
    mov pwm, #0
    lcall Update_PWM
    clr timer_running
    mov fsm_state, #0
    setb heat_error_flag

    ; Clear LCD and print only the error message
    WriteCommand(#0x01)        ; clear display
    Wait_Milli_Seconds(#2)     ; wait for clear to finish
    Set_Cursor(1, 1)
    mov dptr, #Heat_Error_Msg
    lcall ?Send_Constant_String

    ret

end