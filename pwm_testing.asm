; pwm_testing.asm - pwm.inc Testing Program for DE10-Lite 

; 
; HARDWARE CONNECTION used for testing PWM (series resistor and LED) 
; JP2 Pin 36 (P3.7) ----[330 ohm]->        --->|---- JP2 Pin 30 (GND)
;                       Resistor     LED
; ================================================================

$NOLIST
$MODMAX10
$LIST

; CONFIGURATION CONSTANTS
CLK              EQU 33333333    ; DE10-Lite CV-8052 = 33.333 MHz
TIMER2_RATE      EQU 2048        ; 2048 Hz for a 488 u-sec period/per tick
TIMER2_RELOAD    EQU ((65536-(CLK/(12*TIMER2_RATE))))
PWM_PERIOD_TICKS EQU 20          ; 20 ticks = 9.77ms period = 102 Hz PWM

;****TIMER 2 initiation/ISR functions are also in pwm.inc

SSR_PIN          equ P3.7        ; PWM output pin

dseg at 0x30
    ; Timer variables
    ticks_per_sec:    ds 2        ; Tick counter for seconds
    
    ; PWM variables
    pwm_tick_counter: ds 1        ; PWM counter (0-19)
    pwm_on_ticks:     ds 1        ; ON time in ticks (CALCULATED VALUE)
    
    ; USER VARIABLES
    PWM:      ds 1        ; Input: Set this to 0-100
                                  ; Then call Update_PWM to apply
    
    ; Decimal conversion variables
    digit_100:    ds 1        ; Hundreds digit
    digit_10:     ds 1        ; Tens digit
    digit_1:      ds 1        ; Ones digit

bseg
    seconds_flag:     dbit 1      ; Set every second
    oven_enabled:     dbit 1      ; PWM state

cseg
org 0x0000
    ljmp main
org 0x002B
    ljmp Timer2_ISR


$NOLIST
$include(pwm.inc)
$LIST



; ================================================================
;                        TESTING HELPER FUNCTIONS:
; ================================================================

; DISPLAY DECIMAL ON 7-SEGMENT
; Look-up table for the 7-seg displays
T_7seg:
    DB 0xC0, 0xF9, 0xA4, 0xB0, 0x99        ; 0 TO 4
    DB 0x92, 0x82, 0xF8, 0x80, 0x90        ; 5 TO 9
    DB 0x88, 0x83, 0xC6, 0xA1, 0x86, 0x8E  ; A to F

; ================================================================
; Convert Binary to Decimal Digits
; Input: ACC contains binary value (0-100)
; Output: digit_100, digit_10, digit_1 contain decimal digits
; ================================================================
Binary_to_Decimal:
    push acc
    push b
    push psw
    
    ; Clear all digits
    mov digit_100, #0
    mov digit_10, #0
    mov digit_1, #0
    
    ; Extract hundreds digit (0 or 1 for values 0-100)
    mov b, #100
    div AB                    ; A = quotient (hundreds), B = remainder
    mov digit_100, a          ; Store hundreds digit (0 or 1)
    mov a, b                  ; Get remainder
    
    ; Extract tens digit
    mov b, #10
    div AB                    ; A = quotient (tens), B = remainder
    mov digit_10, a           ; Store tens digit
    mov digit_1, b            ; Store ones digit (remainder)
    
    pop psw
    pop b
    pop acc
    ret

; ================================================================
; Display Decimal Value on HEX2-HEX0
; Converts PWM value to decimal and displays on 7-segment displays
; ================================================================
Display_Decimal_7_Seg:
    push acc
    push DPL
    push DPH
    
    ; Convert PWM value to decimal digits
    mov a, pwm
    lcall Binary_to_Decimal
    
    mov dptr, #T_7seg
    
    ; Display hundreds digit on HEX2
    mov a, digit_100
    movc a, @a+dptr
    mov HEX2, a
    
    ; Display tens digit on HEX1
    mov a, digit_10
    movc a, @a+dptr
    mov HEX1, a
    
    ; Display ones digit on HEX0
    mov a, digit_1
    movc a, @a+dptr
    mov HEX0, a
    
    pop DPH
    pop DPL
    pop acc
    ret


; ================================================================
; WAIT SECONDS FUNCTION
; ================================================================
; Waits for R2 seconds using the seconds_flag
; Input: R2 = number of seconds to wait
; ================================================================
Wait_Seconds:
    push acc
Wait_Seconds_Loop:
    clr seconds_flag
Wait_Seconds_Check:
    jnb seconds_flag, Wait_Seconds_Check
    djnz R2, Wait_Seconds_Loop
    pop acc
    ret



; ================================================================
; MAIN PROGRAM - Initialization and Demo
; ================================================================
main:
    ; Initialize system
    mov SP, #0x7F
    mov P3MOD, #10000000b         ; P3.7 = output
    mov LEDRA, #0
    mov LEDRB, #0
    
    ; Initialize PWM variables
    clr a
    mov pwm_tick_counter, a
    mov pwm_on_ticks, a
    mov pwm, #0
    
    ; Start timer and enable interrupts
    lcall Timer2_Init
    setb EA
    
    ; Set initial 0% and apply
    mov pwm, #0
    lcall Update_PWM              

;demo

demo_loop:
    ; ============================================================
    ; Test 1: 30% for 5 seconds
    ; ============================================================
    mov pwm, #30          ; Set percentage
    lcall Update_PWM              ; Apply new duty cycle
    lcall Display_Decimal_7_Seg   ; Display on 7-segment
    mov R2, #5                    ; Wait 5 seconds
    lcall Wait_Seconds
    
    ; ============================================================
    ; Test 2: 90% for 5 seconds
    ; ============================================================
    mov pwm, #90              
    lcall Update_PWM              
    lcall Display_Decimal_7_Seg
    mov R2, #5
    lcall Wait_Seconds
    
    ; ============================================================
    ; Test 3: 10% for 3 seconds
    ; ============================================================
    mov pwm, #10
    lcall Update_PWM
    lcall Display_Decimal_7_Seg
    mov R2, #3
    lcall Wait_Seconds
    
    ; ============================================================
    ; Test 4: 50% for 3 seconds
    ; ============================================================
    mov pwm, #50
    lcall Update_PWM
    lcall Display_Decimal_7_Seg
    mov R2, #3
    lcall Wait_Seconds
    
    ; ============================================================
    ; Test 5: 75% for 3 seconds
    ; ============================================================
    mov pwm, #75
    lcall Update_PWM
    lcall Display_Decimal_7_Seg
    mov R2, #3
    lcall Wait_Seconds
    
    ; ============================================================
    ; Test 6: 0% (off) for 2 seconds
    ; ============================================================
    mov pwm, #0
    lcall Update_PWM
    lcall Display_Decimal_7_Seg
    mov R2, #2
    lcall Wait_Seconds
    
    ; ============================================================
    ; Test 7: 100% (full) for 3 seconds
    ; ============================================================
    mov pwm, #100
    lcall Update_PWM
    lcall Display_Decimal_7_Seg
    mov R2, #3
    lcall Wait_Seconds
    
    ; Repeat demo
    ljmp demo_loop

END
