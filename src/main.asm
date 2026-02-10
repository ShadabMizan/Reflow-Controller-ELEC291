$MODMAX10

org 0000H
    ljmp Main

; For uart.inc
CLK            equ 33333333 
BAUD           equ 115200
TIMER_2_RELOAD equ (0x10000-(CLK/(32*BAUD)))

$NOLIST
$INCLUDE(uart.inc)
$LIST

DSEG at 30H
uartbuf: ds 30  ; For uart.inc

CSEG
Main:
    mov SP, #7FH

    ; Turn off all unused LEDs (Too bright!)
    mov LEDRA, #0 
	mov LEDRB, #0

    lcall InitSerialPort
MainLoop:

    ; --- Ask for input ---
    mov dptr, #Prompt
    lcall SendString

    ; --- Get string into buffer ---
    mov R0, #uartbuf
    lcall GetString

    ; --- Print newline ---
    lcall PrintNL

    ; --- Echo back ---
    mov dptr, #EchoText
    lcall SendString

    mov R0, #uartbuf
    lcall SendBuffer

    mov dptr, #NewLine
    lcall SendString

    sjmp MainLoop

Prompt:
    db '\r\nEnter text: ',0

EchoText:
    db 'You typed: ',0

END