CSEG
;***BETA, CUR_TEMP and TGT_TEMP should be in 10000 = 10k= 1 
; ALPHA is 100 = 1% =0.01
; 

; ex. Cur = 100 0000 = 100 deg  Tgt = 140 0000 = 140 deg  
;alpha = 50 00 = 50%    beta = 40000 = 4
; then 
; f() = 0.5*(140-100) - 4 = 16% pwm
; 
; PWM from 0 to 100 
; 

; create in main file: 
; DSEG
; CUR_TEMP:   ds 4
; TGT_TEMP:   ds 4
; ALPHA:      ds 4
; BETA:       ds 4
; PWM:        ds 1    ; Changed to 1 byte (0-100)

;--------------------------------------------------
; SET_PWM
;
; PWM = f(CUR_TEMP, TGT_TMP, ALPHA, BETA) in %
; f()= ALPHA*(TGT_TMP - CUR_TEMP) + BETA
; Uses math32.inc
;
; 4 inputs
; CUR_TEMP, TGT_TEMP : signed 32-bit, in 100microC (?)
; ALPHA, BETA        : constants in signed 32-bit 
;
; 1 output
; PWM           : 8-bit unsigned value (0-100)
;--------------------------------------------------
SET_PWM:

; ---------- Δ = TARGET - CURRENT ----------
    MOV  x+0, TGT_TEMP+0
    MOV  x+1, TGT_TEMP+1
    MOV  x+2, TGT_TEMP+2
    MOV  x+3, TGT_TEMP+3

    MOV  y+0, CUR_TEMP+0
    MOV  y+1, CUR_TEMP+1
    MOV  y+2, CUR_TEMP+2
    MOV  y+3, CUR_TEMP+3

    LCALL sub32          ; x = Δ

    MOV  y+0, ALPHA+0
    MOV  y+1, ALPHA+1
    MOV  y+2, ALPHA+2
    MOV  y+3, ALPHA+3
    LCALL mul32          ; x = ALPHA * Δ

    Load_y(10000)
    LCALL div32
    
    MOV  y+0, BETA+0
    MOV  y+1, BETA+1
    MOV  y+2, BETA+2
    MOV  y+3, BETA+3
    
    LCALL sub32  
    Load_y(10000)
    LCALL div32
    
    
    


; ---------- Clamp result to 0-100 range ----------
    
; Check if negative (MSB of x+3 is set)
    MOV  A, x+3
    JNB  ACC.7, CHECK_UPPER  ; If bit 7 is 0, it's positive
    
; Value is negative, clamp to 0
    MOV  PWM, #0
    SJMP DONE
    
CHECK_UPPER:
; Check if > 100 (if any upper bytes are non-zero, or lower byte > 100)
    MOV  A, x+3
    JNZ  CLAMP_MAX       ; If x+3 != 0, value > 255
    MOV  A, x+2
    JNZ  CLAMP_MAX       ; If x+2 != 0, value > 255
    MOV  A, x+1
    JNZ  CLAMP_MAX       ; If x+1 != 0, value > 255
    
; Only x+0 has a value, check if it's > 100
    MOV  A, x+0
    CJNE A, #101, CHECK_LESS
CHECK_LESS:
    JC   STORE_PWM       ; If A < 101, store the value
    
CLAMP_MAX:
    MOV  PWM, #100       ; Clamp to 100
    SJMP DONE
    
STORE_PWM:
    MOV  PWM, x+0        ; Store the 8-bit result

DONE:
    RET
