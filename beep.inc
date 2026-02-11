; =====================================================================
; BEEP.INC - Speaker control with Timer0 sharing
; =====================================================================
; Temporarily borrows Timer0 to generate 2048 Hz tone
; Saves/restores Timer0 configuration for FSM timing
; =====================================================================

SPEAKER_PIN     EQU BUZZER      ; Use existing BUZZER pin (P2.2)
BEEP_DURATION   EQU 200         ; 200ms beep
BEEP_GAP        EQU 100         ; 100ms gap between beeps
TIMER_RELOAD_H  EQU 0FEh        ; 2048 Hz tone
TIMER_RELOAD_L  EQU 03Eh

; ---------------------------------------------------------------------
; Save Timer0 state before using for beeps
; ---------------------------------------------------------------------
Save_Timer0_State:
    push ACC
    mov A, TH0
    mov R2, A           ; Save TH0 in R2
    mov A, TL0
    mov R3, A           ; Save TL0 in R3
    mov A, TMOD
    mov R4, A           ; Save TMOD in R4
    clr TR0             ; Stop Timer0
    clr ET0             ; Disable Timer0 interrupt
    pop ACC
    ret

; ---------------------------------------------------------------------
; Restore Timer0 state after beeps
; ---------------------------------------------------------------------
Restore_Timer0_State:
    push ACC
    mov A, R4
    mov TMOD, A         ; Restore TMOD
    mov A, R2
    mov TH0, A          ; Restore TH0
    mov A, R3
    mov TL0, A          ; Restore TL0
    setb ET0            ; Re-enable Timer0 interrupt
    setb TR0            ; Restart Timer0
    pop ACC
    ret

; ---------------------------------------------------------------------
; Configure Timer0 for tone generation (2048 Hz)
; ---------------------------------------------------------------------
Setup_Timer0_For_Tone:
    push ACC
    anl TMOD, #0xF0     ; Clear Timer0 bits
    orl TMOD, #0x01     ; Timer0 mode 1 (16-bit)
    clr TR0
    clr TF0
    pop ACC
    ret

; ---------------------------------------------------------------------
; Single beep
; ---------------------------------------------------------------------
Beep_Once:
    push ACC
    push PSW
    push AR2
    push AR3
    push AR4
    push AR6
    push AR7
    
    lcall Save_Timer0_State
    lcall Setup_Timer0_For_Tone
    
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
    
    lcall Restore_Timer0_State
    
    pop AR7
    pop AR6
    pop AR4
    pop AR3
    pop AR2
    pop PSW
    pop ACC
    ret

; ---------------------------------------------------------------------
; 1 beep for state change
; ---------------------------------------------------------------------
Beep_State_Change:
    lcall Beep_Once
    ret

; ---------------------------------------------------------------------
; 5 beeps for completion
; ---------------------------------------------------------------------
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

; ---------------------------------------------------------------------
; 10 beeps for error
; ---------------------------------------------------------------------
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

; ---------------------------------------------------------------------
; Toggle speaker to generate tone
; ---------------------------------------------------------------------
Toggle_Speaker_Tone:
    push ACC
    setb SPEAKER_PIN
    lcall Delay_Half_Period
    clr SPEAKER_PIN
    lcall Delay_Half_Period
    pop ACC
    ret

; ---------------------------------------------------------------------
; Half-period delay for tone generation
; ---------------------------------------------------------------------
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

; ---------------------------------------------------------------------
; Gap between beeps
; ---------------------------------------------------------------------
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

; ---------------------------------------------------------------------
; 1ms delay
; ---------------------------------------------------------------------
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
