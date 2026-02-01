$modde0cv

	CSEG at 0
	ljmp mycode

	DSEG at 30H
x:      ds 4
y:      ds 4
sx:     ds 4
sy:     ds 4
bcd:	ds 5
op:     ds 1

	BSEG
mf:     dbit 1

	CSEG

$include(math32.asm)

; Look-up table for 7-seg displays
myLUT:
    DB 0C0H, 0F9H, 0A4H, 0B0H, 099H        ; 0 TO 4
    DB 092H, 082H, 0F8H, 080H, 090H        ; 5 TO 9
    DB 088H, 083H, 0C6H, 0A1H, 086H, 08EH  ; A to F

showBCD MAC
	; Display LSD
    mov A, %0
    anl a, #0fh
    movc A, @A+dptr
    mov %1, A
	; Display MSD
    mov A, %0
    swap a
    anl a, #0fh
    movc A, @A+dptr
    mov %2, A
ENDMAC

Display:
	mov dptr, #myLUT
	showBCD(bcd+0, HEX0, HEX1)
	showBCD(bcd+1, HEX2, HEX3)
	showBCD(bcd+2, HEX4, HEX5)
    ret

MYRLC MAC
	mov a, %0
	rlc a
	mov %0, a
ENDMAC

Shift_Digits:
	mov R0, #4 ; shift left four bits
Shift_Digits_L0:
	clr c
	MYRLC(bcd+0)
	MYRLC(bcd+1)
	MYRLC(bcd+2)
	MYRLC(bcd+3)
	MYRLC(bcd+4)
	djnz R0, Shift_Digits_L0
	; R7 has the new bcd digit	
	mov a, R7
	orl a, bcd+0
	mov bcd+0, a
	; bcd+3 and bcd+4 don't fit so make them zero
	clr a
	mov bcd+3, a
	mov bcd+4, a
	ret

Wait50ms:
;33.33MHz, 1 clk per cycle: 0.03us
	mov R0, #30
L3: mov R1, #74
L2: mov R2, #250
L1: djnz R2, L1 ;3*250*0.03us=22.5us
    djnz R1, L2 ;74*22.5us=1.665ms
    djnz R0, L3 ;1.665ms*30=50ms
    ret

; Check if SW0 to SW9 are toggled up.  Returns the toggled switch in
; R7.  If the carry is not set, no toggling switches were detected.
ReadNumber:
	mov r4, SWA ; Read switches 0 to 7
	mov r5, SWB ; Read switches 8 to 15
	mov a, r4
	orl a, r5
	jz ReadNumber_no_number
	lcall Wait50ms ; debounce
	mov a, SWA
	clr c
	subb a, r4
	jnz ReadNumber_no_number ; it was a bounce
	mov a, SWB
	clr c
	subb a, r5
	jnz ReadNumber_no_number ; it was a bounce
	mov r7, #16 ; Loop counter
ReadNumber_L0:
	clr c
	mov a, r4
	rlc a
	mov r4, a
	mov a, r5
	rlc a
	mov r5, a
	jc ReadNumber_decode
	djnz r7, ReadNumber_L0
	sjmp ReadNumber_no_number	
ReadNumber_decode:
	dec r7
	setb c
ReadNumber_L1:
	mov a, SWA
	jnz ReadNumber_L1
ReadNumber_L2:
	mov a, SWB
	jnz ReadNumber_L2
	ret
ReadNumber_no_number:
	clr c
	ret

; Binary search of "floor square root" for 32-bit number in x
sqrt32:
	; Save all used registers in the stack
	push acc
	push psw
	push AR0
	push AR1
	push AR2
	push AR3
	push AR4
	push AR5
	push AR6
	push AR7

	; Original value saved in [R5, R4, R3, R2]
	mov R5, x+3
	mov R4, x+2
	mov R3, x+1
	mov R2, x+0
	
	; Bit mask
	mov R7, #0x80
	mov R6, #0x00
	; Partial result
	mov R1, #0x00
	mov R0, #0x00
	
sqrt32_L1:
	mov a, R7
	orl a, R1
	mov R1, a
	mov a, R6
	orl a, R0
	mov R0, a  

    ; Square partial result
	mov x+3, #0	
	mov x+2, #0
	mov x+1, R1
    mov x+0, R0
	mov y+3, #0	
	mov y+2, #0
	mov y+1, R1
	mov y+0, R0
	lcall mul32

	; Compare the square with the original number
	mov y+3, R5
	mov y+2, R4
	mov y+1, R3
	mov y+0, R2
    lcall x_gt_y
    jnb mf, root32_L2
    ; The square is too big.  Clear the bit we just tested
	mov a, R7
	cpl a
	anl a, R1
	mov R1, a
	mov a, R6
	cpl a
	anl a, R0
	mov R0, a  
root32_L2: 
	; Shift the mask RIGHT one bit and clear the most significant bit
	clr c
	mov a, R7
	rrc a
	mov R7, a
	mov a, R6
	rrc a
	mov R6, a
	; If we tested all the bits both R7 and R6 are zero
	orl a, R7
	jnz sqrt32_L1
	
	; Copy the result to x
	mov x+3, #0	
	mov x+2, #0
	mov x+1, R1
	mov x+0, R0
    
    ; Restore all saved resgisters from the stack	
	pop AR7
	pop AR6
	pop AR5
	pop AR4
	pop AR3
	pop AR2
	pop AR1
	pop AR0
	pop psw
	pop acc

	ret
	
mycode:
	mov SP, #7FH
	clr a
	mov LEDRA, a
	mov LEDRB, a
	Load_x(0)
	Load_y(0)
	mov bcd+0, a
	mov bcd+1, a
	mov bcd+2, a
	mov bcd+3, a
	mov bcd+4, a
	mov op, a
	lcall Display

	mov b, #0           ; b=0:addition, b=1:subtraction, etc.

forever:
	; This is a good spot to set the LEDs for each operation
	mov a, b
	cjne a, #0, $+6
	mov LEDRA, #0x01
	cjne a, #1, $+6
	mov LEDRA, #0x02
	cjne a, #2, $+6
	mov LEDRA, #0x04
	cjne a, #3, $+6
	mov LEDRA, #0x08
	cjne a, #4, $+6
	mov LEDRA, #0x10
	cjne a, #5, $+6
	mov LEDRA, #0x20

	jb KEY.3, no_funct  ; If 'Function' key not pressed, skip
	jnb KEY.3, $        ; Wait for release of 'Function' key
	inc b               ; 'b' is used as function select 
	mov a, b            ; make sure b is not larger than 5
    cjne a, #6, forever ; ^
	mov b, #0           ; ^
	ljmp forever        ; Go check for more input

no_funct:
	jb KEY.2, no_load   ; If 'Load' key not pressed, skip
	jnb KEY.2, $        ; Wait for user to release 'Load' key
	lcall bcd2hex       ; Convert the BCD number to hex in x
	lcall copy_xy       ; Copy x to y
    Load_X(0)           ; Clear x (this is a macro)
	lcall hex2bcd       ; Convert result in x to BCD
	lcall Display       ; Display the new BCD number
	ljmp forever        ; Go check for more input

no_load:
	jb KEY.1, no_equalt ; If 'equal' key not pressed, skip
	sjmp equalt
no_equalt:
	ljmp no_equal
equalt:
	jnb KEY.1, $        ; Wait for user to release 'equal' key
	lcall bcd2hex       ; Convert the BCD number to hex in x

	mov a, b
    cjne a, #0, no_add  ; Addition?
	lcall add32         ; Perform x+y
	lcall hex2bcd       ; Convert result in x to BCD
	lcall Display       ; Display the new BCD number
	ljmp forever        ; Go check for more input
no_add:
    cjne a, #1, no_sub  ; Subtraction?
    lcall xchg_xy       ;
	lcall sub32         ; Perform x-y
	lcall hex2bcd       ; Convert result in x to BCD
	lcall Display       ; Display the new BCD number
	ljmp forever        ; Go check for more input
no_sub:
    cjne a, #2, no_mul  ; Multiplication?
	lcall mul32         ; Perform x*y
	lcall hex2bcd       ; Convert result in x to BCD
	lcall Display       ; Display the new BCD number
	ljmp forever        ; Go check for more input
no_mul:
    cjne a, #3, no_div  ; Division?
    lcall xchg_xy       ;
	lcall div32         ; Perform x/y
	lcall hex2bcd       ; Convert result in x to BCD
	lcall Display       ; Display the new BCD number
	ljmp forever        ; Go check for more input
no_div:
	cjne a, #4, no_remainder
    lcall xchg_xy       ;
    mov sx+0, x+0
    mov sx+1, x+1
    mov sx+2, x+2
    mov sx+3, x+3
    mov sy+0, y+0
    mov sy+1, y+1
    mov sy+2, y+2
    mov sy+3, y+3
	lcall div32
    mov y+0, sy+0
    mov y+1, sy+1
    mov y+2, sy+2
    mov y+3, sy+3
    lcall mul32
    lcall xchg_xy
    mov x+0, sx+0
    mov x+1, sx+1
    mov x+2, sx+2
    mov x+3, sx+3
    lcall sub32
	lcall hex2bcd       ; Convert result in x to BCD
	lcall Display       ; Display the new BCD number
	ljmp forever        ; Go check for more input
no_remainder:
	cjne a, #5, no_isqrt
	lcall sqrt32
	lcall hex2bcd       ; Convert result in x to BCD
	lcall Display       ; Display the new BCD number
	ljmp forever        ; Go check for more input	
no_isqrt:
	
no_equal:
	; get more numbers       
	lcall ReadNumber
	jnc no_new_digit    ; Indirect jump to 'forever'
	lcall Shift_Digits
	lcall Display
no_new_digit:
	ljmp forever ; 'forever' is to far away, need to use ljmp
	
end
