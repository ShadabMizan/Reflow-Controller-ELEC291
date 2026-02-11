;===================================================================
; CV-8052 Temperature Measurement with Thermocouple
; Adapted for DE1-SoC Board with LTC2308
; Uses LTC2308_RW function from Jesus Calvino-Fraga's test program
;===================================================================

$NOLIST
$MODDE1SOC
$LIST

;===================================================================
; Bits used to access the LTC2308
;===================================================================
LTC2308_MISO bit 0xF8 ; Read only bit
LTC2308_MOSI bit 0xF9 ; Write only bit
LTC2308_SCLK bit 0xFA ; Write only bit
LTC2308_ENN  bit 0xFB ; Write only bit

;===================================================================
; SYSTEM PARAMETERS
;===================================================================
CLK   EQU 33333333
BAUD  EQU 57600
TIMER_2_RELOAD EQU (65536-(CLK/(32*BAUD)))

; Temperature measurement constants
THERMOCOUPLE_GAIN_TIMES_CONVERSION_CONSTANT equ 12628 ; 308 * 41
VREF_VALUE equ 4106  ; Reference voltage in mV (adjust as needed)

;===================================================================
; RESET AND INTERRUPT VECTORS
;===================================================================
org 0x0000
	ljmp mycode

; External interrupt 0 vector (not used in this code)
org 0x0003
	reti

; Timer/Counter 0 overflow interrupt vector (not used in this code)
org 0x000B
	reti

; External interrupt 1 vector (not used in this code)
org 0x0013
	reti

; Timer/Counter 1 overflow interrupt vector (not used in this code)
org 0x001B
	reti

; Serial port receive/transmit interrupt vector (not used in this code)
org 0x0023 
	reti
	
; Timer/Counter 2 overflow interrupt vector (not used in this code)
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
    ; Initialize serial port and baud rate using timer 2
	mov RCAP2H, #high(TIMER_2_RELOAD)
	mov RCAP2L, #low(TIMER_2_RELOAD)
	mov T2CON, #0x34 ; #00110100B
	mov SCON, #0x52 ; Serial port in mode 1, ren, txrdy, rxempty
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
	; Initialize SPI pins connected to LTC2308
	clr	LTC2308_MOSI
	clr	LTC2308_SCLK
	setb LTC2308_ENN
	ret

;-------------------------------------------------------------------
; Toggle SPI Pins (helper function for LTC2308_RW)
;-------------------------------------------------------------------
LTC2308_Toggle_Pins:
    mov LTC2308_MOSI, c
    setb LTC2308_SCLK
    mov c, LTC2308_MISO
    clr LTC2308_SCLK
    ret

;-------------------------------------------------------------------
; LTC2308_RW: Bit-bang communication with LTC2308
; From Jesus Calvino-Fraga's test program
; 
; Channel to read passed in register 'b'
; Result in R1 (bits 11 downto 8) and R0 (bits 7 downto 0)
; 
; WARNING: Returns PREVIOUSLY converted channel!
; Call this function TWICE to read current channel value
;-------------------------------------------------------------------
LTC2308_RW:
    clr a 
	clr	LTC2308_ENN ; Enable ADC

    ; Send 'S/D', get bit 11
    setb c ; S/D=1 for single ended conversion
    lcall LTC2308_Toggle_Pins
    mov acc.3, c
    ; Send channel bit 0, get bit 10
    mov c, b.2 ; O/S odd channel select
    lcall LTC2308_Toggle_Pins
    mov acc.2, c 
    ; Send channel bit 1, get bit 9
    mov c, b.0 ; S1
    lcall LTC2308_Toggle_Pins
    mov acc.1, c
    ; Send channel bit 2, get bit 8
    mov c, b.1 ; S0
    lcall LTC2308_Toggle_Pins
    mov acc.0, c
    mov R1, a
    
    ; Now receive the least significant eight bits
    clr a 
    ; Send 'UNI', get bit 7
    setb c ; UNI=1 for unipolar output mode
    lcall LTC2308_Toggle_Pins
    mov acc.7, c
    ; Send 'SLP', get bit 6
    clr c ; SLP=0 for NAP mode
    lcall LTC2308_Toggle_Pins
    mov acc.6, c
    ; Send '0', get bit 5
    clr c
    lcall LTC2308_Toggle_Pins
    mov acc.5, c
    ; Send '0', get bit 4
    clr c
    lcall LTC2308_Toggle_Pins
    mov acc.4, c
    ; Send '0', get bit 3
    clr c
    lcall LTC2308_Toggle_Pins
    mov acc.3, c
    ; Send '0', get bit 2
    clr c
    lcall LTC2308_Toggle_Pins
    mov acc.2, c
    ; Send '0', get bit 1
    clr c
    lcall LTC2308_Toggle_Pins
    mov acc.1, c
    ; Send '0', get bit 0
    clr c
    lcall LTC2308_Toggle_Pins
    mov acc.0, c
    mov R0, a

	setb LTC2308_ENN ; Disable ADC

	ret

;-------------------------------------------------------------------
; Include Math Library (from your original code)
;-------------------------------------------------------------------
$include(math32.inc)

;-------------------------------------------------------------------
; 50ms Delay (from your original code)
;-------------------------------------------------------------------
Wait50ms:
	mov R2, #30
Wait50ms_L3:
	mov R3, #74
Wait50ms_L2:
	mov R4, #250
Wait50ms_L1:
	djnz R4, Wait50ms_L1  ; 3*250*0.03us=22.5us
	djnz R3, Wait50ms_L2  ; 74*22.5us=1.665ms
	djnz R2, Wait50ms_L3  ; 1.665ms*30=50ms
	ret

;-------------------------------------------------------------------
; Display Temperature on Serial Port (from your original code)
; Format: T=XXXX.XX\r\n
;-------------------------------------------------------------------
Display_Temp_Serial:
	mov a, #'T'
	lcall putchar
	mov a, #'='
	lcall putchar
	
	; Display thousands digit
	mov a, bcd+3
	swap a
	anl a, #0FH
	orl a, #'0'
	lcall putchar
	
	; Display hundreds digit
	mov a, bcd+3
	anl a, #0FH
	orl a, #'0'
	lcall putchar
	
	; Display tens digit
	mov a, bcd+2
	swap a
	anl a, #0FH
	orl a, #'0'
	lcall putchar
	
	; Display ones digit
	mov a, bcd+2
	anl a, #0FH
	orl a, #'0'
	lcall putchar
	
	; Display first decimal digit
	mov a, bcd+1
	swap a
	anl a, #0FH
	orl a, #'0'
	lcall putchar
	
	; Decimal point
	mov a, #'.'
	lcall putchar
	
	; Display second decimal digit
	mov a, bcd+1
	anl a, #0FH
	orl a, #'0'
	lcall putchar
	
	; Display third decimal digit
	mov a, bcd+0
	swap a
	anl a, #0FH
	orl a, #'0'
	lcall putchar
	
	; Display fourth decimal digit
	mov a, bcd+0
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
; Stores result in ref4040
; Calls LTC2308_RW TWICE to get current reading
;-------------------------------------------------------------------
LM4040_ADC:
	mov b, #0                ; Channel 0 for LM4040
	lcall LTC2308_RW         ; First call (gets previous conversion)
	lcall LTC2308_RW         ; Second call (gets channel 0 conversion)
	
	; Load 32-bit 'ref4040' with 12-bit ADC result from [R1,R0]
	mov ref4040+3, #0
	mov ref4040+2, #0
	mov ref4040+1, R1
	mov ref4040+0, R0
	
	lcall Wait50ms
	ret

;-------------------------------------------------------------------
; Read LM335 Cold Junction Temperature (Channel 1)
; Formula: Tc = ((ADClm335/ADCref)*Vref - 2730mV) / 10mV
; Stores result in COLD_JUNCTION_TEMP
;-------------------------------------------------------------------
LM335_ADC:
	mov b, #1                ; Channel 1 for LM335
	lcall LTC2308_RW         ; First call (gets previous conversion)
	lcall LTC2308_RW         ; Second call (gets channel 1 conversion)
	
	; Load 32-bit 'x' with 12-bit ADC result from [R1,R0]
	mov x+3, #0
	mov x+2, #0
	mov x+1, R1
	mov x+0, R0
	
	; Calculate: Vlm335 = (ADClm335/ADCref)*Vref
	load_y(VREF_VALUE)       ; Vref in millivolts
	lcall mul32
	
	load_y(ref4040)          ; Divide by reference ADC
	lcall div32
	
	load_y(2730)             ; Subtract 2730mV (0°C offset)
	lcall sub32
	
	load_y(10)               ; Divide by 10mV/°C sensitivity
	lcall div32
	
	; Store result
	mov COLD_JUNCTION_TEMP+3, x+3
	mov COLD_JUNCTION_TEMP+2, x+2
	mov COLD_JUNCTION_TEMP+1, x+1
	mov COLD_JUNCTION_TEMP+0, x+0
	
	lcall Wait50ms
	ret

;-------------------------------------------------------------------
; Read Thermocouple and Calculate Temperature (Channel 2)
; Formula: T = Vadc / (41µV/°C * Gain) + Tcold
; Where: Vadc = Vref * ADC / ADCref
; Sends result to serial port
;-------------------------------------------------------------------
adc_to_temp_to_serial:
	mov b, #2                ; Channel 2 for thermocouple
	lcall LTC2308_RW         ; First call (gets previous conversion)
	lcall LTC2308_RW         ; Second call (gets channel 2 conversion)
	
	; Load 32-bit 'x' with 12-bit ADC result from [R1,R0]
	mov x+3, #0
	mov x+2, #0
	mov x+1, R1
	mov x+0, R0
	
	; Calculate Vadc in microvolts
	;load_y(VREF_VALUE)
	load_y(326)       ; Vref in millivolts
	lcall mul32
	
	load_y(ref4040)          ; Calculate Vadc
	lcall div32
	
	;load_y(1000)          ; Convert to microvolts (x1000 twice for decimal places)
	;lcall mul32
	
	; Divide by thermocouple sensitivity * gain
	;load_y(THERMOCOUPLE_GAIN_TIMES_CONVERSION_CONSTANT) ; 41 * 308
	;lcall div32
	; Note: might need to tune the gain value to 308 or so -> edit feb 10, 2026, 10:39: thumbs up emoji
	
	; Add cold junction temperature
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
	
	; Initialize serial port
	lcall Initialize_Serial_Port
	
	; Initialize ADC
	lcall Initialize_ADC
	
	lcall Wait50ms
	
	; Read reference voltage
	lcall LM4040_ADC
	
	; Read cold junction temperature
	lcall LM335_ADC
	
	; Read thermocouple and display result
	lcall adc_to_temp_to_serial
	
	; Infinite loop - uncomment for continuous readings
	; main_loop:
	;     lcall LM4040_ADC
	;     lcall LM335_ADC
	;     lcall adc_to_temp_to_serial
	;     sjmp main_loop
	
	sjmp $  ; Halt here

END
