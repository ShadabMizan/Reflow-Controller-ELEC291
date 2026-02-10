;-----------------------------------------;
;    REFLOW CONTROLLER WITH PS/2 INPUT    ;
;                                         ;
;  Combines keyboard input and command    ;
;  interpreter for reflow oven control    ;
;                                         ;
;     Syntax: set <PARAMETER> <VALUE>     ;
;             get <PARAMETER>             ;
;             start                       ;
;-----------------------------------------;
$NOLIST
$MODDE1SOC
$LIST

CLK EQU 33333333
TIMER_10ms EQU (65536-(CLK/(12*100)))

;PS/2 Interface
PS2_DAT BIT P3.3

;Shared memory between keyboard and compiler
INPUT_BUFFER    EQU 30h     ;Buffer for keyboard input (up to 80 chars)
INPUT_PTR       DATA 80h    ;Current position in buffer
COMMAND_READY   BIT 20h.0   ;Set when Enter key pressed

;Compiler temporary values
TEMP_VALUE_H    DATA 94h
TEMP_VALUE_L    DATA 95h

;Reflow parameters
SOAK_TEMP_H     DATA 60h
SOAK_TEMP_L     DATA 61h
SOAK_TIME_H     DATA 62h
SOAK_TIME_L     DATA 63h
REFLOW_TEMP_H   DATA 64h
REFLOW_TEMP_L   DATA 65h
REFLOW_TIME_H   DATA 66h
REFLOW_TIME_L   DATA 67h

;Token pointers
TOKEN1_PTR      DATA 90h
TOKEN2_PTR      DATA 91h
TOKEN3_PTR      DATA 92h
TOKEN_COUNT     DATA 93h 

;Flags
MATCH_FLAG      BIT 98h.0
START_FLAG      BIT 98h.1
RELEASE_FLAG    BIT 98h.2

;PS/2 state registers
PS2_BIT_COUNT   DATA 81h    ;Current bit being read (R0 in original)
PS2_DATA_REG    DATA 82h    ;Accumulated scancode data (R1 in original)

cseg
    ljmp MainProgram
    
    ;Interrupt on PS/2 keypress at address 0003h
    org 0003h
    ljmp PS2_Interrupt

;--------------------------------------------
; String literals for command parsing
;--------------------------------------------
    org 0080h
StartStr: 
    db 'start',0
GetStr: 
    db 'get',0
SetStr: 
    db 'set',0
SoakTempStr:    
    db 'soaktemp',0
SoakTimeStr:    
    db 'soaktime',0
ReflowTempStr:  
    db 'reflowtemp',0
ReflowTimeStr:  
    db 'reflowtime',0

;--------------------------------------------
; Scancode to ASCII lookup table
;--------------------------------------------
    org 0100h
ASCII_TABLE:
    DB 0, 0, 0, 0, 0, 0, 0, 0        ; 00-07
    DB 0, 0, 0, 0, 0, 0, '`', 0      ; 08-0F
    DB 0, 0, 0, 0, 0, 'q', '1', 0    ; 10-17
    DB 0, 0, 'z', 's', 'a', 'w', '2', 0  ; 18-1F
    DB 0, 'c', 'x', 'd', 'e', '4', '3', 0  ; 20-27
    DB 0, ' ', 'v', 'f', 't', 'r', '5', 0  ; 28-2F
    DB 0, 'n', 'b', 'h', 'g', 'y', '6', 0  ; 30-37
    DB 0, 0, 'm', 'j', 'u', '7', '8', 0    ; 38-3F
    DB 0, ',', 'k', 'i', 'o', '0', '9', 0  ; 40-47
    DB 0, '.', '/', 'l', ';', 'p', '-', 0  ; 48-4F
    DB 0, 0, 27h, 0, '[', '=', 0, 0        ; 50-57 (27h = apostrophe)
    DB 0, 0, 0, ']', 0, 5Ch, 0, 0          ; 58-5F (5Ch = backslash)
    DB 0, 0, 0, 0, 0, 0, 0, 0              ; 60-67
    DB 0, 0, 0, 0, 0, 0, 0, 0              ; 68-6F
    DB 0, 0, 0, 0, 0, 0, 0, 0              ; 70-77
    DB 0, 0, 0, 0, 0, 0, 0, 0              ; 78-7F

;============================================
; INITIALIZATION ROUTINES
;============================================

Initialize_System:
    ;Initialize compiler variables
    mov SOAK_TEMP_H, #0
    mov SOAK_TEMP_L, #0
    mov SOAK_TIME_H, #0
    mov SOAK_TIME_L, #0
    mov REFLOW_TEMP_H, #0
    mov REFLOW_TEMP_L, #0
    mov REFLOW_TIME_H, #0
    mov REFLOW_TIME_L, #0
    clr START_FLAG
    clr MATCH_FLAG
    mov TOKEN_COUNT, #0
    
    ;Initialize PS/2 interface
    setb PS2_DAT
    setb IT0         ;Edge-triggered external interrupts
    setb EX0         ;Enable external interrupt 0
    setb EA          ;Enable global interrupts
    mov PS2_BIT_COUNT, #0
    mov PS2_DATA_REG, #0
    clr RELEASE_FLAG
    
    ;Initialize input buffer
    mov INPUT_PTR, #0
    clr COMMAND_READY
    
    ret

;============================================
; PS/2 KEYBOARD HANDLER
;============================================

Scancode_To_ASCII:
    ;Input: A = scancode
    ;Output: A = ASCII (or 0 if not valid)
    mov DPTR, #ASCII_TABLE
    movc A, @A+DPTR
    ret

PS2_Interrupt:
    push ACC
    push PSW
    
    mov A, PS2_BIT_COUNT
    ;If we're at the start of a frame, validate start bit
    cjne A, #0, NotAtStart
    mov C, PS2_DAT
    jc PS2_Done    ;If start bit is 1, wait for valid start (should be 0)
    
NotAtStart:
    inc PS2_BIT_COUNT
    mov A, PS2_BIT_COUNT
    ;Ignore start bit (bit 0)
    cjne A, #1, CheckData
    sjmp PS2_Done
    
CheckData:
    ;Read data bits (bits 1-8)
    clr C
    subb A, #10      ;Carry set if A < 10 (bits 1-9)
    jnc CheckIfDone
    mov C, PS2_DAT   ;Read data line
    mov A, PS2_DATA_REG
    rrc A            ;Shift bit into accumulator
    mov PS2_DATA_REG, A
    mov A, PS2_BIT_COUNT
    cjne A, #9, PS2_Done
    
    ;We've read all 8 data bits
    mov A, PS2_DATA_REG
    cjne A, #0F0h, NotRelease
    setb RELEASE_FLAG ;0xF0 is release code
    sjmp PS2_Done
    
NotRelease:
    ;Check if this is a key release (ignore if RELEASE_FLAG is set)
    jb RELEASE_FLAG, ClearRel
    
    ;Check for ENTER key (scancode 0x5A)
    cjne A, #5Ah, NotEnter
    ;ENTER pressed - set command ready flag and reset buffer pointer
    setb COMMAND_READY
    ;Null-terminate the buffer
    mov R0, INPUT_PTR
    add A, #INPUT_BUFFER
    mov R0, A
    mov @R0, #0
    mov INPUT_PTR, #0
    sjmp PS2_Done
    
NotEnter:
    ;Check for BACKSPACE key (scancode 0x66)
    cjne A, #66h, NotBackspace
    ;Backspace - decrement buffer pointer if not at start
    mov A, INPUT_PTR
    jz PS2_Done
    dec INPUT_PTR
    sjmp PS2_Done
    
NotBackspace:
    ;Convert scancode to ASCII
    lcall Scancode_To_ASCII
    ;Only process if valid ASCII (non-zero)
    jz PS2_Done
    
    ;Add character to input buffer
    mov R2, A        ;Save ASCII character
    mov A, INPUT_PTR
    ;Check for buffer overflow (max 80 chars)
    cjne A, #80, BufferOK
    sjmp PS2_Done    ;Buffer full, ignore character
    
BufferOK:
    add A, #INPUT_BUFFER
    mov R0, A
    mov A, R2
    mov @R0, A       ;Store character in buffer
    inc INPUT_PTR
    mov LEDRA, A     ;Display on LEDs
    sjmp PS2_Done
    
ClearRel:
    clr RELEASE_FLAG 
    sjmp PS2_Done
    
CheckIfDone:
    ;Wait for Stop Bit (bit 10)
    cjne A, #11, CheckOverflow
    sjmp Reset
    
Reset:
    ;Reset for next scancode
    mov PS2_BIT_COUNT, #0
    mov PS2_DATA_REG, #0
    sjmp PS2_Done
    
CheckOverflow:
    ;Prevent going out of sync
    clr C
    subb A, #12
    jc PS2_Done
    sjmp Reset
    
PS2_Done:
    pop PSW
    pop ACC
    reti

;============================================
; COMMAND TOKENIZER
;============================================

TokenizeInput:
    mov R0, #INPUT_BUFFER ;Start at beginning of buffer
    mov R1, #TOKEN1_PTR 
    mov TOKEN_COUNT, #0
    
TokenLoop:
    mov A, @R0 ;Read character at R0
    cjne A, #' ', CheckEOS ;If not space, check if end of string
    inc R0 ;Skip space
    sjmp TokenLoop
    
CheckEOS:
    ;Check for end of string
    cjne A, #0, StoreToken
    sjmp DoneTokenizing
    
StoreToken:
    mov A, R0
    mov @R1, A           ;Store pointer to token
    inc R1
    inc TOKEN_COUNT
    
    mov A, TOKEN_COUNT
    cjne A, #3, SkipToSpace
    sjmp DoneTokenizing
    
SkipToSpace:
    inc R0
    mov A, @R0
    cjne A, #0, CheckSpace
    sjmp DoneTokenizing
    
CheckSpace:
    cjne A, #' ', SkipToSpace
    mov @R0, #0          ;Replace space with null terminator
    inc R0
    sjmp TokenLoop
    
DoneTokenizing:
    ret

;============================================
; STRING COMPARISON
;============================================

CompareTokenWithString:
    ;Input: R0 = pointer to token string
    ;       DPTR = pointer to comparison string
    ;Output: MATCH_FLAG set if equal
    push ACC
    
CompareLoop:
    mov A, @R0           ;Load token character
    mov R2, A            ;Store in R2
    clr A
    movc A, @A+DPTR      ;Load string character from code memory
    cjne A, #0, CheckTokenEnd
    mov A, R2
    cjne A, #0, NotEqual
    sjmp Equal
    
CheckTokenEnd:
    xrl A, R2
    jnz NotEqual
    inc R0
    inc DPTR
    sjmp CompareLoop
    
NotEqual:
    clr MATCH_FLAG
    pop ACC
    ret
    
Equal:
    setb MATCH_FLAG
    pop ACC
    ret

;============================================
; COMMAND PARSER
;============================================

Check_Tok_1:
    ;Check first token for valid commands
    mov R1, #TOKEN1_PTR
    mov A, @R1
    mov R0, A
    mov DPTR, #SetStr
    lcall CompareTokenWithString
    jb MATCH_FLAG, DoSet
    
    mov R1, #TOKEN1_PTR
    mov A, @R1
    mov R0, A
    mov DPTR, #StartStr
    lcall CompareTokenWithString
    jb MATCH_FLAG, DoStart
    
    mov R1, #TOKEN1_PTR
    mov A, @R1
    mov R0, A
    mov DPTR, #GetStr
    lcall CompareTokenWithString
    jb MATCH_FLAG, DoGet
    ret

DoSet:
    mov A, TOKEN_COUNT
    cjne A, #3, DoSet_End
    
    ;Parse the numeric value
    mov A, TOKEN3_PTR
    mov R0, A
    lcall ParseNumber
    
    ;Check which parameter to set
    mov A, TOKEN2_PTR
    mov R0, A
    mov DPTR, #SoakTempStr
    lcall CompareTokenWithString
    jb MATCH_FLAG, Set_SoakTemp
    
    mov A, TOKEN2_PTR
    mov R0, A
    mov DPTR, #SoakTimeStr
    lcall CompareTokenWithString
    jb MATCH_FLAG, Set_SoakTime
    
    mov A, TOKEN2_PTR
    mov R0, A
    mov DPTR, #ReflowTempStr
    lcall CompareTokenWithString
    jb MATCH_FLAG, Set_ReflowTemp
    
    mov A, TOKEN2_PTR
    mov R0, A
    mov DPTR, #ReflowTimeStr
    lcall CompareTokenWithString
    jb MATCH_FLAG, Set_ReflowTime
    
DoSet_End:
    ret

Set_SoakTemp:
    mov A, TEMP_VALUE_H
    mov SOAK_TEMP_H, A
    mov A, TEMP_VALUE_L
    mov SOAK_TEMP_L, A
    ;Display confirmation on LEDRB
    mov LEDRB, A
    ret

Set_SoakTime:
    mov A, TEMP_VALUE_H
    mov SOAK_TIME_H, A
    mov A, TEMP_VALUE_L
    mov SOAK_TIME_L, A
    ;Display confirmation on LEDRB
    mov LEDRB, A
    ret

Set_ReflowTemp:
    mov A, TEMP_VALUE_H
    mov REFLOW_TEMP_H, A
    mov A, TEMP_VALUE_L
    mov REFLOW_TEMP_L, A
    ;Display confirmation on LEDRB
    mov LEDRB, A
    ret

Set_ReflowTime:
    mov A, TEMP_VALUE_H
    mov REFLOW_TIME_H, A
    mov A, TEMP_VALUE_L
    mov REFLOW_TIME_L, A
    ;Display confirmation on LEDRB
    mov LEDRB, A
    ret

DoStart:
    setb START_FLAG
    ;Visual confirmation - turn on all LEDRB LEDs
    mov LEDRB, #0xFF
    ret

DoGet:
    mov A, TOKEN_COUNT
    cjne A, #2, DoGet_End
    
    mov A, TOKEN2_PTR
    mov R0, A
    mov DPTR, #SoakTempStr
    lcall CompareTokenWithString
    jb MATCH_FLAG, Get_SoakTemp
    
    mov A, TOKEN2_PTR
    mov R0, A
    mov DPTR, #SoakTimeStr
    lcall CompareTokenWithString
    jb MATCH_FLAG, Get_SoakTime
    
    mov A, TOKEN2_PTR
    mov R0, A
    mov DPTR, #ReflowTempStr
    lcall CompareTokenWithString
    jb MATCH_FLAG, Get_ReflowTemp
    
    mov A, TOKEN2_PTR
    mov R0, A
    mov DPTR, #ReflowTimeStr
    lcall CompareTokenWithString
    jb MATCH_FLAG, Get_ReflowTime
    
DoGet_End:
    ret

Get_SoakTemp:
    mov A, SOAK_TEMP_H
    mov TEMP_VALUE_H, A
    mov A, SOAK_TEMP_L
    mov TEMP_VALUE_L, A
    ;Display on LEDRB
    mov LEDRB, A
    ret

Get_SoakTime:
    mov A, SOAK_TIME_H
    mov TEMP_VALUE_H, A
    mov A, SOAK_TIME_L
    mov TEMP_VALUE_L, A
    ;Display on LEDRB
    mov LEDRB, A
    ret

Get_ReflowTemp:
    mov A, REFLOW_TEMP_H
    mov TEMP_VALUE_H, A
    mov A, REFLOW_TEMP_L
    mov TEMP_VALUE_L, A
    ;Display on LEDRB
    mov LEDRB, A
    ret

Get_ReflowTime:
    mov A, REFLOW_TIME_H
    mov TEMP_VALUE_H, A
    mov A, REFLOW_TIME_L
    mov TEMP_VALUE_L, A
    ;Display on LEDRB
    mov LEDRB, A
    ret

;============================================
; NUMBER PARSER
;============================================

ParseNumber:
    ;Input: R0 = pointer to numeric string
    ;Output: TEMP_VALUE_H:TEMP_VALUE_L = 16-bit value
    mov TEMP_VALUE_H, #0
    mov TEMP_VALUE_L, #0
    
ParseLoop:
    mov A, @R0
    jz ParseDone
    clr C
    subb A, #'0'
    mov R2, A
    
    ;Multiply current value by 10
    mov A, TEMP_VALUE_L
    mov B, #10
    mul AB
    mov TEMP_VALUE_L, A
    mov R3, B
    
    mov A, TEMP_VALUE_H
    mov B, #10
    mul AB
    add A, R3
    mov TEMP_VALUE_H, A
    
    ;Add new digit
    mov A, TEMP_VALUE_L
    add A, R2
    mov TEMP_VALUE_L, A
    mov A, TEMP_VALUE_H
    addc A, #0
    mov TEMP_VALUE_H, A
    
    inc R0
    sjmp ParseLoop
    
ParseDone:
    ret

;============================================
; MAIN PROGRAM
;============================================

MainProgram:
    mov LEDRA, #0x00
    mov LEDRB, #0x00
    mov sp, #0x7f
    lcall Initialize_System
    
MainLoop:
    ;Clear LEDRB for next command
    mov LEDRB, #0x00
    
    ;Wait for command to be ready (Enter key pressed)
    jnb COMMAND_READY, MainLoop
    clr COMMAND_READY
    
    ;Process the command
    lcall TokenizeInput
    lcall Check_Tok_1
    
    sjmp MainLoop
    
    end