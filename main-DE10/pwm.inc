; pwm.inc - PWM Library for CV-8052 on DE10-Lite
; configures Timer2

; Timer: 2048 Hz, PWM: 102 Hz (20 ticks/period)



; 
; TIMER 2 INITIALIZATION
 
Timer2_Init:
    mov T2CON, #0
    mov TH2, #high(TIMER2_RELOAD)
    mov TL2, #low(TIMER2_RELOAD)
    mov RCAP2H, #high(TIMER2_RELOAD)
    mov RCAP2L, #low(TIMER2_RELOAD)
    clr a
    mov ticks_per_sec+0, a
    mov ticks_per_sec+1, a
    setb ET2
    setb TR2
    ret

; TIMER 2 ISR - Called every 488 microseconds

Timer2_ISR:
    clr TF2
    push acc
    push psw
    
    ; Increment tick counter
    inc ticks_per_sec+0
    mov a, ticks_per_sec+0
    jnz T2_ISR_check_second
    inc ticks_per_sec+1

T2_ISR_check_second:
    ; Check if 1 second passed
    mov a, ticks_per_sec+0
    cjne a, #low(2048), T2_ISR_pwm
    mov a, ticks_per_sec+1
    cjne a, #high(2048), T2_ISR_pwm
    
    ; 1 second passed - reset counter
    clr a
    mov ticks_per_sec+0, a
    mov ticks_per_sec+1, a
    setb seconds_flag
    cpl LEDRA.0                   ; Heartbeat
    inc current_time

T2_ISR_pwm:
    ; Call PWM function every tick
    lcall PWM_oven
    
    pop psw
    pop acc
    reti

; PWM FUNCTION - Uses pre-calculated pwm_on_ticks value
; This function does NOT read "BCD_counter"!
; It constantly uses the value in "pwm_on_ticks" that was calculated
; by the Update_PWM function.

PWM_oven:
    push ACC
    
    ; Increment PWM tick counter (0-19)
    inc pwm_tick_counter
    mov a, pwm_tick_counter
    
    ; Check if period completed (reached 20)
    cjne a, #PWM_PERIOD_TICKS, PWM_check_threshold
    
    ; PERIOD COMPLETE - Restart cycle
    mov pwm_tick_counter, #0
    
    ; Check if pwm_on_ticks is 0 (off)
    mov a, pwm_on_ticks
    jz PWM_start_off              ; 0 ticks = stay OFF
    
    ; pwm_on_ticks > 0, start ON
    setb SSR_PIN
    setb oven_enabled
    sjmp PWM_return

PWM_start_off:
    ; 0 ticks = stay OFF
    clr SSR_PIN
    clr oven_enabled
    sjmp PWM_return

    ; during. check if should turn off
PWM_check_threshold:
    ; If counter >= pwm_on_ticks, turn OFF
    mov a, pwm_tick_counter
    clr c
    subb a, pwm_on_ticks
    jc PWM_return                 ; Counter < threshold, stay ON
    
    ; Counter >= threshold - turn OFF
    clr SSR_PIN
    clr oven_enabled

PWM_return:
    pop ACC
    ret

; UPDATE PWM FUNCTION - Call this to apply new percentage
; ================================================================
; Input: BCD_counter variable (0-100 in BCD or binary)
; Output: Updates pwm_on_ticks
;
; USAGE:
;   mov BCD_counter, #30
;   lcall Update_PWM        ; Call this to apply!
;
; The PWM function will now use 30% duty cycle until you
; call Update_PWM again with a different value.
; ================================================================
Update_PWM:
    push acc
    push psw
    
    ; Calculate: pwm_on_ticks = (BCD_counter * 20) / 100 = BCD_counter / 5
    mov a, pwm
    mov b, #5
    div AB                        ; A = BCD_counter / 5
    
    ; Limit to max 20 ticks (in case BCD_counter > 100)
    cjne a, #21, Store_Ticks
    mov a, #20
    
Store_Ticks:
    mov pwm_on_ticks, a           ; Store calculated value
    
    pop psw
    pop acc
    ret



