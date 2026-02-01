$NOLIST
$MODMAX10
$LIST
	ljmp main
	
delay:
    mov R2, #90
L3: mov R1, #250
L2: mov R0, #250
L1: djnz R0, L1 ; 3 machine cycles-> 3*30ns*250=22.5us
    djnz R1, L2 ; 22.5us*250=5.625ms
    djnz R2, L3 ; 5.625ms*90=0.506s (approximately)
    ret

main:
	mov sp, #0x7f
	mov ledra, #0
	mov ledrb, #0
	mov P4MOD, #0xff
forever:	
	mov hex5, #0xff
	mov hex4, #0xe1
	mov hex3, #0x86
	mov hex2, #0x92
	mov hex1, #0xc1
	mov hex0, #0x92
	mov P4, #0x55
	lcall delay
	mov hex5, #0xff
	mov hex4, #0xff
	mov hex3, #0xff
	mov hex2, #0xff
	mov hex1, #0xff
	mov hex0, #0xff
	mov P4, #0xaa
	lcall delay

    sjmp forever
end
