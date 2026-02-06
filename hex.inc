; hex.inc - HEX Display Functions for temperature

; Displays temperature on 7-segment displays in format: ___._C
; Input format: temp variable where 1000 = 1.0°C
; Example: 250,7890 displays as 250.7°C


$NOLIST

; NEEDED Definitions in Main program
; temp: ds 4  ; Temperature input (32-bit)
; bcd:  ds 3  ; BCD conversion buffer

CSEG

; 7-segment lookup table (0-9)
myLUT: DB 0xC0,0xF9,0xA4,0xB0,0x99,0x92,0x82,0xF8,0x80,0x90


; bin16_to_bcd
; Convert 16-bit binary in R5:R4 to BCD in bcd+0, bcd+1, bcd+2
; Uses double-dabble algorithm
; Input: R5:R4 = 16-bit binary number
; Output: bcd+0, bcd+1, bcd+2 = packed BCD (6 digits)

bin16_to_bcd:
    push acc
    push AR0
    push AR1
    push AR2
    
    ; Clear BCD
    mov bcd+0, #0
    mov bcd+1, #0
    mov bcd+2, #0
    
    mov R2, #16  ; 16 bits to process
    
bcd_loop:
    ; Shift binary left
    clr c
    mov a, R4
    rlc a
    mov R4, a
    mov a, R5
    rlc a
    mov R5, a
    
    ; Shift BCD left and add carry using BCD arithmetic
    mov a, bcd+0
    addc a, bcd+0
    da a
    mov bcd+0, a
    
    mov a, bcd+1
    addc a, bcd+1
    da a
    mov bcd+1, a
    
    mov a, bcd+2
    addc a, bcd+2
    da a
    mov bcd+2, a
    
    djnz R2, bcd_loop
    
    pop AR2
    pop AR1
    pop AR0
    pop acc
    ret


; Display_Temperature
; Displays temperature on HEX5-HEX0 in format: ___._C
; Input: temp (32-bit) where 1000 = 1.0°C
; Example: 2507890 displays as 250.7°C
; Output: Updates HEX0-HEX5 seven-segment displays

Display_Temperature:
    push acc
    push b
    push AR0
    push AR1
    push AR2
    push AR3
    push AR4
    push AR5
    
    ; Divide temp by 1000 using repeated subtraction
    mov R0, temp+0
    mov R1, temp+1
    mov R2, temp+2
    mov R3, temp+3
    
    mov R4, #0  ; Result low byte
    mov R5, #0  ; Result high byte
    
div1k:
    ; Check if [R3:R2:R1:R0] >= 1000
    mov a, R3
    jnz sub1k
    mov a, R2  
    jnz sub1k
    clr c
    mov a, R0
    subb a, #0xE8  ; Low byte of 1000
    mov a, R1
    subb a, #0x03  ; High byte of 1000
    jc div_end
    
sub1k:
    ; Subtract 1000 (0x03E8)
    clr c
    mov a, R0
    subb a, #0xE8
    mov R0, a
    mov a, R1
    subb a, #0x03
    mov R1, a
    mov a, R2
    subb a, #0
    mov R2, a
    mov a, R3
    subb a, #0
    mov R3, a
    
    ; Increment 16-bit result
    inc R4
    mov a, R4
    jnz div1k
    inc R5
    sjmp div1k
    
div_end:
    ; Convert R5:R4 to BCD
    lcall bin16_to_bcd
    
    ; Display BCD digits on 7-segment displays
    mov dptr, #myLUT
    mov HEX0, #0xC6  ; 'C'
    
    ; bcd+0 has digits 1 and 0 (lower nibble = digit 0, upper nibble = digit 1)
    ; bcd+1 has digits 3 and 2 (lower nibble = digit 2, upper nibble = digit 3)
    ; bcd+2 has digits 5 and 4 (lower nibble = digit 4, upper nibble = digit 5)
    
    ; Digit 0 (tenths place) - lower nibble of bcd+0
    mov a, bcd+0
    anl a, #0x0F
    movc a, @a+dptr
    mov HEX1, a
    
    ; Digit 1 (ones place with decimal point) - upper nibble of bcd+0
    mov a, bcd+0
    swap a
    anl a, #0x0F
    movc a, @a+dptr
    anl a, #0x7F  ; Clear bit 7 to turn on decimal point
    mov HEX2, a
    
    ; Digit 2 (tens place) - lower nibble of bcd+1
    mov a, bcd+1
    anl a, #0x0F
    push acc
    ; Check if should blank (leading zero suppression)
    mov a, bcd+1
    swap a
    anl a, #0x0F
    jnz show_d2
    mov a, bcd+2
    jnz show_d2
    ; Both hundreds and higher are zero, blank tens
    mov HEX3, #0xFF
    pop acc
    sjmp do_d3
show_d2:
    pop acc
    movc a, @a+dptr
    mov HEX3, a
    
do_d3:
    ; Digit 3 (hundreds place) - upper nibble of bcd+1
    mov a, bcd+1
    swap a
    anl a, #0x0F
    jz blank_d3
    movc a, @a+dptr
    mov HEX4, a
    sjmp done_display
blank_d3:
    mov HEX4, #0xFF  ; Blank display
    
done_display:
    mov HEX5, #0xFF  ; Always blank (for temps < 1000°C)
    
    pop AR5
    pop AR4
    pop AR3
    pop AR2
    pop AR1
    pop AR0
    pop b
    pop acc
    ret

$LIST
