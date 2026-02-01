$NOLIST
$MODDE2
$LIST
loop:
    mov R2, #90
L3: mov R1, #250
L2: mov R0, #250
L1: djnz R0, L1 ; 3 machine cycles-> 3*30ns*250=22.5us
    djnz R1, L2 ; 22.5us*250=5.625ms
    djnz R2, L3 ; 5.625ms*90=0.506s (approximately)
    cpl LEDRA.0
    sjmp loop
end
