; hex.inc - HEX Display Functions for temperature (BCD-based)
;
; Displays temperature on 7-segment displays in format: xxx.xC
; Input: global BCD buffer `bcd` containing temperature * 10 in BCD
;        (hundreds/tens/ones/tenths in bcd+1/bcd+0, as produced by hex2bcd)
;
$NOLIST

CSEG

; 7-segment lookup table for 0-9
myLUT: 
    DB 0xC0, 0xF9, 0xA4, 0xB0, 0x99        ; 0 TO 4
    DB 0x92, 0x82, 0xF8, 0x80, 0x90        ; 5 TO 9

; --------------------------------------------------------------------
; Display_BCD_HEX
; --------------------------------------------------------------------
; Displays temperature from BCD on HEX displays
; Assumes:
;   - `bcd` holds temperature * 10 in BCD
;   - Layout (from hex2bcd lower digits):
;       bcd+0: upper nibble = ones, lower nibble = tenths
;       bcd+1: upper nibble = hundreds, lower nibble = tens
; Format on HEX:
;   HEX5 HEX4 HEX3 HEX2 HEX1 HEX0
;    [ ]  [H]  [T] [O.] [t]  ['C']
; Example: 123.4°C -> HEX5 blank, HEX4=1, HEX3=2, HEX2=3 with DP, HEX1=4, HEX0='C'
;
Display_BCD_HEX:
    push acc
    push dph
    push dpl
    
    mov dptr, #myLUT
    
    ; HEX0: 'C'
    mov HEX0, #0xC6
    
    ; HEX1: tenths digit (bcd+0, lower nibble)
    mov a, bcd+0
    anl a, #0x0F
    movc a, @a+dptr
    mov HEX1, a
    
    ; HEX2: ones digit with decimal point (bcd+0, upper nibble)
    mov a, bcd+0
    swap a
    anl a, #0x0F
    movc a, @a+dptr
    anl a, #0x7F    ; Turn on decimal point
    mov HEX2, a
    
    ; HEX3: tens digit (bcd+1, lower nibble)
    mov a, bcd+1
    anl a, #0x0F
    movc a, @a+dptr
    mov HEX3, a
    
    ; HEX4: hundreds digit (bcd+1, upper nibble) with leading-blank suppression
    mov a, bcd+1
    swap a
    anl a, #0x0F
    jz blank_hex4
    movc a, @a+dptr
    mov HEX4, a
    sjmp hex_done
blank_hex4:
    mov HEX4, #0xFF
    
hex_done:
    mov HEX5, #0xFF
    
    pop dpl
    pop dph
    pop acc
    ret

; Backwards-compatible alias (if older code expects Display_Temperature)
Display_Temperature:
    ljmp Display_BCD_HEX

$LIST

