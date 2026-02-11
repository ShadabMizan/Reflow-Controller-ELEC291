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

; Bit-bang communication with the LTC2308 ADC.  Check Figure 8 in datasheet (page 17).
; Warning: we are reading the previously converted value!
; Configuration and channel is passed in [R1,R0].  Result is returned in [R1,R0].
; Note: The reference of this ADC is 4.096V
; Top view of ADC_CON, with the switches and pushbuttons facing the viewer:
;
;             ------
;      GND   | o  o |  ADC_IN 7
; ADC_IN 6   | o  o |  ADC_IN 5
; ADC_IN 4   | o  o    ADC_IN 3 (notch)
; ADC_IN 2   | o  o |  ADC_IN 1
; ADC_IN 0   | o  o |  5V
;             ------

LTC2308RW:
	mov R2, #12 ; SPI for this device consists of 12 bits
	clr ADC_ENN ; Enable LTC2308
LTC2308RW_loop:
	mov A, R1
	mov c, acc.3
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
	djnz R2, LTC2308RW_loop
	setb ADC_ENN ; Disable LTC2308
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
	
	mov R0, #0b10000000
	
	; ADC Channel selection is a bit confusing. So better follow table 1 in page 10 of the LTC2308 datasheet.
Channel0:
	cjne a, #0, Channel1
	mov R1, #0b00001000
	sjmp Channel_done
Channel1:
	cjne a, #1, Channel2
	mov R1, #0b00001100
	sjmp Channel_done
Channel2:
	cjne a, #2, Channel3
	mov R1, #0b00001001
	sjmp Channel_done
Channel3:
	cjne a, #3, Channel4
	mov R1, #0b00001101
	sjmp Channel_done
Channel4:
	cjne a, #4, Channel5
	mov R1, #0b00001010
	sjmp Channel_done
Channel5:
	cjne a, #5, Channel6
	mov R1, #0b00001110
	sjmp Channel_done
Channel6:
	cjne a, #6, Channel7
	mov R1, #0b00001011
	sjmp Channel_done
Channel7:
	mov R1, #0b00001111
Channel_done:
	lcall LTC2308RW
	
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
