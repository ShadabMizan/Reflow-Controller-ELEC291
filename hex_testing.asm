
; hex_test.asm - Test program for hex.inc
; Tests temperature display using manually set temp variable


$MODMAX10

CSEG at 0
ljmp main


dseg at 30h
temp: ds 4  ; Temperature input (32-bit, where 1000 = 1.0°C)
bcd:  ds 3  ; BCD conversion buffer (used by hex.inc)


CSEG
$include(hex.inc)

; ============================================================================
; Main program
; ============================================================================
main:
    
    
    
    ; 0007890 = 0x00001ED2
    mov temp+0, #0xD2  ; LSB
    mov temp+1, #0x1E
    mov temp+2, #0x00
    mov temp+3, #0x00  ; MSB
    
    lcall Display_Temperature

forever:
    ljmp forever

end
