$MODMAX10

; The Special Function Registers below were added to 'MODMAX10' recently.
; If you are getting an error, uncomment the three lines below.

; ADC_C DATA 0xa1
; ADC_L DATA 0xa2
; ADC_H DATA 0xa3

org 0000h
    ljmp mycode

org 002Bh
    ljmp Timer2_ISR

dseg at 30h
; Math32 variables
x:		ds	4
y:		ds	4
bcd:	ds	5

; PWM variables
ticks_per_sec:    ds 2        ; Tick counter for seconds
pwm_tick_counter: ds 1
pwm_on_ticks:     ds 1
pwm:              ds 1    ; 0–100 (% duty cycle)

; Tmp variables
ref4040: ds 4
coldj_tmp: ds 4


bseg
; math32 bit
mf:		dbit 1

; PWM bit
seconds_flag: dbit 1
oven_enabled:     dbit 1      ; PWM state

CLK              EQU 33333333    ; DE10-Lite CV-8052 = 33.333 MHz
TIMER2_RATE      EQU 2048        ; 2048 Hz for a 488 u-sec period/per tick
TIMER2_RELOAD    EQU ((65536-(CLK/(12*TIMER2_RATE))))
PWM_PERIOD_TICKS EQU 20          ; 20 ticks = 9.77ms period = 102 Hz PWM

SSR_PIN         EQU P3.7

VREF_VALUE      EQU 4116

THERMOCOUPLE_GAIN_TIMES_CONVERSION_CONSTANT equ 12628 ; 300 * 41

CSEG

InitSerialPort:
    mov TMOD, #20H        ; Timer1 mode 2
    mov TH1, #0F7H          ; 9600 baud @ 33.333MHz
    mov TL1, #0F7H
    setb TR1              ; Start Timer1
    mov SCON, #50H        ; Mode 1, REN enabled
    setb TI               ; Set TI so first transmit works
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

$include(math32.asm)

cseg
; These 'equ' must match the wiring between the DE10Lite board and the LCD!
; P0 is in connector JPIO.  Check "CV-8052 Soft Processor in the DE10Lite Board: Getting
; Started Guide" for the details.
ELCD_RS equ P1.7
; ELCD_RW equ Px.x ; Not used.  Connected to ground 
ELCD_E  equ P1.1
ELCD_D4 equ P0.7
ELCD_D5 equ P0.5
ELCD_D6 equ P0.3
ELCD_D7 equ P0.1
$NOLIST
$include(LCD_4bit_DE10Lite_no_RW.inc) ; A library of LCD related functions and utility macros
$include(pwm.inc)
$LIST

; Look-up table for 7-seg displays
myLUT:
    DB 0xC0, 0xF9, 0xA4, 0xB0, 0x99        ; 0 TO 4
    DB 0x92, 0x82, 0xF8, 0x80, 0x90        ; 4 TO 9
    DB 0x88, 0x83, 0xC6, 0xA1, 0x86, 0x8E  ; A to F

Wait50ms:
;33.33MHz, 1 clk per cycle: 0.03us
	mov R0, #30
Wait50ms_L3:
	mov R1, #74
Wait50ms_L2:
	mov R2, #250
Wait50ms_L1:
	djnz R2, Wait50ms_L1 ;3*250*0.03us=22.5us
    djnz R1, Wait50ms_L2 ;74*22.5us=1.665ms
    djnz R0, Wait50ms_L3 ;1.665ms*30=50ms
    ret

Display_Voltage_7seg:
	
	mov dptr, #myLUT

	mov a, bcd+1
	swap a
	anl a, #0FH
	movc a, @a+dptr
	anl a, #0x7f ; Turn on decimal point
	mov HEX3, a
	
	mov a, bcd+1
	anl a, #0FH
	movc a, @a+dptr
	mov HEX2, a

	mov a, bcd+0
	swap a
	anl a, #0FH
	movc a, @a+dptr
	mov HEX1, a
	
	mov a, bcd+0
	anl a, #0FH
	movc a, @a+dptr
	mov HEX0, a
	
	ret

Display_Voltage_LCD:
	Set_Cursor(2,1)
	mov a, #'V'
	lcall ?WriteData
	mov a, #'='
	lcall ?WriteData

	mov a, bcd+1
	swap a
	anl a, #0FH
	orl a, #'0'
	lcall ?WriteData
	
	mov a, #'.'
	lcall ?WriteData
	
	mov a, bcd+1
	anl a, #0FH
	orl a, #'0'
	lcall ?WriteData

	mov a, bcd+0
	swap a
	anl a, #0FH
	orl a, #'0'
	lcall ?WriteData
	
	mov a, bcd+0
	anl a, #0FH
	orl a, #'0'
	lcall ?WriteData
	
	ret
	
Display_Voltage_Serial:
	mov a, #'V'
	lcall putchar
	mov a, #'='
	lcall putchar

	mov a, bcd+1
	swap a
	anl a, #0FH
	orl a, #'0'
	lcall putchar
	
	mov a, #'.'
	lcall putchar
	
	mov a, bcd+1
	anl a, #0FH
	orl a, #'0'
	lcall putchar

	mov a, bcd+0
	swap a
	anl a, #0FH
	orl a, #'0'
	lcall putchar
	
	mov a, bcd+0
	anl a, #0FH
	orl a, #'0'
	lcall putchar

	mov a, #'\r'
	lcall putchar
	mov a, #'\n'
	lcall putchar
	
	ret

Initial_Message:  db 'Voltmeter test', 0

mycode:
	mov SP, #0x7F
	clr a
	mov LEDRA, a
	mov LEDRB, a
	
	lcall InitSerialPort
    lcall Timer2_Init
	
	; COnfigure the pins connected to the LCD as outputs
	mov P0MOD, #10101010b ; P0.1, P0.3, P0.5, P0.7 are outputs.  ('1' makes the pin output)
    mov P1MOD, #10000010b ; P1.7 and P1.1 are outputs

    ; Initial PWM output
    mov P3MOD, #10000000b   ; P3.7

    mov ADC_C, #0x80 ; Reset ADC
	lcall Wait50ms

    clr a
    mov pwm_tick_counter, a
    mov pwm_on_ticks, a
    mov pwm, #0

    setb EA              ; Enable global interrupts
    
    ; Set initial 0% and apply
    mov pwm, #0
    lcall Update_PWM        

    ; lcall ELCD_4BIT ; Configure LCD in four bit mode
    ; ; ; For convenience a few handy macros are included in 'LCD_4bit_DE1Lite.inc':
	; Set_Cursor(1, 1)
    ; Send_Constant_String(#Initial_Message)
	
	mov dptr, #Initial_Message
	lcall SendString
	mov a, #'\r'
	lcall putchar
	mov a, #'\n'
	lcall putchar

    mov pwm, #50
    lcall Update_PWM

    ; Test UART
    mov a, #'T'
    lcall putchar
    mov a, #'E'
    lcall putchar
    mov a, #'S'
    lcall putchar
    mov a, #'T'
    lcall putchar
    mov a, #'\r'
    lcall putchar
    mov a, #'\n'
    lcall putchar
    
    lcall Wait50ms

forever:
    mov pwm, #75
    lcall Update_PWM

    lcall Read_Temperature_Simple
    lcall Wait50ms
	ljmp forever

; ----------------------------------------
; TEMPERATURE ROUTINES
; ----------------------------------------
Read_Temperature:    
    ; Load LM335 ADC
    mov ADC_C, #0x01
    lcall Wait5ms

	mov x+3, #0
	mov x+2, #0
	mov x+1, ADC_H
	mov x+0, ADC_L

    Load_y(VREF_VALUE)
    lcall mul32     ; x = VREF * ADCLM335

    ; Load Reference ADC 
    mov ADC_C, #0x00 
    lcall Wait5ms

    mov y+3, #0
	mov y+2, #0
	mov y+1, ADC_H
	mov y+0, ADC_L

    lcall div32
    ; x = (VREF(mV) * ADCLM335)/ADCREF = VLM335 (mV)

    Load_y(2730)
    lcall sub32 
    ; x = (VLM335 - 2730mV)

    Load_y(10)
    lcall div32
    ; x = (VLM335 -2730mV)/(10mV/C)

    mov coldj_tmp+3, x+3
    mov coldj_tmp+2, x+2
    mov coldj_tmp+1, x+1
    mov coldj_tmp+0, x+0

    ; coldj_tmp = TC

    mov ADC_C, #0x02
    lcall Wait5ms

	mov x+3, #0
	mov x+2, #0
	mov x+1, ADC_H
	mov x+0, ADC_L

    Load_y(330) ; (4096mV)/(0.041mV) * (1/303)
    lcall mul32
    ; x = (4096mV/0.041mV)*(1/303)*ADCOp

    mov ADC_C, #0x00
    lcall Wait5ms

    mov y+3, #0
	mov y+2, #0
	mov y+1, ADC_H
	mov y+0, ADC_L
    lcall div32
    ; x = ((4096mV/0.041mV)*(1/303)*ADCOp)/ADCref

    ; x = TH

    mov y+3, coldj_tmp+3
	mov y+2, coldj_tmp+2
	mov y+1, coldj_tmp+1
	mov y+0, coldj_tmp+0
    ; y = TC

    lcall add32
    ; x = TH + TC

    Load_y(1000)
    lcall mul32
    
	lcall hex2bcd

    lcall Display_Temp_Serial ;sending this ts to the serial port

    lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
    ret

Read_Temperature_Simple:
    mov ADC_C, #0x02
    lcall Wait5ms
	
	; Load 32-bit 'x' with 12-bit adc result
	mov x+3, #0
	mov x+2, #0
	mov x+1, ADC_H
	mov x+0, ADC_L
	
	; Convert to voltage by multiplying by 5.000 and dividing by 4096
	Load_y(5000)
	lcall mul32
	Load_y(4096)
	lcall div32
	
    Load_y(1000) ; convert to microvolts
    lcall mul32
    Load_y(12300) ; 41 * 300
    lcall div32

    Load_y(22) ; add cold junction temperature
    lcall add32

    Load_y(1000)
    lcall mul32

    lcall hex2bcd
    lcall Display_Temp_Serial
    lcall Display_Voltage_7seg
    ret


Display_Temp_Serial:
	mov a, #'T'
	lcall putchar
	mov a, #'='
	lcall putchar
	
	mov a, bcd+3
	swap a
	anl a, #0FH
	orl a, #'0'
	lcall putchar
	
	mov a, bcd+3
	anl a, #0FH
	orl a, #'0'
	lcall putchar

	mov a, bcd+2
	swap a
	anl a, #0FH
	orl a, #'0'
	lcall putchar
	
	mov a, bcd+2
	anl a, #0FH
	orl a, #'0'
	lcall putchar

	mov a, bcd+1
	swap a
	anl a, #0FH
	orl a, #'0'
	lcall putchar
	
	mov a, #'.'
	lcall putchar
	
	mov a, bcd+1
	anl a, #0FH
	orl a, #'0'
	lcall putchar

	mov a, bcd+0
	swap a
	anl a, #0FH
	orl a, #'0'
	lcall putchar
	
	mov a, bcd+0
	anl a, #0FH
	orl a, #'0'
	lcall putchar

	mov a, #'\r'
	lcall putchar
	mov a, #'\n'
	lcall putchar
	
	ret

Wait5ms:
    push acc
    mov R2, #25
Wait5ms_L1:
    lcall Wait200us
    djnz R2, Wait5ms_L1
    pop acc
    ret

Wait200us:
    push acc
    mov R3, #250
Wait200us_L1:
    nop
    nop
    djnz R3, Wait200us_L1
    pop acc
    ret

end