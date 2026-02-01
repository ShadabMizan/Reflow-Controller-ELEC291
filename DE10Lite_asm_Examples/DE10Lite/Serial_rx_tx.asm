$MODMAX10

CLK            equ 33333333
BAUD           equ 115200
TIMER_2_RELOAD equ (0x10000-(CLK/(32*BAUD)))

org 0000H
   ljmp MyProgram

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

SendString:
    CLR A
    MOVC A, @A+DPTR
    JZ SSDone
    LCALL putchar
    INC DPTR
    SJMP SendString
SSDone:
    ret

SendBuffer:
    mov R0, #Buffer
SendBuffer1:
    MOV A, @R0
    JZ SendBufferDone
    LCALL putchar
    INC R0
    SJMP SendBuffer1
SendBufferDone:
    ret
    
Question:
    DB  'What is your name?', 0AH, 0DH, 0
Hello:
	DB 0AH, 0DH, 'Hello ', 0
nlcr:
	DB 0AH, 0DH, 0

getchar:
    jnb RI, getchar
    clr RI
    mov a, SBUF
    lcall putchar
    ret

DSEG at 30H
buffer: ds 30

CSEG
GeString:
    mov R0, #buffer
GSLoop:
    lcall getchar
    push acc
    clr c
    subb a, #10H
    pop acc
    jc GSDone
    MOV @R0, A
    inc R0
    cjne R0, #(buffer+29), GSLoop ; Prevent buffer overrun
GSDone:
    clr a
    mov @R0, a
    ret
    
MyProgram:
    MOV SP, #7FH
    mov LEDRA, #0
    mov LEDRB, #0
    
    LCALL InitSerialPort
    MOV DPTR, #Question
    
    LCALL SendString
    lcall GeString
    
    mov dptr, #Hello
    lcall SendString
    
    lcall SendBuffer
    
    mov dptr, #nlcr
    LCALL SendString
    
Forever:
    SJMP Forever
END
