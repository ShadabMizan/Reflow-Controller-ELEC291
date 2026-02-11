$MODDE1SOC

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

; Bit-bang communication with AD7928.  Check Figure 28 in datasheet (page 25).
; Configuration and channel is passed in [R1,R0].  Result is returned in [R1,R0].
; Note: The reference of this ADC is 5V
; Top view of ADC_CON, with the switches and pushbuttons facing the viewer:
;
;             ------
;      GND   | o  o |  ADC_IN 7
; ADC_IN 6   | o  o |  ADC_IN 5
; ADC_IN 4   | o  o    ADC_IN 3 (notch)
; ADC_IN 2   | o  o |  ADC_IN 1
; ADC_IN 0   | o  o |  5V
;             ------

AD7928RW:
	mov R2, #16 ; SPI for this device consists of 16 bits
	clr ADC_ENN ; Enable AD7928
	nop
	nop
	nop
AD7928RW_loop:
	mov A, R1
	mov c, acc.7
	mov ADC_MOSI, c
	setb ADC_SCLK
	mov c, ADC_MISO
	clr ADC_SCLK
	mov a, R0
	rlc a
	mov R0, a
	mov a, R1
	rlc a
	mov R1, a
	djnz R2, AD7928RW_loop
	setb ADC_ENN ; Disable AD7928
	mov a, R1
	anl a, #0x0f
	mov R1, a
	ret

mycode:
	mov SP, #7FH
	clr a
	mov LEDRA, a
	mov LEDRB, a
	mov dptr, #myLUT
	
	; Default for SPI pins
	clr ADC_MOSI
	clr ADC_SCLK
	setb ADC_ENN
	
forever:
	mov a, SWA ; The first three switches select the channel to read
	anl a, #0x07
	clr c
	rlc a
	rlc a
	orl a, #0b_100_000_11 ; After this instruction hannel to read is in bits 4 down to 2
	mov R1, a
	mov R0, #0b_0001_0000
	
	lcall AD7928RW
	
	mov a, R1
	movc a, @dptr+a
	mov HEX2, a
	mov a, R0
	swap a
	anl a, #0x0f
	movc a, @dptr+a
	mov HEX1, a
	mov a, R0
	anl a, #0x0f
	movc a, @dptr+a
	mov HEX0, a
	lcall Wait50ms
	ljmp forever
	
end
