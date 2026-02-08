;Raphael Jarreth Uriostegui Rosas 7/2/2026

;I have put the subroutine sending the temperature value (in the x variable)
;to the serial port here as a separate .inc file, that operates with the assumption
;that putchar is defined in some other place 

$NOLIST

CSEG

Display_Temp_Serial:

	;this chunk can and shall be removed if need be
	;	just adds the "T=" to "T=123.456"
	;------------------
	mov a, #'T'
	lcall putchar
	mov a, #'='
	lcall putchar
	;------------------
	
	
	mov a, bcd+3
	swap a
	anl a, #0FH ;bit masks to send the highest nibble of bcd+3 first via putchar
	orl a, #'0'
	lcall putchar
	
	mov a, bcd+3
	anl a, #0FH ;now sends the lower nibble
	orl a, #'0'
	lcall putchar
	
	;and this repeats for each bcd:

	mov a, bcd+2
	swap a
	anl a, #0FH
	orl a, #'0'
	lcall putchar
	
	mov a, bcd+2
	anl a, #0FH
	orl a, #'0'
	lcall putchar

	mov a, bcd+1
	swap a
	anl a, #0FH
	orl a, #'0'
	lcall putchar
	
	mov a, #'.'
	lcall putchar
	
	mov a, bcd+1
	anl a, #0FH
	orl a, #'0'
	lcall putchar

	mov a, bcd+0
	swap a
	anl a, #0FH
	orl a, #'0'
	lcall putchar
	
	mov a, bcd+0
	anl a, #0FH
	orl a, #'0'
	lcall putchar

	mov a, #'\r'
	lcall putchar
	mov a, #'\n'
	lcall putchar
	
	ret
	
$NOLIST