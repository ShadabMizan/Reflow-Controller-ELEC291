$MODMAX10
; Combined reflow controller with keypad input for parameter setting
; A = set soak time, B = set soak temp, C = set reflow time, D = set reflow temp
; * = backspace/clear, # = enter value

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

; Keypad input variables
input_mode:    ds 1      ; 0=normal, 1=soak time, 2=soak temp, 3=reflow time, 4=reflow temp
input_buffer:  ds 1      ; temporary storage for entered value
input_digits:  ds 1      ; count of digits entered

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
START_BUTTON    EQU P1.5      ; Start button (from main(2), active-low to GND)
ABORT_BUTTON    EQU P1.3

VREF_VALUE      EQU 4116

SPEAKER_PIN     EQU P3.6
BEEP_DURATION   EQU 200
BEEP_GAP        EQU 100
TIMER_RELOAD_H  EQU 0FEh
TIMER_RELOAD_L  EQU 03Eh

; Keypad pins
ROW1 EQU P1.2
ROW2 EQU P1.4
ROW3 EQU P1.6
ROW4 EQU P2.0
COL1 EQU P2.2
COL2 EQU P2.4
COL3 EQU P2.6
COL4 EQU P3.0

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
ELCD_RS equ P1.7
ELCD_E  equ P1.1
ELCD_D4 equ P0.7
ELCD_D5 equ P0.5
ELCD_D6 equ P0.3
ELCD_D7 equ P0.1
$NOLIST
$include(LCD_4bit_DE10Lite_no_RW.inc)
$include(pwm.inc)
$include(hex.inc)
$LIST

; Write R3 space characters (0x20) to LCD at current cursor position
?Write_Spaces_16:
?Write_Spaces_Loop:
	mov a, #20h
	lcall ?WriteData
	djnz r3, ?Write_Spaces_Loop
	ret

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

Wait25ms:
;33.33MHz, 1 clk per cycle: 0.03us
	mov R0, #15
Wait25ms_L3:
	mov R1, #74
Wait25ms_L2:
	mov R2, #250
Wait25ms_L1:
	djnz R2, Wait25ms_L1 ;3*250*0.03us=22.5us
    djnz R1, Wait25ms_L2 ;74*22.5us=1.665ms
    djnz R0, Wait25ms_L3 ;1.665ms*15=25ms
    ret

Initial_Message:  db 'Reflow Controller', 0

; ============================================================
; KEYPAD ROUTINES
; ============================================================

Configure_Keypad_Pins:
	; Configure the row pins as output and the column pins as inputs
	orl P1MOD, #0b_01010100 ; P1.6, P1.4, P1.2 output
	orl P2MOD, #0b_00000001 ; P2.0 output
	anl P2MOD, #0b_10101011 ; P2.6, P2.4, P2.2 input
	anl P3MOD, #0b_11111110 ; P3.0 input
	ret

CHECK_COLUMN MAC
	jb %0, CHECK_COL_%M
	mov R7, %1
	jnb %0, $ ; wait for key release
	setb c
	ret
CHECK_COL_%M:
ENDMAC

; Scan keypad and return key code in R7 if pressed (carry set)
Keypad_Scan:
	; Make all the rows zero.  If any column is zero then a key is pressed.
	clr ROW1
	clr ROW2
	clr ROW3
	clr ROW4
	mov c, COL1
	anl c, COL2
	anl c, COL3
	anl c, COL4
	jnc Keypad_Scan_Debounce
	clr c
	ret
		
Keypad_Scan_Debounce:
	; A key maybe pressed.  Wait and check again to discard bounces.
	lcall Wait25ms ; debounce
	mov c, COL1
	anl c, COL2
	anl c, COL3
	anl c, COL4
	jnc Keypad_Scan_Key_Code
	clr c
	ret
	
Keypad_Scan_Key_Code:	
	; A key is pressed.  Find out which one by checking each possible column and row combination.

	setb ROW1
	setb ROW2
	setb ROW3
	setb ROW4
	
	; Standard keypad layout (not rotated)
	; Check row 1	
	clr ROW1
	CHECK_COLUMN(COL1, #01H)
	CHECK_COLUMN(COL2, #02H)
	CHECK_COLUMN(COL3, #03H)
	CHECK_COLUMN(COL4, #0AH)  ; A
	setb ROW1

	; Check row 2	
	clr ROW2
	CHECK_COLUMN(COL1, #04H)
	CHECK_COLUMN(COL2, #05H)
	CHECK_COLUMN(COL3, #06H)
	CHECK_COLUMN(COL4, #0BH)  ; B
	setb ROW2

	; Check row 3	
	clr ROW3
	CHECK_COLUMN(COL1, #07H)
	CHECK_COLUMN(COL2, #08H)
	CHECK_COLUMN(COL3, #09H)
	CHECK_COLUMN(COL4, #0CH)  ; C
	setb ROW3

	; Check row 4	
	clr ROW4
	CHECK_COLUMN(COL1, #0EH)  ; *
	CHECK_COLUMN(COL2, #00H)  ; 0
	CHECK_COLUMN(COL3, #0FH)  ; #
	CHECK_COLUMN(COL4, #0DH)  ; D
	setb ROW4

	clr c
	ret

; Process keypad input based on current mode
Process_Keypad_Input:
    lcall Keypad_Scan
    jnc Process_Keypad_Done  ; no key pressed

    ; Key pressed, R7 has key code
    mov a, input_mode
    jz Check_Mode_Keys       ; if in normal mode, check for A/B/C/D

    ; We're in an input mode (1-4), process digit/*/# 
    mov a, R7
    
    ; Check for # (enter - 0x0F)
    cjne a, #0FH, Check_Asterisk
    lcall Enter_Value
    sjmp Process_Keypad_Done

Check_Asterisk:
    ; Check for * (backspace - 0x0E)
    cjne a, #0EH, Check_Digit
    lcall Clear_Input
    sjmp Process_Keypad_Done

Check_Digit:
    ; Check if it's a digit (0-9)
    mov a, R7
    cjne a, #0AH, Process_Digit  ; if >= 0x0A, it's A/B/C/D
    sjmp Process_Keypad_Done     ; ignore A/B/C/D while in input mode
    
Process_Digit:
    mov a, R7
    cjne a, #0AH, Add_Digit_To_Buffer
    sjmp Process_Keypad_Done

Add_Digit_To_Buffer:
    ; Limit to 3 digits
    mov a, input_digits
    cjne a, #3, Add_Digit_OK
    sjmp Process_Keypad_Done
    
Add_Digit_OK:
    ; Multiply current buffer by 10 and add new digit
    mov a, input_buffer
    mov b, #10
    mul ab
    add a, R7
    mov input_buffer, a
    
    ; Increment digit count
    inc input_digits
    
    ; Update display
    lcall Update_Input_Display
    sjmp Process_Keypad_Done

Check_Mode_Keys:
    ; Check for A/B/C/D to enter input modes
    mov a, R7
    
    cjne a, #0AH, Check_Key_B
    ; A pressed - soak time
    mov input_mode, #1
    lcall Init_Input_Mode
    sjmp Process_Keypad_Done
    
Check_Key_B:
    cjne a, #0BH, Check_Key_C
    ; B pressed - soak temp
    mov input_mode, #2
    lcall Init_Input_Mode
    sjmp Process_Keypad_Done
    
Check_Key_C:
    cjne a, #0CH, Check_Key_D
    ; C pressed - reflow time
    mov input_mode, #3
    lcall Init_Input_Mode
    sjmp Process_Keypad_Done
    
Check_Key_D:
    cjne a, #0DH, Process_Keypad_Done
    ; D pressed - reflow temp
    mov input_mode, #4
    lcall Init_Input_Mode

Process_Keypad_Done:
    ret

; Initialize input mode - clear buffer and update display
Init_Input_Mode:
    mov input_buffer, #0
    mov input_digits, #0
    lcall Update_Input_Display
    ret

; Clear input buffer (backspace)
Clear_Input:
    mov a, input_digits
    jz Clear_Input_Done
    
    ; If we have digits, remove last one
    mov a, input_buffer
    mov b, #10
    div ab
    mov input_buffer, a
    dec input_digits
    
    lcall Update_Input_Display
Clear_Input_Done:
    ret

; Enter the value and exit input mode
Enter_Value:
    mov a, input_mode
    
    cjne a, #1, Check_Mode2
    ; Mode 1: soak time
    mov a, input_buffer
    mov soaktime, a
    sjmp Exit_Input_Mode
    
Check_Mode2:
    cjne a, #2, Check_Mode3
    ; Mode 2: soak temp
    mov a, input_buffer
    mov soaktmp, a
    sjmp Exit_Input_Mode
    
Check_Mode3:
    cjne a, #3, Check_Mode4
    ; Mode 3: reflow time
    mov a, input_buffer
    mov reflowtime, a
    sjmp Exit_Input_Mode
    
Check_Mode4:
    cjne a, #4, Exit_Input_Mode
    ; Mode 4: reflow temp
    mov a, input_buffer
    mov reflowtmp, a

Exit_Input_Mode:
    mov input_mode, #0
    ; Force LCD update on next cycle
    ret

; Update LCD display during input mode
Update_Input_Display:
    push acc
    push b
    
    ; Clear row 1 and show prompt
    mov a, #80h
    lcall ?WriteCommand
    
    mov a, input_mode
    cjne a, #1, Input_Disp_Mode2
    ; Soak time
    mov a, #'S'
    lcall ?WriteData
    mov a, #'o'
    lcall ?WriteData
    mov a, #'a'
    lcall ?WriteData
    mov a, #'k'
    lcall ?WriteData
    mov a, #' '
    lcall ?WriteData
    mov a, #'T'
    lcall ?WriteData
    mov a, #'i'
    lcall ?WriteData
    mov a, #'m'
    lcall ?WriteData
    mov a, #'e'
    lcall ?WriteData
    mov a, #':'
    lcall ?WriteData
    sjmp Input_Disp_Value
    
Input_Disp_Mode2:
    cjne a, #2, Input_Disp_Mode3
    ; Soak temp
    mov a, #'S'
    lcall ?WriteData
    mov a, #'o'
    lcall ?WriteData
    mov a, #'a'
    lcall ?WriteData
    mov a, #'k'
    lcall ?WriteData
    mov a, #' '
    lcall ?WriteData
    mov a, #'T'
    lcall ?WriteData
    mov a, #'e'
    lcall ?WriteData
    mov a, #'m'
    lcall ?WriteData
    mov a, #'p'
    lcall ?WriteData
    mov a, #':'
    lcall ?WriteData
    sjmp Input_Disp_Value
    
Input_Disp_Mode3:
    cjne a, #3, Input_Disp_Mode4
    ; Reflow time
    mov a, #'R'
    lcall ?WriteData
    mov a, #'e'
    lcall ?WriteData
    mov a, #'f'
    lcall ?WriteData
    mov a, #'l'
    lcall ?WriteData
    mov a, #'o'
    lcall ?WriteData
    mov a, #'w'
    lcall ?WriteData
    mov a, #' '
    lcall ?WriteData
    mov a, #'T'
    lcall ?WriteData
    mov a, #'i'
    lcall ?WriteData
    mov a, #'m'
    lcall ?WriteData
    mov a, #'e'
    lcall ?WriteData
    mov a, #':'
    lcall ?WriteData
    sjmp Input_Disp_Value
    
Input_Disp_Mode4:
    ; Reflow temp
    mov a, #'R'
    lcall ?WriteData
    mov a, #'e'
    lcall ?WriteData
    mov a, #'f'
    lcall ?WriteData
    mov a, #'l'
    lcall ?WriteData
    mov a, #'o'
    lcall ?WriteData
    mov a, #'w'
    lcall ?WriteData
    mov a, #' '
    lcall ?WriteData
    mov a, #'T'
    lcall ?WriteData
    mov a, #'e'
    lcall ?WriteData
    mov a, #'m'
    lcall ?WriteData
    mov a, #'p'
    lcall ?WriteData
    mov a, #':'
    lcall ?WriteData

Input_Disp_Value:
    ; Display the current input buffer value (up to 3 digits)
    mov a, input_buffer
    mov b, #100
    div ab
    mov r1, a         ; hundreds
    mov a, b
    mov b, #10
    div ab
    mov r2, a         ; tens
    ; b has ones
    
    ; Display hundreds (space if 0)
    mov a, r1
    jz Input_Disp_Hund_Space
    add a, #'0'
    sjmp Input_Disp_Hund_Out
Input_Disp_Hund_Space:
    mov a, #' '
Input_Disp_Hund_Out:
    lcall ?WriteData
    
    ; Display tens (space if both hundreds and tens are 0)
    mov a, r1
    jnz Input_Disp_Tens_Print
    mov a, r2
    jz Input_Disp_Tens_Space
Input_Disp_Tens_Print:
    mov a, r2
    add a, #'0'
    sjmp Input_Disp_Tens_Out
Input_Disp_Tens_Space:
    mov a, #' '
Input_Disp_Tens_Out:
    lcall ?WriteData
    
    ; Display ones (always)
    mov a, b
    add a, #'0'
    lcall ?WriteData
    
    pop b
    pop acc
    ret

; ============================================================
; END KEYPAD ROUTINES
; ============================================================

mycode:
	mov SP, #0x7F
	clr a
	mov LEDRA, a
	mov LEDRB, a
	
	lcall InitSerialPort
    lcall Timer2_Init
    lcall Configure_Keypad_Pins

    ; Initial PWM output
    mov P3MOD, #11000000b   ; P3.7, P3.6
    lcall Init_Speaker

    mov ADC_C, #0x80 ; Reset ADC
	lcall Wait50ms

    clr a
    mov pwm_tick_counter, a
    mov pwm_on_ticks, a

	; LCD: set port state first, then MOD, then long power-on delay
	clr a
	mov P0, a
	mov P1, a
	mov P0MOD, #10101010b ; P0.1, P0.3, P0.5, P0.7 = outputs
	mov P1MOD, #10000010b ; P1.7 (RS), P1.1 (E) = outputs
	; Give LCD time to power up before any init (many need 100–300 ms)
	Wait_Milli_Seconds(#200)

	; Configure LCD in 4-bit mode
	lcall ELCD_4BIT
	; Extra delay after init before first use
	Wait_Milli_Seconds(#50)
	; Clear display and return home so no leftover garbage
	WriteCommand(#0x01)
	Wait_Milli_Seconds(#10)
	WriteCommand(#0x02)   ; Return home (cursor to 0x00)
	Wait_Milli_Seconds(#5)
	; Fill row 1 with spaces so old DD RAM doesn't show as 0/?
	mov a, #80h
	lcall ?WriteCommand
	mov r3, #16
	lcall ?Write_Spaces_16
	; Row 2
	mov a, #0C0h
	lcall ?WriteCommand
	mov r3, #16
	lcall ?Write_Spaces_16
	; Now write test text at start of each row
	mov a, #80h
	lcall ?WriteCommand
	mov a, #'R'
	lcall ?WriteData
	mov a, #'1'
	lcall ?WriteData
	mov a, #0C0h
	lcall ?WriteCommand
	mov a, #'T'
	lcall ?WriteData
	mov a, #'2'
	lcall ?WriteData
	Wait_Milli_Seconds(#250)

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

    ; Initialize parameters
    mov soaktime, #60
    mov soaktmp, #150
    mov reflowtime, #45
    mov reflowtmp, #220

    ; Initialize input mode
    mov input_mode, #0
    mov input_buffer, #0
    mov input_digits, #0

    ; Initialize total elapsed time and LCD state
    mov total_time_lo, #0
    mov total_time_hi, #0
    mov lcd_screen,   #0
    clr timer_running
    clr heat_error_flag

    ; Give LCD time to stabilize before first update
    Wait_Milli_Seconds(#250)

    lcall Wait50ms

forever:
    ; Check keypad input
    lcall Process_Keypad_Input

    ; Only run normal operations if not in input mode
    mov a, input_mode
    jnz Skip_Normal_Operation

    lcall Read_Temperature_Simple

    jb ABORT_BUTTON, Jumpshort
    lcall Wait50ms
    jb ABORT_BUTTON, Jumpshort
    jnb ABORT_BUTTON, $
    mov fsm_state, #0

Jumpshort:
    lcall FSM_Reflow

    ; Once per second: toggle which status screen is shown on row 1
    jnb seconds_flag, After_Second_Tasks
    clr seconds_flag
    mov a, lcd_screen
    jz Set_Screen1
    mov lcd_screen, #0
    sjmp After_Second_Tasks
Set_Screen1:
    mov lcd_screen, #1
After_Second_Tasks:

    ; Update LCD every loop (unless in input mode)
    lcall Update_LCD_Status

Skip_Normal_Operation:
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

    ; ---------------- Row 1: DDRAM 0x80 (first line) = status
    mov a, #80h
    lcall ?WriteCommand
Row1_Normal:
    ; Screen A: "R xxxC S xxxC #x"  or  Screen B: "R xxxs S xxxs #x"
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

Row1_Done:
    ; ---------------- Row 2: DDRAM 0xC0 (second line) = temp + seconds
    mov a, #0C0h
    lcall ?WriteCommand
    mov a, #'T'
    lcall ?WriteData
    mov a, #' '
    lcall ?WriteData
    mov a, bcd+2
    swap a
    anl a, #0x0F
    jz R2_HundSp
    add a, #'0'
    sjmp R2_HundOut
R2_HundSp:
    mov a, #' '
R2_HundOut:
    lcall ?WriteData
    mov a, bcd+2
    anl a, #0x0F
    add a, #'0'
    lcall ?WriteData
    mov a, bcd+1
    swap a
    anl a, #0x0F
    add a, #'0'
    lcall ?WriteData
    mov a, #'.'
    lcall ?WriteData
    mov a, bcd+1
    anl a, #0x0F
    add a, #'0'
    lcall ?WriteData
    mov a, #' '
    lcall ?WriteData
    lcall Print_4Digit_From_RAM16
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

    ; Thousands (1000s)
P4_Thou_Loop:
    mov a, time_tmp_lo
    clr c
    subb a, #0E8h
    mov b, a
    mov a, time_tmp_hi
    subb a, #03h
    jc P4_Thou_Done

    mov time_tmp_lo, b
    mov time_tmp_hi, a
    mov a, time_thou
    inc a
    mov time_thou, a
    sjmp P4_Thou_Loop

P4_Thou_Done:

    ; Hundreds (100s)
P4_Hund_Loop:
    mov a, time_tmp_lo
    clr c
    subb a, #064h
    mov b, a
    mov a, time_tmp_hi
    subb a, #00h
    jc P4_Hund_Done

    mov time_tmp_lo, b
    mov time_tmp_hi, a
    mov a, time_hund
    inc a
    mov time_hund, a
    sjmp P4_Hund_Loop

P4_Hund_Done:

    ; Tens (10s)
P4_Tens_Loop:
    mov a, time_tmp_lo
    clr c
    subb a, #0Ah
    mov b, a
    mov a, time_tmp_hi
    subb a, #00h
    jc P4_Tens_Done

    mov time_tmp_lo, b
    mov time_tmp_hi, a
    mov a, time_tens
    inc a
    mov time_tens, a
    sjmp P4_Tens_Loop

P4_Tens_Done:

    mov a, time_tmp_lo
    mov time_ones, a

    ; Print digits with leading spaces
    mov a, time_thou
    jz P4_Out_Thou_Space
    add a, #'0'
    sjmp P4_Out_Thou
P4_Out_Thou_Space:
    mov a, #' '
P4_Out_Thou:
    lcall ?WriteData

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
    lcall mul32

    ; Load Reference ADC 
    mov ADC_C, #0x00 
    lcall Wait5ms

    mov y+3, #0
	mov y+2, #0
	mov y+1, ADC_H
	mov y+0, ADC_L

    lcall div32

    Load_y(2730)
    lcall sub32 

    Load_y(10)
    lcall div32

    mov coldj_tmp+3, x+3
    mov coldj_tmp+2, x+2
    mov coldj_tmp+1, x+1
    mov coldj_tmp+0, x+0

    mov ADC_C, #0x02
    lcall Wait5ms

	mov x+3, #0
	mov x+2, #0
	mov x+1, ADC_H
	mov x+0, ADC_L

    Load_y(330)
    lcall mul32

    mov ADC_C, #0x00
    lcall Wait5ms

    mov y+3, #0
	mov y+2, #0
	mov y+1, ADC_H
	mov y+0, ADC_L
    lcall div32

    mov y+3, coldj_tmp+3
	mov y+2, coldj_tmp+2
	mov y+1, coldj_tmp+1
	mov y+0, coldj_tmp+0

    lcall add32

    Load_y(1000)
    lcall mul32
    
	lcall hex2bcd

    lcall Display_Temp_Serial

    lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
    ret

Read_Temperature_Simple:
    mov ADC_C, #0x02
    lcall Wait5ms
	
	mov x+3, #0
	mov x+2, #0
	mov x+1, ADC_H
	mov x+0, ADC_L
	
	Load_y(5000)
	lcall mul32
	Load_y(4096)
	lcall div32
	
    Load_y(1000)
    lcall mul32
    Load_y(12300)
    lcall div32

    Load_y(22)
    lcall add32

    mov current_tmp, x+0

    Load_y(1000)
    lcall mul32

    lcall hex2bcd
    lcall Display_Temp_Serial
    lcall Display_Voltage_7seg
    ret


Display_Voltage_7seg:
	
	mov dptr, #myLUT

    mov a, bcd+2
	swap a
	anl a, #0FH
	movc a, @a+dptr
	mov HEX5, a
	
	mov a, bcd+2
	anl a, #0FH
	movc a, @a+dptr
	mov HEX4, a

	mov a, bcd+1
	swap a
	anl a, #0FH
	movc a, @a+dptr
	anl a, #0x7f
	mov HEX3, a
	
	mov a, bcd+1
	anl a, #0FH
	movc a, @a+dptr
	mov HEX2, a

	mov a, bcd+0
	swap a
	anl a, #0FH
	movc a, @a+dptr
	mov HEX1, a
	
	mov a, bcd+0
	anl a, #0FH
	movc a, @a+dptr
	mov HEX0, a
	
	ret

Display_Temp_Serial:
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

myLUT:
    DB 0xC0, 0xF9, 0xA4, 0xB0, 0x99        ; 0 TO 4
    DB 0x92, 0x82, 0xF8, 0x80, 0x90        ; 4 TO 9
    DB 0x88, 0x83, 0xC6, 0xA1, 0x86, 0x8E  ; A to F

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
    jz FSM_State0
    jb START_BUTTON, FSM_Check_States
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

    mov total_time_lo, #0
    mov total_time_hi, #0
    mov lcd_screen,   #0
    setb timer_running
    clr heat_error_flag

    mov current_time, #0
    mov a, current_tmp
    mov state1_start_tmp, a

    mov pwm, #100
    lcall Update_PWM

    lcall Beep_Once

FSM_State0_Done:
    ljmp FSM_Done

FSM_State1:
    cjne a, #1, FSM_State2

    mov a, current_time
    cjne a, #60, FSM_State1_Check_Soak

    mov a, current_tmp
    clr c
    subb a, state1_start_tmp
    clr c
    subb a, #50
    jnc FSM_State1_Check_Soak
    lcall Heat_Incorrect_Error
    ljmp FSM_Done

FSM_State1_Check_Soak:
    mov a, soaktmp
    clr c
    subb a, current_tmp
    jnc FSM_State1_Done

    mov dptr, #FSM_STATE_MSG
    lcall SendString
    mov a, #'2'
    lcall putchar
    mov a, #'\r'
    lcall putchar
    mov a, #'\n'
    lcall putchar

    mov fsm_state, #2

    mov pwm, #20
    lcall Update_PWM

    lcall Beep_Once

FSM_State1_Done:
    ljmp FSM_Done

FSM_State2:
    cjne a, #2, FSM_State3

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

    mov pwm, #100
    lcall Update_PWM

    lcall Beep_Once

FSM_State2_Done:
    ljmp FSM_Done

FSM_State3:
    cjne a, #3, FSM_State4

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

    mov pwm, #20
    lcall Update_PWM

    lcall Beep_Once

FSM_State3_Done:
    ljmp FSM_Done

FSM_State4:
    cjne a, #4, FSM_State5
    
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

    mov pwm, #0
    lcall Update_PWM

    lcall Beep_Once

FSM_State4_Done:
    ljmp FSM_Done

FSM_State5:
    cjne a, #5, FSM_Done

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

    lcall Beep_Complete

    clr timer_running
FSM_State5_Done:
FSM_Done:
    pop PSW
    pop ACC
    ret

FSM_Abort_Stop:
    mov pwm, #0
    lcall Update_PWM
    mov fsm_state, #0
    clr timer_running
    sjmp FSM_Done

Heat_Incorrect_Error:
    mov pwm, #0
    lcall Update_PWM
    clr timer_running
    mov fsm_state, #0
    setb heat_error_flag

    WriteCommand(#0x01)
    Wait_Milli_Seconds(#2)
    Set_Cursor(1, 1)
    mov dptr, #Heat_Error_Msg
    lcall ?Send_Constant_String

    ret


; Beeper
Beep_Once:
    push ACC
    push PSW
    mov R7, #HIGH(BEEP_DURATION)
    mov R6, #LOW(BEEP_DURATION)
Beep_Once_Loop:
    lcall Toggle_Speaker_Tone
    dec R6
    cjne R6, #0FFh, Beep_Once_Continue
    dec R7
Beep_Once_Continue:
    mov A, R6
    orl A, R7
    jnz Beep_Once_Loop
    clr SPEAKER_PIN
    pop PSW
    pop ACC
    ret

Beep_State_Change:
    lcall Beep_Once
    ret

Beep_Complete:
    push ACC
    mov A, #5
Beep_Complete_Loop:
    push ACC
    lcall Beep_Once
    lcall Delay_Gap
    pop ACC
    dec A
    jnz Beep_Complete_Loop
    pop ACC
    ret

Beep_Error:
    push ACC
    mov A, #10
Beep_Error_Loop:
    push ACC
    lcall Beep_Once
    lcall Delay_Gap
    pop ACC
    dec A
    jnz Beep_Error_Loop
    pop ACC
    ret

Toggle_Speaker_Tone:
    push ACC
    setb SPEAKER_PIN
    lcall Delay_Half_Period
    clr SPEAKER_PIN
    lcall Delay_Half_Period
    pop ACC
    ret

Delay_Half_Period:
    push ACC
    clr TR0
    clr TF0
    mov TH0, #TIMER_RELOAD_H
    mov TL0, #TIMER_RELOAD_L
    setb TR0
Wait_Half_Period:
    jnb TF0, Wait_Half_Period
    clr TR0
    clr TF0
    pop ACC
    ret

Delay_Gap:
    push ACC
    push AR7
    push AR6
    mov R7, #HIGH(BEEP_GAP)
    mov R6, #LOW(BEEP_GAP)
Delay_Gap_Loop:
    lcall Delay_1ms
    dec R6
    cjne R6, #0FFh, Delay_Gap_Continue
    dec R7
Delay_Gap_Continue:
    mov A, R6
    orl A, R7
    jnz Delay_Gap_Loop
    pop AR6
    pop AR7
    pop ACC
    ret

Delay_1ms:
    push ACC
    push AR5
    mov R5, #184
Delay_1ms_Loop:
    nop
    nop
    nop
    djnz R5, Delay_1ms_Loop
    pop AR5
    pop ACC
    ret

Init_Speaker:
    clr SPEAKER_PIN
    anl TMOD, #0F0h
    orl TMOD, #01h
    clr TR0
    clr TF0
    ret

end
