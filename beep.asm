; --------------------------------------------- PARAM :
; SPEAKER_PIN - I/O pin connected to speaker (default: P1.0)
; BEEP_DURATION - Length of each beep in milliseconds (default: 200ms)
; BEEP_GAP - Silence between beeps in milliseconds (default: 100ms)
; TIMER_RELOAD_H/L - Timer 0 reload values for 2048 Hz tone generation

; --------------------------------------------- USE :
; Call Init_Speaker "lcall Init_Speaker" once at program startup
; Call Beep_State_Change "lcall Beep_State_Change" for 1 beep (state change)
; Call Beep_Complete "lcall Beep_Complete" for 5 beeps (completion)
; Call Beep_Error "lcall Beep_Error" for 10 beeps (error)


SPEAKER_PIN     EQU P1.0
BEEP_DURATION   EQU 200
BEEP_GAP        EQU 100
TIMER_RELOAD_H  EQU 0FEh
TIMER_RELOAD_L  EQU 03Eh

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
