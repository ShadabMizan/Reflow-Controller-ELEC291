; Blinky.asm: blinks LEDR0 of the CV-8052 each second.
$MODMAX10

org 0000H
	ljmp myprogram

$NOLIST
$include(math32.inc)
$include(filter.inc)
$LIST

ALPHA equ 300   ; ALPHA=(alpha/1000)

DSEG at 30H
x:      ds 4
y:      ds 4
bcd:    ds 5

tmp:    ds 4

BSEG
mf: dbit 1

CSEG
;For a 33.333333MHz clock, one machine cycle takes 30ns
WaitHalfSec:
	mov R2, #90
L3: mov R1, #250
L2: mov R0, #250
L1: djnz R0, L1 ; 3 machine cycles-> 3*30ns*250=22.5us
	djnz R1, L2 ; 22.5us*250=5.625ms
	djnz R2, L3 ; 5.625ms*90=0.506s (approximately)
	ret

myprogram:
	mov SP, #7FH ; Set the beginning of the stack (more on this later)
	mov LEDRA, #0 ; Turn off all unused LEDs (Too bright!)
	mov LEDRB, #0
M0:
	cpl LEDRA.0
	lcall WaitHalfSec

    lcall CalcOvenTemperature

	sjmp M0
END