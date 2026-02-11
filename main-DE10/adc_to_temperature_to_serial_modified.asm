;contains the subroutine to convert from the adc to the temperature, sending this to the serial port
;		I spent many hours making subroutines converting the adc to a temperature then 
;		sending values to the serial port only to find an example file that did most all of this functionality. 
;		then it took more hours trying to adapt that example file to what we needed.
;		The following is the result.

$MODMAX10



; ADC_C DATA 0xa1
; ADC_L DATA 0xa2
; ADC_H DATA 0xa3

	CSEG at 0
	ljmp mycode

dseg at 30h
ref4040: ds 4
COLD_JUNCTION_TEMP: ds 4
x:		ds	4
y:		ds	4
bcd:	ds	5

bseg

mf:		dbit 1

;-----------------------------------------------------------
;------------parameters to be had at the main function's ---
;------------initialization phase---------------------------
;-----------------------------------------------------------

CLK EQU 33333333
BAUD EQU 57600
TIMER_1_RELOAD EQU (256-((2*CLK)/(12*32*BAUD)))
TIMER_10ms EQU (65536-(CLK/(12*100)))

;COLD_JUNCTION_TEMP equ 22000 ;must make a variable for this i think
THERMOCOUPLE_GAIN_TIMES_CONVERSION_CONSTANT equ 12628 ; 300 * 41
VREF_VALUE equ 4116 ; changed to whatever it will be, inshal: measure lm4040d value then change

;-----------------------------------------------------------
;-----------------------------------------------------------
;-----------------------------------------------------------
;-----------------------------------------------------------

CSEG

;-----------------------------------------------------------;
;--------the following subroutine definitions should--------;
;--------be placed somewhere else in the main code file-----;
;-----------------------------------------------------------

InitSerialPort:
	; Configure serial port and baud rate
	clr TR1 ; Disable timer 1
	anl TMOD, #0x0f ; Mask the bits for timer 1
	orl TMOD, #0x20 ; Set timer 1 in 8-bit auto reload mode
    orl PCON, #80H ; Set SMOD to 1
	mov TH1, #low(TIMER_1_RELOAD)
	mov TL1, #low(TIMER_1_RELOAD) 
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
    

$include(math32.inc)

cseg

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

;-----------------------------------------------------------;
;--------------end of associated subroutine definitions-----;
;-----------------------------------------------------------;


mycode:
	mov SP, #7FH
	
;--------------------------------------------------;
;-----I believe the following chunk can be removed-;
;-----when copy/pasting the rest into main---------;
;--------------------------------------------------;
	clr a
	mov LEDRA, a
	mov LEDRB, a
	
	; so long as this is done somewhere else in the code
		lcall InitSerialPort 
		mov ADC_C, #0x80 ; Reset ADC
		lcall Wait50ms
	
;--------------------------------------------------;
;--------------------------------------------------;
;--------------------------------------------------;


;-----------------------------------------------;
;-------this is the subroutine that has the-----;
;-------adc->temperature->serial port ----------;
;---------functionality-------------------------;
;-----------------------------------------------;

;this is used to read the lm4040d adc value
LM4040_ADC:
	mov ADC_C, #0x00 ;ADC channel 0 is used
	
	; Load 32-bit 'x' with 12-bit adc result
	mov ref4040+3, #0
	mov ref4040+2, #0
	mov ref4040+1, ADC_H
	mov ref4040+0, ADC_L
	
	lcall Wait50ms
	
;we are purely reading adc value and storing it, no calculations
ret

;-------------------------------------------------------------------

;LM335 ADC gives cold junction temperature
LM335_ADC:
	mov ADC_C, #0x01 ;ADC channel 1 is used
	
	; Load 32-bit 'x' with 12-bit lm335 adc result
	mov x+3, #0
	mov x+2, #0
	mov x+1, ADC_H
	mov x+0, ADC_L
	
;	using equation 
;Vlm335 = (ADClm335/ADCref)*Vref, adcref here being the lm4040adc 
;Tc = (Vlm335 - 2730)mv / 10mv
	load_y(VREF_VALUE);vref in microVolts (mV0)
	lcall mul32

	load_y(ref4040); using adcref
	lcall div32

	load_y(2730);1000 * 1000 (multing by 1000 to convert to microvolts (uV)and the extra 1000 is to keep the decimal places
	lcall sub32

	load_y(10)
	lcall div32

	mov COLD_JUNCTION_TEMP+3, x+3
	mov COLD_JUNCTION_TEMP+2, x+2
	mov COLD_JUNCTION_TEMP+1, x+1
	mov COLD_JUNCTION_TEMP+0, x+0

	lcall Wait50ms

ret

;-------------------------------------------------------------------

adc_to_temp_to_serial:
	mov ADC_C, #0x02 ;ADC channel 2  is used
	
	; Load 32-bit 'x' with 12-bit adc result
	mov x+3, #0
	mov x+2, #0
	mov x+1, ADC_H
	mov x+0, ADC_L
	
;	using equation of the form
;			Temperature = Vadc / (41*10^(-6) * (R1/R2) ) + Cold Junction Temp
;				Where Vadc = Vref * ADC / 4095
;		and so:

; x has ADC
load_y(VREF_VALUE);vref in microVolts (mV0) lm4040
lcall mul32

load_y(ref4040); calculating Vadc, this is lm4040 adc value
lcall div32

load_y(100000);1000 * 1000 (multing by 1000 to convert to microvolts (uV)and the extra 1000 is to keep the decimal places
lcall mul32

load_y(THERMOCOUPLE_GAIN_TIMES_CONVERSION_CONSTANT);41 * 300, (conversion constant * gain)
lcall div32
;might need to tune the gain value to 308 or so,

load_y(COLD_JUNCTION_TEMP)
lcall add32 ;adding the cold junction temp to x, x now has the thermocouple temperature
	lcall hex2bcd
	
	
	lcall Display_Temp_Serial ;sending this ts to the serial port

	lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms
	lcall Wait50ms

	;sjmp adc_to_temp_to_serial ;comment this out, it was used for debugging

ret
	
end
