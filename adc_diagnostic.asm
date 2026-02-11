;===================================================================
; DIAGNOSTIC CODE - Check Raw ADC Values
; This will help identify why temperature is constant
;===================================================================

$NOLIST
$MODDE1SOC
$LIST

LTC2308_MISO bit 0xF8
LTC2308_MOSI bit 0xF9
LTC2308_SCLK bit 0xFA
LTC2308_ENN  bit 0xFB

CLK   EQU 33333333
BAUD  EQU 57600
TIMER_2_RELOAD EQU (65536-(CLK/(32*BAUD)))

org 0x0000
	ljmp mycode

org 0x0003
	reti
org 0x000B
	reti
org 0x0013
	reti
org 0x001B
	reti
org 0x0023 
	reti
org 0x002B
	reti

CSEG

Initialize_Serial_Port:
	mov RCAP2H, #high(TIMER_2_RELOAD)
	mov RCAP2L, #low(TIMER_2_RELOAD)
	mov T2CON, #0x34
	mov SCON, #0x52
	ret

putchar:
	jbc	TI,putchar_L1
	sjmp putchar
putchar_L1:
	mov	SBUF,a
	ret

SendString:
    clr a
    movc a, @a+dptr
    jz SendString_L1
    inc dptr
    lcall putchar
    sjmp SendString  
SendString_L1:
	ret

Initialize_ADC:
	clr	LTC2308_MOSI
	clr	LTC2308_SCLK
	setb LTC2308_ENN
	ret

LTC2308_Toggle_Pins:
    mov LTC2308_MOSI, c
    setb LTC2308_SCLK
    mov c, LTC2308_MISO
    clr LTC2308_SCLK
    ret

LTC2308_RW:
    clr a 
	clr	LTC2308_ENN

    setb c
    lcall LTC2308_Toggle_Pins
    mov acc.3, c
    mov c, b.2
    lcall LTC2308_Toggle_Pins
    mov acc.2, c 
    mov c, b.0
    lcall LTC2308_Toggle_Pins
    mov acc.1, c
    mov c, b.1
    lcall LTC2308_Toggle_Pins
    mov acc.0, c
    mov R1, a
    
    clr a 
    setb c
    lcall LTC2308_Toggle_Pins
    mov acc.7, c
    clr c
    lcall LTC2308_Toggle_Pins
    mov acc.6, c
    clr c
    lcall LTC2308_Toggle_Pins
    mov acc.5, c
    clr c
    lcall LTC2308_Toggle_Pins
    mov acc.4, c
    clr c
    lcall LTC2308_Toggle_Pins
    mov acc.3, c
    clr c
    lcall LTC2308_Toggle_Pins
    mov acc.2, c
    clr c
    lcall LTC2308_Toggle_Pins
    mov acc.1, c
    clr c
    lcall LTC2308_Toggle_Pins
    mov acc.0, c
    mov R0, a

	setb LTC2308_ENN
	ret

Wait50ms:
	mov R2, #30
Wait50ms_L3:
	mov R3, #74
Wait50ms_L2:
	mov R4, #250
Wait50ms_L1:
	djnz R4, Wait50ms_L1
	djnz R3, Wait50ms_L2
	djnz R2, Wait50ms_L3
	ret

; Send a HEX byte
SendHexByte:
	push acc
	swap a
	anl a, #0Fh
	add a, #'0'
	cjne a, #'9'+1, $+3
	sjmp SendHex_1
	add a, #7
SendHex_1:
	lcall putchar
	pop acc
	anl a, #0Fh
	add a, #'0'
	cjne a, #'9'+1, $+3
	sjmp SendHex_2
	add a, #7
SendHex_2:
	lcall putchar
	ret

; Send 12-bit value in [R1, R0] as hex
Send12BitHex:
	mov a, #'0'
	lcall putchar
	mov a, #'x'
	lcall putchar
	
	mov a, R1
	lcall SendHexByte
	mov a, R0
	lcall SendHexByte
	ret

; Send decimal number in [R1,R0]
SendDecimal:
	; Simple decimal conversion for values 0-4095
	mov a, R1
	mov b, #100
	div ab
	push b
	add a, #'0'
	lcall putchar
	pop acc
	mov b, #10
	div ab
	push b
	add a, #'0'
	lcall putchar
	pop acc
	add a, #'0'
	lcall putchar
	
	mov a, R0
	mov b, #100
	div ab
	push b
	add a, #'0'
	lcall putchar
	pop acc
	mov b, #10
	div ab
	push b
	add a, #'0'
	lcall putchar
	pop acc
	add a, #'0'
	lcall putchar
	ret

Header: db '\r\n=== ADC CHANNEL DIAGNOSTIC ===\r\n', 0
Ch0_msg: db 'CH0 (LM4040 Ref):  ', 0
Ch1_msg: db 'CH1 (LM335 Cold):  ', 0
Ch2_msg: db 'CH2 (Thermocouple):', 0
Separator: db '  (decimal: ', 0
EndLine: db ')\r\n', 0

mycode:
	mov SP, #7FH
	
	clr a
	mov LEDRA, a
	mov LEDRB, a
	
	lcall Initialize_Serial_Port
	lcall Initialize_ADC
	lcall Wait50ms

forever:
	; Print header
	mov dptr, #Header
	lcall SendString
	
	; ===== Channel 0 (LM4040) =====
	mov dptr, #Ch0_msg
	lcall SendString
	
	mov b, #0
	lcall LTC2308_RW
	lcall LTC2308_RW
	
	lcall Send12BitHex
	mov dptr, #Separator
	lcall SendString
	lcall SendDecimal
	mov dptr, #EndLine
	lcall SendString
	
	; ===== Channel 1 (LM335) =====
	mov dptr, #Ch1_msg
	lcall SendString
	
	mov b, #1
	lcall LTC2308_RW
	lcall LTC2308_RW
	
	lcall Send12BitHex
	mov dptr, #Separator
	lcall SendString
	lcall SendDecimal
	mov dptr, #EndLine
	lcall SendString
	
	; ===== Channel 2 (Thermocouple) =====
	mov dptr, #Ch2_msg
	lcall SendString
	
	mov b, #2
	lcall LTC2308_RW
	lcall LTC2308_RW
	
	lcall Send12BitHex
	mov dptr, #Separator
	lcall SendString
	lcall SendDecimal
	mov dptr, #EndLine
	lcall SendString
	
	; Blank line
	mov a, #'\r'
	lcall putchar
	mov a, #'\n'
	lcall putchar
	
	; Wait 1 second
	lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
	
	sjmp forever

END
