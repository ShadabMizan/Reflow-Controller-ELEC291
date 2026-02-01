$NOLIST
$MODMAX10
$LIST

    ljmp main

debounce:
	mov R7, #10
L1:	mov R6, #250
L2: djnz R6, L2 ; 3 cycles -> 3*250*30ns=22.5us
    djnz R7, L1 ; 22.5us*25=0.5625ms
    ret
 
main:
    mov sp, #0x7f
	mov LEDRA, #0
	mov LEDRB, #0
	
forever:
	jb KEY.1, $
	lcall debounce
	jb KEY.1, forever
	jnb KEY.1, $

	mov dptr, #0x8101
	mov R0, DPL
	mov R1, DPH
	mov dptr, #message
	mov R2, DPL
	mov R3, DPH
	
copy_loop:
	mov DPL, R2
	mov DPH, R3
	clr a
	movc a, @a+dptr
	jz copy_loop_done
	inc dptr
	mov R2, DPL
	mov R3, DPH
	mov DPL, R0
	mov DPH, R1
	movx @dptr, a
	inc dptr
	mov R0, DPL
	mov R1, DPH
	sjmp copy_loop

copy_loop_done:
	mov DPL, R0
	mov DPH, R1
	movx @dptr, a
	mov dptr, #0x8100
	mov a, #1 ; Tell debugger script to display buffer
	movx @dptr, a

    sjmp forever
    
message: db 'This is a simple message.\r\n'

END    
