;===================================================================
; CV-8052 Temperature Measurement - CORRECTED VERSION
; For DE1-SoC with LTC2308
; Fixed: VREF value and unit consistency for 2 decimal places
;===================================================================

$NOLIST
$MODDE1SOC
$LIST

LTC2308_MISO bit 0xF8
LTC2308_MOSI bit 0xF9
LTC2308_SCLK bit 0xFA
LTC2308_ENN  bit 0xFB

;===================================================================
; SYSTEM PARAMETERS
;===================================================================
CLK   EQU 33333333
BAUD  EQU 57600
TIMER_2_RELOAD EQU (65536-(CLK/(32*BAUD)))

; Temperature measurement constants - CORRECTED
THERMOCOUPLE_GAIN_TIMES_CONVERSION_CONSTANT equ 12300 ; 300 * 41
VREF_VALUE equ 4096  ; CORRECTED: 4.096V = 4096 mV (was 4106)

;===================================================================
; INTERRUPT VECTORS
;===================================================================
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

;===================================================================
; MEMORY ALLOCATION
;===================================================================
DSEG at 30h
ref4040:            ds 4
COLD_JUNCTION_TEMP: ds 4
x:                  ds 4
y:                  ds 4
bcd:                ds 5

BSEG
mf: dbit 1

;===================================================================
; CODE SECTION
;===================================================================
CSEG

;-------------------------------------------------------------------
; Initialize Serial Port (using Timer 2)
;-------------------------------------------------------------------
Initialize_Serial_Port:
	mov RCAP2H, #high(TIMER_2_RELOAD)
	mov RCAP2L, #low(TIMER_2_RELOAD)
	mov T2CON, #0x34
	mov SCON, #0x52
	ret

;-------------------------------------------------------------------
; Send Character via Serial Port
;-------------------------------------------------------------------
putchar:
	jbc	TI,putchar_L1
	sjmp putchar
putchar_L1:
	mov	SBUF,a
	ret

;-------------------------------------------------------------------
; Send String via Serial Port
;-------------------------------------------------------------------
SendString:
    clr a
    movc a, @a+dptr
    jz SendString_L1
    inc dptr
    lcall putchar
    sjmp SendString  
SendString_L1:
	ret

;-------------------------------------------------------------------
; Initialize ADC
;-------------------------------------------------------------------
Initialize_ADC:
	clr	LTC2308_MOSI
	clr	LTC2308_SCLK
	setb LTC2308_ENN
	ret

;-------------------------------------------------------------------
; Toggle SPI Pins
;-------------------------------------------------------------------
LTC2308_Toggle_Pins:
    mov LTC2308_MOSI, c
    setb LTC2308_SCLK
    mov c, LTC2308_MISO
    clr LTC2308_SCLK
    ret

;-------------------------------------------------------------------
; LTC2308_RW: Read ADC channel
; Input: b = channel (0-7)
; Output: [R1,R0] = 12-bit result
; Must call TWICE to get current reading
;-------------------------------------------------------------------
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

;-------------------------------------------------------------------
; Include Math Library
;-------------------------------------------------------------------
$include(math32.inc)

;-------------------------------------------------------------------
; 50ms Delay
;-------------------------------------------------------------------
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

;-------------------------------------------------------------------
; Display Temperature on Serial Port
; Format: T=XXX.XX\r\n (3 digits, 2 decimals)
;-------------------------------------------------------------------
Display_Temp_Serial:
	mov a, #'T'
	lcall putchar
	mov a, #'='
	lcall putchar
	
	; Display hundreds digit
	mov a, bcd+2
	swap a
	anl a, #0FH
	orl a, #'0'
	lcall putchar
	
	; Display tens digit
	mov a, bcd+2
	anl a, #0FH
	orl a, #'0'
	lcall putchar
	
	; Display ones digit
	mov a, bcd+1
	swap a
	anl a, #0FH
	orl a, #'0'
	lcall putchar
	
	; Decimal point
	mov a, #'.'
	lcall putchar
	
	; Display first decimal digit
	mov a, bcd+1
	anl a, #0FH
	orl a, #'0'
	lcall putchar
	
	; Display second decimal digit
	mov a, bcd+0
	swap a
	anl a, #0FH
	orl a, #'0'
	lcall putchar
	
	; Carriage return and line feed
	mov a, #'\r'
	lcall putchar
	mov a, #'\n'
	lcall putchar
	
	ret

;===================================================================
; TEMPERATURE MEASUREMENT FUNCTIONS
;===================================================================

;-------------------------------------------------------------------
; Read LM4040 Reference Voltage ADC (Channel 0)
; Stores raw ADC result in ref4040
;-------------------------------------------------------------------
LM4040_ADC:
	mov b, #0                ; Channel 0 for LM4040
	lcall LTC2308_RW         ; First call (gets previous)
	lcall LTC2308_RW         ; Second call (gets current)
	
	; Load 32-bit 'ref4040' with 12-bit ADC result from [R1,R0]
	mov ref4040+3, #0
	mov ref4040+2, #0
	mov ref4040+1, R1
	mov ref4040+0, R0
	
	lcall Wait50ms
	ret

;-------------------------------------------------------------------
; Read LM335 Cold Junction Temperature (Channel 1)
; Formula: TC(°C×100) = ((VREF×ADCLM335/ADCREF) - 2730mV) / 10
; Result in COLD_JUNCTION_TEMP with 2 decimal places (×100)
;-------------------------------------------------------------------
LM335_ADC:
	mov b, #1                ; Channel 1 for LM335
	lcall LTC2308_RW         ; First call
	lcall LTC2308_RW         ; Second call
	
	; Load 32-bit 'x' with 12-bit ADC result from [R1,R0]
	mov x+3, #0
	mov x+2, #0
	mov x+1, R1
	mov x+0, R0
	
	; Calculate: VLM335(mV) = (VREF × ADCLM335) / ADCREF
	load_y(VREF_VALUE)       ; 4096 mV
	lcall mul32
	
	load_y(ref4040)          ; Divide by ADCREF
	lcall div32
	
	; Now x = VLM335 in millivolts
	; Calculate: TC = (VLM335 - 2730mV) / 10mV/°C
	load_y(2730)             ; 2.73V = 2730mV
	lcall sub32
	
	load_y(10)               ; 10mV per °C
	lcall div32
	
	; Result: TC in °C × 100 (2 decimal places)
	; Example: 25.67°C stored as 2567
	mov COLD_JUNCTION_TEMP+3, x+3
	mov COLD_JUNCTION_TEMP+2, x+2
	mov COLD_JUNCTION_TEMP+1, x+1
	mov COLD_JUNCTION_TEMP+0, x+0
	
	lcall Wait50ms
	ret

;-------------------------------------------------------------------
; Read Thermocouple and Calculate Temperature (Channel 2)
; Formula: TH(°C×100) = (VOP07(µV)×100)/(41µV/°C×Gain) + TC(°C×100)
; Result with 2 decimal places (×100)
;-------------------------------------------------------------------
adc_to_temp_to_serial:
	mov b, #2                ; Channel 2 for thermocouple
	lcall LTC2308_RW         ; First call
	lcall LTC2308_RW         ; Second call
	
	; Load 32-bit 'x' with 12-bit ADC result from [R1,R0]
	mov x+3, #0
	mov x+2, #0
	mov x+1, R1
	mov x+0, R0
	
	; Calculate: VOP07(mV) = (VREF × ADCOP07) / ADCREF
	load_y(VREF_VALUE)       ; 4096 mV
	lcall mul32
	
	load_y(ref4040)          ; Divide by ADCREF
	lcall div32
	
	; Now x = VOP07 in millivolts
	; Convert to microvolts and scale for 2 decimals:
	; VOP07(µV) × 100 = VOP07(mV) × 1000 × 100 = VOP07(mV) × 100000
	load_y(100000)           ; CORRECTED: was 1000000 (6 zeros)
	lcall mul32              ; Now 5 zeros for ×100 scaling
	
	; Divide by thermocouple sensitivity × gain
	; 41 µV/°C × 300 = 12300 µV/°C
	load_y(THERMOCOUPLE_GAIN_TIMES_CONVERSION_CONSTANT)
	lcall div32
	
	; Result: TH in °C × 100 (2 decimal places)
	; Add cold junction temperature (also °C × 100)
	load_y(COLD_JUNCTION_TEMP)
	lcall add32
	
	; Convert to BCD for display
	lcall hex2bcd
	
	; Send to serial port
	lcall Display_Temp_Serial
	
	lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
	
	ret

;===================================================================
; MAIN PROGRAM
;===================================================================
mycode:
	mov SP, #7FH
	
	; Initialize LEDs
	clr a
	mov LEDRA, a
	mov LEDRB, a
	
	; Initialize peripherals
	lcall Initialize_Serial_Port
	lcall Initialize_ADC
	lcall Wait50ms
	
	; Single measurement cycle
	lcall LM4040_ADC
	lcall LM335_ADC
	lcall adc_to_temp_to_serial
	
	; Uncomment for continuous readings:
	; main_loop:
	;     lcall LM4040_ADC
	;     lcall LM335_ADC
	;     lcall adc_to_temp_to_serial
	;     sjmp main_loop
	
	sjmp $  ; Halt

END
