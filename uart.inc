; Main must define:
; CLK            equ 33333333 
; BAUD           equ 115200
; TIMER_2_RELOAD equ (0x10000-(CLK/(32*BAUD)))
; uartbuf in dseg

$NOLIST
CSEG

; Must be called in the start to initialize the UART port. Uses Timer 2
InitSerialPort:
	mov RCAP2H, #HIGH(TIMER_2_RELOAD);
	mov RCAP2L, #LOW(TIMER_2_RELOAD);
	mov T2CON, #0x34 ; // #00110100B
	mov SCON, #0x52 ; // Serial port in mode 1, ren, txrdy, rxempty
	ret

putchar:
    JNB TI, putchar
    CLR TI
    MOV SBUF, a
    RET

; Send the string that is being pointed to by DPTR
SendString:
    CLR A
    MOVC A, @A+DPTR
    JZ SSDone
    LCALL putchar
    INC DPTR
    SJMP SendString
SSDone:
    ret

; Input: R0 = address of the buffer to be sent
SendBuffer:
SBLoop:
    MOV A, @R0
    JZ SendBufferDone
    LCALL putchar
    INC R0
    SJMP SBLoop
SendBufferDone:
    ret

getchar:
    jnb RI, getchar
    clr RI
    mov a, SBUF
    lcall putchar
    ret

GetString:
    mov R0, #uartbuf
GSLoop:
    lcall getchar
    push acc
    clr c
    subb a, #10H
    pop acc
    jc GSDone
    MOV @R0, A
    inc R0
    cjne R0, #(uartbuf+29), GSLoop ; Prevent buffer overrun
GSDone:
    clr a
    mov @R0, a
    ret

NewLine:
    DB '\r\n',0

PrintNL:
    mov DPTR, #NewLine
    lcall SendString

$LIST