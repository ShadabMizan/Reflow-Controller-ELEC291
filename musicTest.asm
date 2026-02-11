; Buzzer Musical Scale Program for CV-8052 on DE10-SoC
; Uses Timer 0 in Mode 1 (16-bit timer) for accurate frequency generation
; Buzzer connected to P3.5 (or adjust as needed)

$NOLIST
$MODLP51
$LIST

; Assume CV-8052 running at 33.33 MHz (typical for DE10-SoC configuration)
; Timer reload values for musical notes
; Formula: Reload = 65536 - (CLK_FREQ / (12 * 2 * NOTE_FREQ))
; Using CLK_FREQ = 33,333,000 Hz

; Note definitions (Timer 0 reload values for square wave generation)
C4_H    EQU HIGH(65536 - 53191)  ; C4 = 261.63 Hz
C4_L    EQU LOW(65536 - 53191)
D4_H    EQU HIGH(65536 - 47396)  ; D4 = 293.66 Hz
D4_L    EQU LOW(65536 - 47396)
E4_H    EQU HIGH(65536 - 42225)  ; E4 = 329.63 Hz
E4_L    EQU LOW(65536 - 42225)
F4_H    EQU HIGH(65536 - 39850)  ; F4 = 349.23 Hz
F4_L    EQU LOW(65536 - 39850)
G4_H    EQU HIGH(65536 - 35501)  ; G4 = 392.00 Hz
G4_L    EQU LOW(65536 - 35501)
A4_H    EQU HIGH(65536 - 31618)  ; A4 = 440.00 Hz
A4_L    EQU LOW(65536 - 31618)
B4_H    EQU HIGH(65536 - 28166)  ; B4 = 493.88 Hz
B4_L    EQU LOW(65536 - 28166)
C5_H    EQU HIGH(65536 - 26596)  ; C5 = 523.25 Hz
C5_L    EQU LOW(65536 - 26596)

BUZZER_PIN EQU P3.5  ; Change this to match your hardware connection

DSEG at 30H
note_counter: DS 2   ; Counter for note duration

CSEG

org 0000H
    ljmp main

; Timer 0 Interrupt - toggles buzzer pin
org 000BH
    cpl BUZZER_PIN      ; Toggle buzzer pin
    reti

org 0030H
main:
    mov SP, #7FH
    
    ; Configure Timer 0
    ; Mode 1: 16-bit timer
    anl TMOD, #0F0H     ; Clear Timer 0 bits
    orl TMOD, #01H      ; Set Timer 0 to Mode 1
    
    ; Enable Timer 0 interrupt
    setb ET0            ; Enable Timer 0 interrupt
    setb EA             ; Enable global interrupts
    
play_scale_loop:
    ; Play C4
    mov TH0, #C4_H
    mov TL0, #C4_L
    lcall play_note
    lcall delay_between
    
    ; Play D4
    mov TH0, #D4_H
    mov TL0, #D4_L
    lcall play_note
    lcall delay_between
    
    ; Play E4
    mov TH0, #E4_H
    mov TL0, #E4_L
    lcall play_note
    lcall delay_between
    
    ; Play F4
    mov TH0, #F4_H
    mov TL0, #F4_L
    lcall play_note
    lcall delay_between
    
    ; Play G4
    mov TH0, #G4_H
    mov TL0, #G4_L
    lcall play_note
    lcall delay_between
    
    ; Play A4
    mov TH0, #A4_H
    mov TL0, #A4_L
    lcall play_note
    lcall delay_between
    
    ; Play B4
    mov TH0, #B4_H
    mov TL0, #B4_L
    lcall play_note
    lcall delay_between
    
    ; Play C5
    mov TH0, #C5_H
    mov TL0, #C5_L
    lcall play_note
    lcall delay_between
    
    lcall long_delay    ; Pause before repeating
    ljmp play_scale_loop

;--------------------------------------------
; Play note for approximately 500ms
;--------------------------------------------
play_note:
    setb TR0            ; Start Timer 0
    
    ; Delay for note duration (~500ms)
    mov R3, #20
note_duration_loop:
    mov R2, #0
    mov R1, #0
inner_delay:
    djnz R1, inner_delay
    djnz R2, inner_delay
    djnz R3, note_duration_loop
    
    clr TR0             ; Stop Timer 0
    clr BUZZER_PIN      ; Ensure buzzer is off
    ret

;--------------------------------------------
; Short delay between notes (~100ms)
;--------------------------------------------
delay_between:
    mov R4, #5
delay_outer1:
    mov R3, #0
    mov R2, #0
delay_inner1:
    djnz R2, delay_inner1
    djnz R3, delay_inner1
    djnz R4, delay_outer1
    ret

;--------------------------------------------
; Long delay (~1 second)
;--------------------------------------------
long_delay:
    mov R5, #10
long_outer:
    mov R4, #0
    mov R3, #0
long_inner:
    djnz R3, long_inner
    djnz R4, long_inner
    djnz R5, long_outer
    ret

END
