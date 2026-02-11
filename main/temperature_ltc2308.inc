;===================================================================
; TEMPERATURE READING MODULE - LTC2308 ADC
; Include file for Reflow Oven Controller
; 
; This module provides temperature measurement using:
; - LTC2308 12-bit ADC
; - Type-K Thermocouple (Channel 2) with amplifier (Gain=300)
; - LM335 Cold Junction Sensor (Channel 1)
; - LM4040 Voltage Reference (Channel 0)
;
; USAGE:
;   $INCLUDE(temperature_ltc2308.inc)
;   lcall Read_Temperature        ; Updates 'temp' variable
;   lcall Send_Temp_To_Serial     ; Optional: outputs to serial
;
; REQUIREMENTS:
;   - math32.inc must be included BEFORE this file
;   - Variables x, y, bcd must be defined (from math32)
;   - Variable 'temp' must be defined (1 byte)
;   - Serial port must be initialized (for optional serial output)
;
; HARDWARE CONNECTIONS:
;   LTC2308_MISO (bit 0xF8) - SPI data input
;   LTC2308_MOSI (bit 0xF9) - SPI data output  
;   LTC2308_SCLK (bit 0xFA) - SPI clock
;   LTC2308_ENN  (bit 0xFB) - Chip enable (active low)
;
; ADC CHANNELS:
;   Channel 0: LM4040 4.096V reference
;   Channel 1: LM335 cold junction sensor
;   Channel 2: Thermocouple amplifier output
;===================================================================

;-------------------------------------------------------------------
; BIT DEFINITIONS FOR LTC2308 ADC
;-------------------------------------------------------------------
LTC2308_MISO bit 0xF8 ; Read only bit
LTC2308_MOSI bit 0xF9 ; Write only bit
LTC2308_SCLK bit 0xFA ; Write only bit
LTC2308_ENN  bit 0xFB ; Write only bit

;-------------------------------------------------------------------
; TEMPERATURE MEASUREMENT CONSTANTS
;-------------------------------------------------------------------
THERMOCOUPLE_GAIN_TIMES_CONVERSION_CONSTANT equ 12300 ; 300 * 41
VREF_VALUE equ 4106  ; Reference voltage in mV (4.096V, adjust if needed)

;-------------------------------------------------------------------
; VARIABLES FOR TEMPERATURE MODULE
; Note: x, y, bcd are already defined by math32.inc
;-------------------------------------------------------------------
DSEG
ref4040:            ds 4    ; LM4040 reference ADC reading
COLD_JUNCTION_TEMP: ds 4    ; Cold junction temperature in °C
temp_raw:           ds 4    ; Raw temperature before conversion to byte

CSEG
;===================================================================
; INITIALIZATION FUNCTION
;===================================================================
;-------------------------------------------------------------------
; Initialize_ADC
; 
; Initializes the SPI interface to the LTC2308 ADC
; Must be called once during startup before using Read_Temperature
;
; MODIFIES: LTC2308 control pins
; RETURNS: Nothing
;-------------------------------------------------------------------
Initialize_ADC:
    clr  LTC2308_MOSI
    clr  LTC2308_SCLK
    setb LTC2308_ENN      ; Disable ADC (active low)
    ret

;===================================================================
; LOW-LEVEL ADC COMMUNICATION FUNCTIONS
;===================================================================
;-------------------------------------------------------------------
; LTC2308_Toggle_Pins
;
; Helper function for bit-banged SPI communication
; Sends one bit on MOSI, receives one bit from MISO
;
; INPUT: c = bit to send
; OUTPUT: c = bit received
; MODIFIES: SCLK, MOSI pins
;-------------------------------------------------------------------
LTC2308_Toggle_Pins:
    mov LTC2308_MOSI, c   ; Output bit to MOSI
    setb LTC2308_SCLK     ; Clock high
    mov c, LTC2308_MISO   ; Read bit from MISO
    clr LTC2308_SCLK      ; Clock low
    ret

;-------------------------------------------------------------------
; LTC2308_RW
;
; Performs a complete SPI transaction with the LTC2308
; Sends channel selection and receives 12-bit ADC result
;
; INPUT: b = channel number (0-7)
; OUTPUT: R1 = bits [11:8] of result
;         R0 = bits [7:0] of result
;
; IMPORTANT: Due to the LTC2308 architecture, this function returns
; the PREVIOUS conversion result, not the current channel.
; Always call TWICE to get the desired channel reading:
;   mov b, #2
;   lcall LTC2308_RW   ; Starts conversion on channel 2
;   lcall LTC2308_RW   ; Returns channel 2 result
;
; MODIFIES: A, c, R0, R1, LTC2308 pins
;-------------------------------------------------------------------
LTC2308_RW:
    clr a 
    clr LTC2308_ENN       ; Enable ADC (active low)

    ; ===== COMMAND PHASE: Send channel selection =====
    ; Bit 0: S/D (Single-ended/Differential)
    setb c                ; S/D=1 for single ended conversion
    lcall LTC2308_Toggle_Pins
    mov acc.3, c          ; Receive bit 11 of previous conversion
    
    ; Bit 1: O/S (Odd/Sign channel select)
    mov c, b.2            ; O/S from channel bit 2
    lcall LTC2308_Toggle_Pins
    mov acc.2, c          ; Receive bit 10
    
    ; Bit 2: S1 (Select bit 1)
    mov c, b.0            ; S1 from channel bit 0
    lcall LTC2308_Toggle_Pins
    mov acc.1, c          ; Receive bit 9
    
    ; Bit 3: S0 (Select bit 0)
    mov c, b.1            ; S0 from channel bit 1
    lcall LTC2308_Toggle_Pins
    mov acc.0, c          ; Receive bit 8
    mov R1, a             ; Save upper 4 bits
    
    ; ===== CONFIGURATION PHASE: Send operating mode =====
    clr a 
    
    ; Bit 4: UNI (Unipolar/Bipolar)
    setb c                ; UNI=1 for unipolar output mode
    lcall LTC2308_Toggle_Pins
    mov acc.7, c          ; Receive bit 7
    
    ; Bit 5: SLP (Sleep mode)
    clr c                 ; SLP=0 for NAP mode (fast wake-up)
    lcall LTC2308_Toggle_Pins
    mov acc.6, c          ; Receive bit 6
    
    ; Bits 6-11: Don't care bits (send 0)
    clr c
    lcall LTC2308_Toggle_Pins
    mov acc.5, c          ; Receive bit 5
    
    clr c
    lcall LTC2308_Toggle_Pins
    mov acc.4, c          ; Receive bit 4
    
    clr c
    lcall LTC2308_Toggle_Pins
    mov acc.3, c          ; Receive bit 3
    
    clr c
    lcall LTC2308_Toggle_Pins
    mov acc.2, c          ; Receive bit 2
    
    clr c
    lcall LTC2308_Toggle_Pins
    mov acc.1, c          ; Receive bit 1
    
    clr c
    lcall LTC2308_Toggle_Pins
    mov acc.0, c          ; Receive bit 0
    
    mov R0, a             ; Save lower 8 bits

    setb LTC2308_ENN      ; Disable ADC

    ret

;===================================================================
; TEMPERATURE MEASUREMENT FUNCTIONS
;===================================================================
;-------------------------------------------------------------------
; LM4040_ADC
;
; Reads the LM4040 4.096V reference voltage from ADC channel 0
; This provides the reference for all other measurements
;
; OUTPUT: ref4040 = 32-bit ADC reading (0-4095)
; MODIFIES: A, b, R0, R1, x, y (from math operations)
;-------------------------------------------------------------------
LM4040_ADC:
    mov b, #0             ; Channel 0 for LM4040
    lcall LTC2308_RW      ; First call (gets previous conversion)
    lcall LTC2308_RW      ; Second call (gets channel 0 conversion)
    
    ; Load 32-bit 'ref4040' with 12-bit ADC result from [R1,R0]
    mov ref4040+3, #0
    mov ref4040+2, #0
    mov ref4040+1, R1
    mov ref4040+0, R0
    
    ret

;-------------------------------------------------------------------
; LM335_ADC
;
; Reads the LM335 cold junction temperature sensor from channel 1
; The LM335 outputs 10mV/°K, with 2.73V at 0°C (273°K)
;
; Formula: Tc = ((ADClm335/ADCref)*Vref - 2730mV) / (10mV/°C)
;
; OUTPUT: COLD_JUNCTION_TEMP = temperature in °C (32-bit signed)
; MODIFIES: A, b, R0, R1, x, y (from math operations)
;-------------------------------------------------------------------
LM335_ADC:
    mov b, #1             ; Channel 1 for LM335
    lcall LTC2308_RW      ; First call (gets previous conversion)
    lcall LTC2308_RW      ; Second call (gets channel 1 conversion)
    
    ; Load 32-bit 'x' with 12-bit ADC result from [R1,R0]
    mov x+3, #0
    mov x+2, #0
    mov x+1, R1
    mov x+0, R0
    
    ; Calculate: Vlm335 = (ADClm335/ADCref)*Vref
    load_y(VREF_VALUE)    ; Vref in millivolts
    lcall mul32
    
    load_y(ref4040)       ; Divide by reference ADC
    lcall div32
    
    load_y(2730)          ; Subtract 2730mV (0°C offset: 273°K * 10mV)
    lcall sub32
    
    load_y(10)            ; Divide by 10mV/°C sensitivity
    lcall div32
    
    ; Store result
    mov COLD_JUNCTION_TEMP+3, x+3
    mov COLD_JUNCTION_TEMP+2, x+2
    mov COLD_JUNCTION_TEMP+1, x+1
    mov COLD_JUNCTION_TEMP+0, x+0
    
    ret

;-------------------------------------------------------------------
; Read_Thermocouple_ADC
;
; Reads the amplified thermocouple voltage from ADC channel 2
; Type-K thermocouple has ~41µV/°C sensitivity
; Signal is amplified by a gain of 300 before the ADC
;
; Formula: T = Vadc / (41µV/°C * Gain) + Tcold
; Where: Vadc = Vref * ADC / ADCref
;
; OUTPUT: temp_raw = temperature in °C (32-bit)
; MODIFIES: A, b, R0, R1, x, y (from math operations)
;-------------------------------------------------------------------
Read_Thermocouple_ADC:
    mov b, #2             ; Channel 2 for thermocouple
    lcall LTC2308_RW      ; First call (gets previous conversion)
    lcall LTC2308_RW      ; Second call (gets channel 2 conversion)
    
    ; Load 32-bit 'x' with 12-bit ADC result from [R1,R0]
    mov x+3, #0
    mov x+2, #0
    mov x+1, R1
    mov x+0, R0
    
    ; Calculate Vadc in microvolts
    ; Step 1: Vadc_mV = (ADC / ADCref) * Vref
    load_y(VREF_VALUE)    ; Vref in millivolts
    lcall mul32
    
    load_y(ref4040)       ; Calculate Vadc in mV
    lcall div32
    
    ; Step 2: Convert mV to µV (multiply by 1000000 for precision)
    load_y(1000000)       ; Convert to microvolts
    lcall mul32
    
    ; Step 3: Divide by thermocouple sensitivity * gain
    ; 41 µV/°C * 300 (gain) = 12300 µV/°C
    load_y(THERMOCOUPLE_GAIN_TIMES_CONVERSION_CONSTANT)
    lcall div32
    
    ; Step 4: Add cold junction temperature compensation
    load_y(COLD_JUNCTION_TEMP)
    lcall add32
    
    ; Store result in temp_raw
    mov temp_raw+3, x+3
    mov temp_raw+2, x+2
    mov temp_raw+1, x+1
    mov temp_raw+0, x+0
    
    ret

;===================================================================
; MAIN TEMPERATURE READING FUNCTION
;===================================================================
;-------------------------------------------------------------------
; Read_Temperature
;
; Complete temperature measurement sequence:
; 1. Reads reference voltage (LM4040)
; 2. Reads cold junction temperature (LM335)
; 3. Reads thermocouple and compensates for cold junction
; 4. Converts result to single byte (0-255°C)
;
; This is the main function to call from your reflow oven code.
; It updates the 'temp' variable with the current temperature.
;
; OUTPUT: temp = temperature in °C (8-bit, 0-255)
; MODIFIES: All ADC variables, x, y, math variables
;
; EXAMPLE USAGE IN MAIN LOOP:
;   Forever:
;       lcall Read_Temperature  ; Updates 'temp' with current reading
;       mov a, temp            ; Use temperature value
;       ; ... rest of code
;-------------------------------------------------------------------
Read_Temperature:
    push acc
    push psw
    
    ; Step 1: Read reference voltage
    lcall LM4040_ADC
    
    ; Step 2: Read cold junction temperature
    lcall LM335_ADC
    
    ; Step 3: Read thermocouple and calculate temperature
    lcall Read_Thermocouple_ADC
    
    ; Step 4: Convert 32-bit temperature to 8-bit byte
    ; Take the low byte of temp_raw (assumes temp < 256°C)
    mov a, temp_raw+0
    mov temp, a
    
    ; Optional: Clamp to valid range (0-255)
    ; If temperature is negative (MSB set in temp_raw+3), set to 0
    mov a, temp_raw+3
    jnb acc.7, Temp_Not_Negative
    mov temp, #0          ; Clamp negative temps to 0
    sjmp Temp_Done
    
Temp_Not_Negative:
    ; If temperature > 255, clamp to 255
    mov a, temp_raw+1
    jz Temp_In_Range      ; If upper bytes are 0, temp is in range
    mov temp, #255        ; Clamp to max
    sjmp Temp_Done
    
Temp_In_Range:
    ; Temperature is valid, already stored in temp
    
Temp_Done:
    pop psw
    pop acc
    ret

;===================================================================
; OPTIONAL: SERIAL OUTPUT FUNCTION
;===================================================================
;-------------------------------------------------------------------
; Send_Temp_To_Serial
;
; Outputs formatted temperature to serial port
; Format: "T=XXX.XX°C\r\n"
;
; Uses the BCD conversion from math32.inc to display with 
; decimal precision
;
; REQUIRES: 
;   - putchar function available
;   - temp_raw variable contains valid 32-bit temperature
;
; MODIFIES: A, DPTR, bcd, x
;-------------------------------------------------------------------
Send_Temp_To_Serial:
    push acc
    
    ; Convert temperature to BCD for display
    mov x+3, temp_raw+3
    mov x+2, temp_raw+2
    mov x+1, temp_raw+1
    mov x+0, temp_raw+0
    lcall hex2bcd
    
    ; Output "T="
    mov a, #'T'
    lcall putchar
    mov a, #'='
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
    
    ; Decimal point
    mov a, #'.'
    lcall putchar
    
    ; Display first decimal digit
    mov a, bcd+1
    swap a
    anl a, #0FH
    orl a, #'0'
    lcall putchar
    
    ; Display second decimal digit
    mov a, bcd+1
    anl a, #0FH
    orl a, #'0'
    lcall putchar
    
    ; Output "°C"
    mov a, #0xDF          ; Degree symbol (if supported)
    lcall putchar
    mov a, #'C'
    lcall putchar
    
    ; Carriage return and line feed
    mov a, #'\r'
    lcall putchar
    mov a, #'\n'
    lcall putchar
    
    pop acc
    ret

;===================================================================
; END OF TEMPERATURE MODULE
;===================================================================
