; LCD_test_4bit.asm - FIXED 4-BIT INITIALIZATION
$NOLIST
$MODLP51
$LIST

org 0000H
    ljmp myprogram

LCD_RS_PIN equ P0.4
LCD_E      equ P0.5
LCD_D4     equ P0.0
LCD_D5     equ P0.1
LCD_D6     equ P0.2
LCD_D7     equ P0.3

; Increased delays
Wait40uSec:
    push AR0
    mov R0, #250
L0: nop
    nop
    nop
    djnz R0, L0
    pop AR0
    ret

WaitmilliSec:
    push AR0
    push AR1
L3: mov R1, #50
L2: mov R0, #250
L1: djnz R0, L1
    djnz R1, L2
    djnz R2, L3
    pop AR1
    pop AR0
    ret

LCD_pulse:
    setb LCD_E
    lcall Wait40uSec
    clr LCD_E
    lcall Wait40uSec
    ret

; Special function: send only 4 bits (for initialization)
LCD_4bits:
    mov c, ACC.7
    mov LCD_D7, c
    mov c, ACC.6
    mov LCD_D6, c
    mov c, ACC.5
    mov LCD_D5, c
    mov c, ACC.4
    mov LCD_D4, c
    lcall LCD_pulse
    ret

WriteData:
    setb LCD_RS_PIN
    ljmp LCD_byte

WriteCommand:
    clr LCD_RS_PIN
    ljmp LCD_byte

LCD_byte:
    ; Send high nibble
    mov c, ACC.7
    mov LCD_D7, c
    mov c, ACC.6
    mov LCD_D6, c
    mov c, ACC.5
    mov LCD_D5, c
    mov c, ACC.4
    mov LCD_D4, c
    lcall LCD_pulse
    
    ; Send low nibble
    mov c, ACC.3
    mov LCD_D7, c
    mov c, ACC.2
    mov LCD_D6, c
    mov c, ACC.1
    mov LCD_D5, c
    mov c, ACC.0
    mov LCD_D4, c
    lcall LCD_pulse
    ret

LCD_4BIT:
    clr LCD_E
    clr LCD_RS_PIN
    
    ; Wait >40ms after power on
    mov R2, #50
    lcall WaitmilliSec
    
    ; CRITICAL: First commands are 8-bit, but we send only upper nibble
    ; Send 0x03 three times (this is 0x30 in 8-bit mode)
    mov A, #030h
    lcall LCD_4bits
    mov R2, #5
    lcall WaitmilliSec
    
    mov A, #030h
    lcall LCD_4bits
    mov R2, #1
    lcall WaitmilliSec
    
    mov A, #030h
    lcall LCD_4bits
    mov R2, #1
    lcall WaitmilliSec
    
    ; Now switch to 4-bit mode
    mov A, #020h
    lcall LCD_4bits
    mov R2, #1
    lcall WaitmilliSec
    
    ; Now we can use full LCD_byte function
    ; Function set: 4-bit, 2 lines, 5x8
    mov A, #028h
    lcall WriteCommand
    
    ; Display off
    mov A, #008h
    lcall WriteCommand
    
    ; Clear display
    mov A, #001h
    lcall WriteCommand
    mov R2, #5
    lcall WaitmilliSec
    
    ; Entry mode: increment, no shift
    mov A, #006h
    lcall WriteCommand
    
    ; Display on, cursor off
    mov A, #00Ch
    lcall WriteCommand
    
    ret

myprogram:
    mov SP, #7FH
    
    ; Drive ports high
    mov P0, #0FFh
    mov P1, #0FFh
    mov P2, #0FFh
    mov P3, #0FFh
    
    lcall LCD_4BIT
    
    ; Write 'A' at position 0
    mov A, #080h
    lcall WriteCommand
    mov A, #'A'
    lcall WriteData
    
    ; Write 'B' at second line, position 2
    mov A, #0C2h
    lcall WriteCommand
    mov A, #'B'
    lcall WriteData

forever:
    sjmp forever
END