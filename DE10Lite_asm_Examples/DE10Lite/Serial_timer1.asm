$MODMAX10

; With a 33.3333MHz clock, the highest reliable baudrate we can achieve is 57600

FREQ   EQU 33333333
BAUD   EQU 57600
T2LOAD EQU 256-((FREQ*2)/(32*12*BAUD))

org 0000H
   ljmp MyProgram

InitSerialPort:
	clr TR1 ; Disable timer 1
	mov TMOD, #020H ; Set timer 1 as 8-bit auto reload
	mov TH1, #T2LOAD
	mov TL1, #0
	mov a, PCON ; Set SMOD to 1
	orl a, #80H
	mov PCON, a
	setb TR1 ; Enable timer 1
	mov SCON, #52H
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

Hello:
    DB  'Hello, World!', 0AH, 0DH, 0

MyProgram:
    MOV SP, #7FH
    mov LEDRA, #0
    mov LEDRB, #0
    LCALL InitSerialPort
    MOV DPTR, #Hello
    LCALL SendString

Forever:
    SJMP Forever
END
