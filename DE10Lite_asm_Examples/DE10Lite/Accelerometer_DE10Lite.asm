$MODMAX10

	CSEG at 0
	ljmp mycode

; ADXL345 connections
GSENSOR_SDI BIT 0xfd ; MOSI in SPI mode
GSENSOR_SDO BIT 0xfd ; MISO in SPI mode
GSENSOR_SCLK BIT 0xfe
GSENSOR_CS_n BIT 0xff
GSENSOR_INT1 BIT 0xfe
GSENSOR_INT2 BIT 0xff

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
    
SPI_ByteRW:
    mov   R6, #8
    mov   R7, #0          ; RX accumulator

SPI_Loop:
    ; --- MOSI valid before falling edge ---
    mov   C, ACC.7
    mov   GSENSOR_SDI, C

    ; --- Clock low (CPHA=1: shift on falling edge) ---
    clr   GSENSOR_SCLK
    rl    A               ; shift TX left

    ; --- Clock high: sample MISO ---
    setb  GSENSOR_SCLK
    mov   C, GSENSOR_SDO
    push  acc
    mov   a, R7
    rlc   a              ; shift RX in
    mov   R7, a
    pop   acc

    djnz  R6, SPI_Loop

    mov   a, R7
    ret

ADXL345_WriteReg:
    setb  GSENSOR_SCLK ; idle high
    clr   GSENSOR_CS_n
    mov   A, R0  ; address
    anl   A, #3Fh ; write, single-byte
    lcall SPI_ByteRW
    mov   A, R1 ; data
    lcall SPI_ByteRW
    setb  GSENSOR_CS_n
    ret

ADXL345_ReadReg:
    setb  GSENSOR_SCLK ; idle high
    clr   GSENSOR_CS_n
    orl   A, #80h ; read bit
    lcall SPI_ByteRW
    mov   A, #00h ; dummy
    lcall SPI_ByteRW ; read data
    setb  GSENSOR_CS_n
    ret


ADXL345_ReadXYZ_One_Byte:  
    mov   A, #0x32
    lcall ADXL345_ReadReg
    mov R0, A

    mov   A, #0x33
    lcall ADXL345_ReadReg
    mov R1, A

    mov   A, #0x34
    lcall ADXL345_ReadReg
    mov R2, A

    mov   A, #0x35
    lcall ADXL345_ReadReg
    mov R3, A

    mov   A, #0x36
    lcall ADXL345_ReadReg
    mov R4, A

    mov   A, #0x37
    lcall ADXL345_ReadReg
    mov R5, A

    ret

ADXL345_ReadXYZ:
    setb  GSENSOR_SCLK ; idle high
    clr   GSENSOR_CS_n

	mov   A, #0xF2        ; 0x32 | R/W (bit 7:1 = read) | MB = multi-byte read (bit 6:1 = multi-byte read)
	lcall SPI_ByteRW
	
	; Now read 6 bytes sequentially:
	lcall SPI_ByteRW
	mov R0, a             ; X LSB
	
	lcall SPI_ByteRW
	mov R1, a             ; X MSB
	
	lcall SPI_ByteRW
	mov R2, a             ; Y LSB
	
	lcall SPI_ByteRW
	mov R3, a             ; Y MSB
	
	lcall SPI_ByteRW
	mov R4, a             ; Z LSB
	
	lcall SPI_ByteRW
	mov R5, a             ; Z MSB
	
    setb  GSENSOR_CS_n
	ret

ADXL345_Configure:
	; DATA_FORMAT = ±2g, full resolution
	mov R0, #31h
	mov R1, #08h
	lcall ADXL345_WriteReg
	
	; POWER_CTL = Measure
	mov R0, #2Dh
	mov R1, #08h
	lcall ADXL345_WriteReg
	ret

mycode:
	mov SP, #7FH
	clr a
	mov LEDRA, a
	mov LEDRB, a
	mov dptr, #myLUT

	lcall ADXL345_Configure

forever:
	lcall ADXL345_ReadXYZ
	
Display_X:

	jb SWA.0, Display_Y
	jb SWA.1, Display_Y

	mov a, R1
	swap a
	anl a, #0x0f
	movc a, @dptr+a
	mov HEX3, a
	mov a, R1
	anl a, #0x0f
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
	
Display_Y:

	jnb SWA.0, Display_Z
	jb SWA.1, Display_Z

	mov a, R3
	swap a
	anl a, #0x0f
	movc a, @dptr+a
	mov HEX3, a
	mov a, R3
	anl a, #0x0f
	movc a, @dptr+a
	mov HEX2, a
	
	mov a, R2
	swap a
	anl a, #0x0f
	movc a, @dptr+a
	mov HEX1, a
	mov a, R2
	anl a, #0x0f
	movc a, @dptr+a
	mov HEX0, a
	lcall Wait50ms
	ljmp forever

Display_Z:

	jb SWA.0, Display_ID
	jnb SWA.1, Display_ID

	mov a, R5
	swap a
	anl a, #0x0f
	movc a, @dptr+a
	mov HEX3, a
	mov a, R5
	anl a, #0x0f
	movc a, @dptr+a
	mov HEX2, a
	
	mov a, R4
	swap a
	anl a, #0x0f
	movc a, @dptr+a
	mov HEX1, a
	mov a, R4
	anl a, #0x0f
	movc a, @dptr+a
	mov HEX0, a
	lcall Wait50ms
	ljmp forever

Display_ID:
	; The result of reading register 0x00 is 0xE5
	mov A, #00H
	lcall ADXL345_ReadReg
	mov R0,A

	mov HEX3, #0xFF
	mov HEX2, #0xFF
	
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
