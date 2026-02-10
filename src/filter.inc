$NOLIST

; Requires math32
; 4 byte x, y in dseg
; 5 byte bcd in dseg
; 1 bit mf in bseg

; Requires a 4 byte tmp variable in dseg
; Requires a define for ALPHA, which should be the filter coefficient * 1000

CSEG

; Moving Avg LPF
; Inputs:
; x = Raw Temperature difference between hot and cold junction, in mC
; Output: 
; x = Oven temperature, Filtered, in mC
CalcOvenTemperature:
    ; Y[n] = X[n-1] + A*(X[n] - Y[n-1])
    mov y+3, tmp+3
    mov y+2, tmp+2
    mov y+1, tmp+1
    mov y+0, tmp+0  ; y = prev tmp, Y[n-1]

    lcall sub32     ; x = X[n] - Y[n-1]

    mov y+3, #0
    mov y+2, #0
    mov y+1, #HIGH(ALPHA)
    mov y+0, #LOW(ALPHA)    ; y = A * 1000

    lcall mul32     ; x = (A * 1000)* (X[n] - Y[n-1])

    mov y+3, #0
    mov y+2, #0
    mov y+1, #HIGH(1000)
    mov y+0, #LOW(1000)     ; y = 1000

    lcall div32     ; x = A * (X[n] - Y[n-1])

    mov y+3, tmp+3
    mov y+2, tmp+2
    mov y+1, tmp+1
    mov y+0, tmp+0  ; y = Y[n-1]

    lcall add32     ; x = Y[n-1] + A*(X[n] - Y[n-1])
    
    ; x = tmp = filtered temperature
    ret

$NOLIST