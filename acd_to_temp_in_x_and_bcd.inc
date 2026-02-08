; Raphael Jarreth Uriostegui Rosas 7/2/2026
;  I have put the code that converts the adc to the corresponding temperature here as 
;  a separate .inc file
;	it works by taking the value from an adc port defined here and converting it, placing it into
;	the bcd variable

$NOLIST

CSEG

adc_to_temp_to_serial:
	mov ADC_C, #0x00 ;ADC channel 0 is used
	
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

	load_y(VREF_VALUE);vref in microVolts (mV0)
	lcall mul32
	load_y(4095); calculating Vadc
	lcall div32
	load_y(1000000);1000 * 1000 (multing by 1000 to convert to microvolts (uV)and the extra 1000 is to keep the decimal places
	lcall mul32
	load_y(THERMOCOUPLE_GAIN_TIMES_CONVERSION_CONSTANT);41 * 300, (conversion constant * gain)
	lcall div32
	load_y(COLD_JUNCTION_TEMP)
	lcall add32 ;adding the cold junction temp to x, x now has the thermocouple temperature
		lcall hex2bcd ;puts the x value into the bcd variable
	
	ret
	
	
$NOLIST