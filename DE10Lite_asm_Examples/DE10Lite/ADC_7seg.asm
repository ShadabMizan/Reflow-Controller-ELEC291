$MODMAX10

; The Special Function Registers below were added to 'MODMAX10' recently.
; If you are getting an error, uncomment the three lines below.

; ADC_C DATA 0xa1
; ADC_L DATA 0xa2
; ADC_H DATA 0xa3

	CSEG at 0
	ljmp mycode

; Look-up table for 7-seg displays
myLUT:
    DB 0xC0, 0xF9, 0xA4, 0xB0, 0x99        ; 0 TO 4
    DB 0x92, 0x82, 0xF8, 0x80, 0x90        ; 4 TO 9
    DB 0x88, 0x83, 0xC6, 0xA1, 0x86, 0x8E  ; A to F

Wait50ms:
;33.33MHz, 1 clk per cycle: 0.03us
	mov R0, #30
L3: mov R1, #74
L2: mov R2, #250
L1: djnz R2, L1 ;3*250*0.03us=22.5us
    djnz R1, L2 ;74*22.5us=1.665ms
    djnz R0, L3 ;1.665ms*30=50ms
    ret

mycode:
	mov SP, #7FH
	clr a
	mov LEDRA, a
	mov LEDRB, a
	mov dptr, #myLUT
	
	mov ADC_C, #0x80 ; Reset ADC
	lcall Wait50ms

forever:
	mov a, SWA ; The first three switches select the channel to read
	anl a, #0x07
	mov ADC_C, a
	mov a, ADC_H
	movc a, @dptr+a
	mov HEX2, a
	mov a, ADC_L
	swap a
	anl a, #0x0f
	movc a, @dptr+a
	mov HEX1, a
	mov a, ADC_L
	anl a, #0x0f
	movc a, @dptr+a
	mov HEX0, a
	lcall Wait50ms
	ljmp forever
	
end
