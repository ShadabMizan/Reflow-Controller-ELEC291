; Non_Blocking_FSM_example.asm:  Four FSMs are run in the forever loop.
; Three FSMs are used to detect (with debounce) when either KEY1, KEY2, or
; KEY3 are pressed.  The fourth FSM keeps a counter (Count3) that is incremented
; every second.  When KEY1 is detected the program increments/decrements Count1,
; depending on the position of SW0. When KEY2 is detected the program
; increments/decrements Count2, also base on the position of SW0.  When KEY3
; is detected, the program resets Count3 to zero.  
;
$NOLIST
$MODDE1SOC
$LIST

CLK           EQU 33333333 ; Microcontroller system crystal frequency in Hz
TIMER2_RATE   EQU 1000     ; 1000Hz, for a timer tick of 1ms
TIMER2_RELOAD EQU ((65536-(CLK/(12*TIMER2_RATE))))

; Reset vector
org 0x0000
    ljmp main

; Timer/Counter 2 overflow interrupt vector
org 0x002B
	ljmp Timer2_ISR

dseg at 0x30
; Each FSM has its own timer
FSM1_timer: ds 1
FSM2_timer: ds 1
FSM3_timer: ds 1
FSM4_timer: ds 1
; Each FSM has its own state counter
FSM1_state: ds 1
FSM2_state: ds 1
FSM3_state: ds 1
FSM4_state: ds 1
; Three counters to display.
Count1:     ds 1 ; Incremented/decremented when KEY1 is pressed.
Count2:     ds 1 ; Incremented/decremented when KEY2 is pressed.
Count3:     ds 1 ; Incremented every second. Reset to zero when KEY3 is pressed.

bseg
; For each pushbutton we have a flag.  The corresponding FSM will set this
; flags to one when a valid press of the pushbutton is detected.
Key1_flag: dbit 1
Key2_flag: dbit 1
Key3_flag: dbit 1

cseg
;---------------------------------;
; Routine to initialize the ISR   ;
; for timer 2                     ;
;---------------------------------;
Timer2_Init:
	mov T2CON, #0 ; Stop timer/counter.  Autoreload mode.
	mov TH2, #high(TIMER2_RELOAD)
	mov TL2, #low(TIMER2_RELOAD)
	; Set the reload value
	mov RCAP2H, #high(TIMER2_RELOAD)
	mov RCAP2L, #low(TIMER2_RELOAD)
	; Enable the timer and interrupts
    setb ET2  ; Enable timer 2 interrupt
    setb TR2  ; Enable timer 2
	ret

;---------------------------------;
; ISR for timer 2.  Runs evere ms ;
;---------------------------------;
Timer2_ISR:
	clr TF2  ; Timer 2 doesn't clear TF2 automatically. Do it in ISR
	; Increment the timers for each FSM. That is all we do here!
	inc FSM1_timer 
	inc FSM2_timer 
	inc FSM3_timer 
	inc FSM4_timer 
	reti

; Look-up table for the 7-seg displays. (Segments are turn on with zero) 
T_7seg:
    DB 40H, 79H, 24H, 30H, 19H, 12H, 02H, 78H, 00H, 10H

; Displays a BCD number pased in R0 in HEX1-HEX0
Display_BCD_7_Seg_HEX10:
	mov dptr, #T_7seg

	mov a, R0
	swap a
	anl a, #0FH
	movc a, @a+dptr
	mov HEX1, a
	
	mov a, R0
	anl a, #0FH
	movc a, @a+dptr
	mov HEX0, a
	
	ret

; Displays a BCD number pased in R0 in HEX3-HEX2
Display_BCD_7_Seg_HEX32:
	mov dptr, #T_7seg

	mov a, R0
	swap a
	anl a, #0FH
	movc a, @a+dptr
	mov HEX3, a
	
	mov a, R0
	anl a, #0FH
	movc a, @a+dptr
	mov HEX2, a
	
	ret

; Displays a BCD number pased in R0 in HEX5-HEX4
Display_BCD_7_Seg_HEX54:
	mov dptr, #T_7seg

	mov a, R0
	swap a
	anl a, #0FH
	movc a, @a+dptr
	mov HEX5, a
	
	mov a, R0
	anl a, #0FH
	movc a, @a+dptr
	mov HEX4, a
	
	ret

; The 8-bit hex number passed in the accumulator is converted to
; BCD and stored in [R1, R0]
Hex_to_bcd_8bit:
	mov b, #100
	div ab
	mov R1, a   ; After dividing, a has the 100s
	mov a, b    ; Remainder is in register b
	mov b, #10
	div ab ; The tens are stored in a, the units are stored in b 
	swap a
	anl a, #0xf0
	orl a, b
	mov R0, a
	ret

;---------------------------------;
; Main program. Includes hardware ;
; initialization and 'forever'    ;
; loop.                           ;
;---------------------------------;
main:
	; Initialization of hardware
    mov SP, #0x7F
    lcall Timer2_Init
    ; Turn off all the LEDs
    mov LEDRA, #0 ; LEDRA is bit addressable
    mov LEDRB, #0 ; LEDRB is NOT bit addresable
    setb EA   ; Enable Global interrupts
    
    ; Initialize variables
    mov FSM1_state, #0
    mov FSM2_state, #0
    mov FSM3_state, #0
    mov FSM4_state, #0
    mov Count1, #0
    mov Count2, #0
    mov Count3, #0
    
    ; Display the initial value of each counter
    mov a, Count1
    lcall Hex_to_bcd_8bit
	lcall Display_BCD_7_Seg_HEX10
    mov a, Count2
    lcall Hex_to_bcd_8bit
	lcall Display_BCD_7_Seg_HEX32
    mov a, Count3
    lcall Hex_to_bcd_8bit
	lcall Display_BCD_7_Seg_HEX54
	
	; After initialization the program stays in this 'forever' loop
loop:

;-------------------------------------------------------------------------------
; non-blocking state machine for KEY1 starts here
	mov a, FSM1_state
FSM1_state0:
	cjne a, #0, FSM1_state1
	jb KEY.1, FSM1_done
	mov FSM1_timer, #0
	inc FSM1_state
	sjmp FSM1_done
FSM1_state1:
	cjne a, #1, FSM1_state2
	; this is the debounce state
	mov a, FSM1_timer
	cjne a, #50, FSM1_done ; 50 ms passed?
	inc FSM1_state
	sjmp FSM1_done	
FSM1_state2:
	cjne a, #2, FSM1_state3
	jb KEY.1, FSM1_state2b
	inc FSM1_state
	sjmp FSM1_done	
FSM1_state2b:
	mov FSM1_state, #0
	sjmp FSM1_done
FSM1_state3:
	cjne a, #3, FSM1_done
	jnb KEY.1, FSM1_done
	setb Key1_flag ; Suscesfully detected a valid KEY1 press/release
	mov FSM1_state, #0	
FSM1_done:
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; non-blocking state machine for KEY2 starts here
	mov a, FSM2_state
FSM2_state0:
	cjne a, #0, FSM2_state1
	jb KEY.2, FSM2_done
	mov FSM2_timer, #0
	inc FSM2_state
	sjmp FSM2_done
FSM2_state1:
	cjne a, #1, FSM2_state2
	; this is the debounce state
	mov a, FSM2_timer
	cjne a, #50, FSM2_done ; 50 ms passed?
	inc FSM2_state
	sjmp FSM2_done	
FSM2_state2:
	cjne a, #2, FSM2_state3
	jb KEY.2, FSM2_state2b
	inc FSM2_state
	sjmp FSM2_done	
FSM2_state2b:
	mov FSM2_state, #0
	sjmp FSM2_done
FSM2_state3:
	cjne a, #3, FSM2_done
	jnb KEY.2, FSM2_done
	setb Key2_flag ; Suscesfully detected a valid KEY2 press/release
	mov FSM2_state, #0	
FSM2_done:
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; non-blocking state machine for KEY3 starts here
	mov a, FSM3_state
FSM3_state0:
	cjne a, #0, FSM3_state1
	jb KEY.3, FSM3_done
	mov FSM3_timer, #0
	inc FSM3_state
	sjmp FSM3_done
FSM3_state1:
	cjne a, #1, FSM3_state2
	; this is the debounce state
	mov a, FSM3_timer
	cjne a, #50, FSM3_done ; 50 ms passed?
	inc FSM3_state
	sjmp FSM3_done	
FSM3_state2:
	cjne a, #2, FSM3_state3
	jb KEY.3, FSM3_state2b
	inc FSM3_state
	sjmp FSM3_done	
FSM3_state2b:
	mov FSM3_state, #0
	sjmp FSM3_done
FSM3_state3:
	cjne a, #3, FSM3_done
	jnb KEY.3, FSM3_done
	setb Key3_flag ; Suscesfully detected a valid KEY3 press/release
	mov FSM3_state, #0	
FSM3_done:
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; non-blocking FSM for the one second counter starts here.
	mov a, FSM4_state
	mov LEDRA, #0
FSM4_state0:
	cjne a, #0, FSM4_state1
	setb LEDRA.0 ; We are using the LEDs to debug in what state is this machine
	mov a, FSM4_timer
	cjne a, #250, FSM4_done ; 250 ms passed? (Since we are usend an 8-bit variable, we need to count 250 ms four times)
	mov FSM4_timer, #0
	inc FSM4_state
	sjmp FSM4_done
FSM4_state1:	
	cjne a, #1, FSM4_state2
	setb LEDRA.1
	mov a, FSM4_timer
	cjne a, #250, FSM4_done ; 250 ms passed?
	mov FSM4_timer, #0
	inc FSM4_state
	sjmp FSM4_done
FSM4_state2:	
	cjne a, #2, FSM4_state3
	setb LEDRA.2
	mov a, FSM4_timer
	cjne a, #250, FSM4_done ; 250 ms passed?
	mov FSM4_timer, #0
	inc FSM4_state
	sjmp FSM4_done
FSM4_state3:	
	cjne a, #3, FSM4_done
	setb LEDRA.3
	mov a, FSM4_timer
	cjne a, #250, FSM4_done ; 250 ms passed?
	mov FSM4_timer, #0
	mov FSM4_state, #0
	mov a, Count3
	cjne a, #59, IncCount3 ; Don't let the seconds counter pass 59
	mov Count3, #0
	sjmp DisplayCount3
IncCount3:
	inc Count3
DisplayCount3:
    mov a, Count3
    lcall Hex_to_bcd_8bit
	lcall Display_BCD_7_Seg_HEX54
	mov FSM4_state, #0
FSM4_done:
;-------------------------------------------------------------------------------


; If KEY1 was detected, increment or decrement Count1.  Notice that we are displying only
; the least two signicant digits of a counter that can have values from 0 to 255.
	jbc Key1_flag, Increment_Count1
	sjmp Skip_Count1
Increment_Count1:
	jb SWA.0, Decrement_Count1
	inc Count1
	sjmp Display_Count1
Decrement_Count1:
	dec Count1
Display_Count1:	
    mov a, Count1
    lcall Hex_to_bcd_8bit
	lcall Display_BCD_7_Seg_HEX10
Skip_Count1:

; If KEY2 was detected, increment or decrement Count2.  Notice that we are displying only
; the least two signicant digits of a counter that can have values from 0 to 255.
	jbc Key2_flag, Increment_Count2
	sjmp Skip_Count2
Increment_Count2:
	jb SWA.0, Decrement_Count2
	inc Count2
	sjmp Display_Count2
Decrement_Count2:
	dec Count2
Display_Count2:	
    mov a, Count2
    lcall Hex_to_bcd_8bit
	lcall Display_BCD_7_Seg_HEX32
Skip_Count2:

; When KEY3 is pressed/released it resets the one second counter (Count3)
	jbc Key3_flag, Clear_Count3
	sjmp Skip_Count3
Clear_Count3:
    mov Count3, #0
    ; Reset also the state machine for the one second counter and its timer
    mov FSM4_state, #0
	mov FSM4_timer, #0
	; Display the new count
    mov a, Count3
    lcall Hex_to_bcd_8bit
	lcall Display_BCD_7_Seg_HEX54
Skip_Count3:

    ljmp loop
END
