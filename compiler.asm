;-----------------------------------------;
;         REFLOW LANGUAGE COMPILER        ;
;     Interprets content of text buffer   ;
;                                         ;
;     Syntax: set <PARAMETER> <VALUE>     ;
;             get <PARAMETER>             ;
;             start                       ;
;-----------------------------------------
$NOLIST
$MODDE1SOC
$LIST

;shared memory with keyboard
INPUT_BUFFER    EQU 30h
INPUT_PTR       EQU 80h    ;current position in buffer
COMMAND_READY   BIT 20h.0  ;set when enter

TEMP_VALUE_H    DATA 94h
TEMP_VALUE_L    DATA 95h

SOAK_TEMP_H     DATA 60h
SOAK_TEMP_L     DATA 61h
SOAK_TIME_H     DATA 62h
SOAK_TIME_L     DATA 63h
REFLOW_TEMP_H   DATA 64h
REFLOW_TEMP_L   DATA 65h
REFLOW_TIME_H   DATA 66h
REFLOW_TIME_L   DATA 67h

TOKEN1_PTR      DATA 90h
TOKEN2_PTR      DATA 91h
TOKEN3_PTR      DATA 92h
TOKEN_COUNT     DATA 93h 

MATCH_FLAG      BIT 98h.0
START_FLAG      BIT 98h.1

cseg
    ljmp MainProgram
    
StartStr: 
db 'start',0
GetStr: 
db 'get',0
SetStr: 
db 'set',0

SoakTempStr:    db 'soaktemp',0
SoakTimeStr:    db 'soaktime',0
ReflowTempStr:  db 'reflowtemp',0
ReflowTimeStr:  db 'reflowtime',0


Initialize_Compiler:
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
    ret
    
;convert buffer into a series of tokens
TokenizeInput:
    mov R0, #INPUT_BUFFER ;start pointing at beginning of buffer
    mov R1, #TOKEN1_PTR 
    mov TOKEN_COUNT, #0
TokenLoop:
    mov A, @R0 ;read content at R0
    cjne A, #' ', CheckEOS ;if we encounter a character, check its value
    inc R0 ;move to the next char
    sjmp TokenLoop
CheckEOS:
    ; check for end of string
    cjne A, #0, StoreToken
    sjmp DoneTokenizing
StoreToken:
    mov A, R0
    mov @R1, A
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
    mov @R0, #0
    inc R0
    sjmp TokenLoop
DoneTokenizing:
    ret
    
;compare token with string literal
CompareTokenWithString:
    push ACC
CompareLoop:
    mov A, @R0        ;load token char
    mov R2, A         ;store token char in R2
    clr A
    movc A, @A+DPTR      ;load string char
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

Check_Tok_1:
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
    mov A, TOKEN3_PTR
    mov R0, A
    lcall ParseNumber
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
    ret

Set_SoakTime:
    mov A, TEMP_VALUE_H
    mov SOAK_TIME_H, A
    mov A, TEMP_VALUE_L
    mov SOAK_TIME_L, A
    ret

Set_ReflowTemp:
    mov A, TEMP_VALUE_H
    mov REFLOW_TEMP_H, A
    mov A, TEMP_VALUE_L
    mov REFLOW_TEMP_L, A
    ret

Set_ReflowTime:
    mov A, TEMP_VALUE_H
    mov REFLOW_TIME_H, A
    mov A, TEMP_VALUE_L
    mov REFLOW_TIME_L, A
    ret

DoStart:
    setb START_FLAG
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
    ret

Get_SoakTime:
    mov A, SOAK_TIME_H
    mov TEMP_VALUE_H, A
    mov A, SOAK_TIME_L
    mov TEMP_VALUE_L, A
    ret

Get_ReflowTemp:
    mov A, REFLOW_TEMP_H
    mov TEMP_VALUE_H, A
    mov A, REFLOW_TEMP_L
    mov TEMP_VALUE_L, A
    ret

Get_ReflowTime:
    mov A, REFLOW_TIME_H
    mov TEMP_VALUE_H, A
    mov A, REFLOW_TIME_L
    mov TEMP_VALUE_L, A
    ret

ParseNumber:
    mov TEMP_VALUE_H, #0
    mov TEMP_VALUE_L, #0
ParseLoop:
    mov A, @R0
    jz ParseDone
    clr C
    subb A, #'0'
    mov R2, A

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

MainProgram:
    lcall Initialize_Compiler
MainLoop:
    jnb COMMAND_READY, MainLoop
    clr COMMAND_READY
    lcall TokenizeInput
    lcall Check_Tok_1
    sjmp MainLoop
    end
