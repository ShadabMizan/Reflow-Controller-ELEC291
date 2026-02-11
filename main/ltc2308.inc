;===================================================================
; Bits used to access the LTC2308
;===================================================================
LTC2308_MISO bit 0xF8 ; Read only bit
LTC2308_MOSI bit 0xF9 ; Write only bit
LTC2308_SCLK bit 0xFA ; Write only bit
LTC2308_ENN  bit 0xFB ; Write only bit

; Temperature measurement constants
THERMOCOUPLE_GAIN_TIMES_CONVERSION_CONSTANT equ 12300 ; 300 * 41
VREF_VALUE equ 4106  ; Reference voltage in mV (adjust as needed)

; In DSEG:
; ref4040:            ds 4
; COLD_JUNCTION_TEMP: ds 4

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

