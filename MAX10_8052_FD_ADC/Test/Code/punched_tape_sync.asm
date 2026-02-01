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
	
	mov dptr, #0x8101
	
forever:

	; Polling check of the sprocket bit
	jnb P1.0, $
	lcall debounce
	jnb P1.0, forever

	jb P1.0, $
	lcall debounce
	jb P1.0, forever

	; Now the tricky part.  We want to sample in the middle of the sprokect pulse
	; but we don't know how long is the sproket pulse.  So we sample from the
	; begining of the sproket pulse to the end, and take the value read in the middle.
		
	mov R0, #0x20 ; store samples from memory location 20h up to 60h, for 64 samples
poll_loop:
	lcall debounce
	mov a, P0
	cpl a
	mov @R0, a
	inc R0
	cjne R0, #0x60, poll_cont
	sjmp poll_done
poll_cont:
	jnb P1.0, poll_loop
poll_done:
	; Pick the value in the middle of the buffer
	mov a, R0
	add a, #0x20
	clr c
	rrc a ; divides by two
	mov R0, a
	mov a, @R0
	
	mov LEDRA, a
	mov b, a
	mov a, #0
	mov c, P1.0
	cpl c
	mov acc.1, c
	mov LEDRB, a
	
	; Write received ASCII to debugger buffer
	mov a, b
	cjne a, #0xff, Save_Char ; When we first insert paper, we get 0xff
	sjmp finish_message

Save_Char:	
	movx @dptr, a
	inc dptr
	sjmp forever
	
finish_message:
	mov a, #'\r'
	movx @dptr, a
	inc dptr
	mov a, #'\n'
	movx @dptr, a
	inc dptr	
	clr a
	movx @dptr, a ; zero terminate the string
	mov dptr, #0x8100
	mov a, #1 ; Tell debugger script to display buffer
	movx @dptr, a
	mov dptr, #0x8101 ; Start over
	
    sjmp forever

END    
