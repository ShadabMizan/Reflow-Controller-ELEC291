;--------------------------------------------------------
; File Created by C51
; Version 1.0.0 #1170 (Feb 16 2022) (MSVC)
; This file was generated Thu Oct 03 21:58:31 2024
;--------------------------------------------------------
$name LargeHex
$optc51 --model-small
	R_DSEG    segment data
	R_CSEG    segment code
	R_BSEG    segment bit
	R_XSEG    segment xdata
	R_PSEG    segment xdata
	R_ISEG    segment idata
	R_OSEG    segment data overlay
	BIT_BANK  segment data overlay
	R_HOME    segment code
	R_GSINIT  segment code
	R_IXSEG   segment xdata
	R_CONST   segment code
	R_XINIT   segment code
	R_DINIT   segment code

;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	public _filler
	public _main
	public __c51_external_startup
	public _de2_8052_crt0
;--------------------------------------------------------
; Special Function Registers
;--------------------------------------------------------
_P0             DATA 0x80
_SP             DATA 0x81
_DPL            DATA 0x82
_DPH            DATA 0x83
_PCON           DATA 0x87
_TCON           DATA 0x88
_TMOD           DATA 0x89
_TL0            DATA 0x8a
_TL1            DATA 0x8b
_TH0            DATA 0x8c
_TH1            DATA 0x8d
_P1             DATA 0x90
_SCON           DATA 0x98
_SBUF           DATA 0x99
_P2             DATA 0xa0
_IE             DATA 0xa8
_P3             DATA 0xb0
_IP             DATA 0xb8
_PSW            DATA 0xd0
_ACC            DATA 0xe0
_B              DATA 0xf0
_T2CON          DATA 0xc8
_RCAP2L         DATA 0xca
_RCAP2H         DATA 0xcb
_TL2            DATA 0xcc
_TH2            DATA 0xcd
_DPS            DATA 0x86
_DPH1           DATA 0x85
_DPL1           DATA 0x84
_HEX0           DATA 0x91
_HEX1           DATA 0x92
_HEX2           DATA 0x93
_HEX3           DATA 0x94
_HEX4           DATA 0x8e
_HEX5           DATA 0x8f
_LEDRA          DATA 0xe8
_LEDRB          DATA 0x95
_SWA            DATA 0xe8
_SWB            DATA 0x95
_KEY            DATA 0xf8
_P0MOD          DATA 0x9a
_P1MOD          DATA 0x9b
_P2MOD          DATA 0x9c
_P3MOD          DATA 0x9d
_REP_ADD_L      DATA 0xf1
_REP_ADD_H      DATA 0xf2
_REP_VALUE      DATA 0xf3
_DEBUG_CALL_L   DATA 0xfa
_DEBUG_CALL_H   DATA 0xfb
_BPC            DATA 0xfc
_BPS            DATA 0xfd
_BPAL           DATA 0xfe
_BPAH           DATA 0xff
_LBPAL          DATA 0xfa
_LBPAH          DATA 0xfb
_P4             DATA 0xc0
_P4MOD          DATA 0xc1
_XRAMUSEDAS     DATA 0xc3
_UFM_ADD0       DATA 0xe1
_UFM_ADD1       DATA 0xe2
_UFM_ADD2       DATA 0xe3
_UFM_DATA0      DATA 0xe4
_UFM_DATA1      DATA 0xe5
_UFM_DATA2      DATA 0xe6
_UFM_DATA3      DATA 0xe7
_UFM_CONTROL0   DATA 0xe9
_UFM_CONTROL1   DATA 0xea
_UFM_CONTROL2   DATA 0xeb
_UFM_CONTROL3   DATA 0xec
_UFM_DATA_CMD   DATA 0xed
_UFM_DATA_STATUS DATA 0xee
_UFM_CONTROL_CMD DATA 0xef
;--------------------------------------------------------
; special function bits
;--------------------------------------------------------
_P0_0           BIT 0x80
_P0_1           BIT 0x81
_P0_2           BIT 0x82
_P0_3           BIT 0x83
_P0_4           BIT 0x84
_P0_5           BIT 0x85
_P0_6           BIT 0x86
_P0_7           BIT 0x87
_IT0            BIT 0x88
_IE0            BIT 0x89
_IT1            BIT 0x8a
_IE1            BIT 0x8b
_TR0            BIT 0x8c
_TF0            BIT 0x8d
_TR1            BIT 0x8e
_TF1            BIT 0x8f
_P1_0           BIT 0x90
_P1_1           BIT 0x91
_P1_2           BIT 0x92
_P1_3           BIT 0x93
_P1_4           BIT 0x94
_P1_5           BIT 0x95
_P1_6           BIT 0x96
_P1_7           BIT 0x97
_RI             BIT 0x98
_TI             BIT 0x99
_RB8            BIT 0x9a
_TB8            BIT 0x9b
_REN            BIT 0x9c
_SM2            BIT 0x9d
_SM1            BIT 0x9e
_SM0            BIT 0x9f
_P2_0           BIT 0xa0
_P2_1           BIT 0xa1
_P2_2           BIT 0xa2
_P2_3           BIT 0xa3
_P2_4           BIT 0xa4
_P2_5           BIT 0xa5
_P2_6           BIT 0xa6
_P2_7           BIT 0xa7
_EX0            BIT 0xa8
_ET0            BIT 0xa9
_EX1            BIT 0xaa
_ET1            BIT 0xab
_ES             BIT 0xac
_ET2            BIT 0xad
_EA             BIT 0xaf
_P3_0           BIT 0xb0
_P3_1           BIT 0xb1
_P3_2           BIT 0xb2
_P3_3           BIT 0xb3
_P3_4           BIT 0xb4
_P3_5           BIT 0xb5
_P3_6           BIT 0xb6
_P3_7           BIT 0xb7
_RXD            BIT 0xb0
_TXD            BIT 0xb1
_INT0           BIT 0xb2
_INT1           BIT 0xb3
_T0             BIT 0xb4
_T1             BIT 0xb5
_WR             BIT 0xb6
_RD             BIT 0xb7
_PX0            BIT 0xb8
_PT0            BIT 0xb9
_PX1            BIT 0xba
_PT1            BIT 0xbb
_PS             BIT 0xbc
_PT2            BIT 0xbd
_P              BIT 0xd0
_F1             BIT 0xd1
_OV             BIT 0xd2
_RS0            BIT 0xd3
_RS1            BIT 0xd4
_F0             BIT 0xd5
_AC             BIT 0xd6
_CY             BIT 0xd7
_T2CON_0        BIT 0xc8
_T2CON_1        BIT 0xc9
_T2CON_2        BIT 0xca
_T2CON_3        BIT 0xcb
_T2CON_4        BIT 0xcc
_T2CON_5        BIT 0xcd
_T2CON_6        BIT 0xce
_T2CON_7        BIT 0xcf
_CP_RL2         BIT 0xc8
_C_T2           BIT 0xc9
_TR2            BIT 0xca
_EXEN2          BIT 0xcb
_TCLK           BIT 0xcc
_RCLK           BIT 0xcd
_EXF2           BIT 0xce
_TF2            BIT 0xcf
_LEDRA_0        BIT 0xe8
_LEDRA_1        BIT 0xe9
_LEDRA_2        BIT 0xea
_LEDRA_3        BIT 0xeb
_LEDRA_4        BIT 0xec
_LEDRA_5        BIT 0xed
_LEDRA_6        BIT 0xee
_LEDRA_7        BIT 0xef
_SWA_0          BIT 0xe8
_SWA_1          BIT 0xe9
_SWA_2          BIT 0xea
_SWA_3          BIT 0xeb
_SWA_4          BIT 0xec
_SWA_5          BIT 0xed
_SWA_6          BIT 0xee
_SWA_7          BIT 0xef
_KEY_0          BIT 0xf8
_KEY_1          BIT 0xf9
_KEY_2          BIT 0xfa
_KEY_3          BIT 0xfb
_P4_0           BIT 0xc0
_P4_1           BIT 0xc1
_P4_2           BIT 0xc2
_P4_3           BIT 0xc3
_P4_4           BIT 0xc4
_P4_5           BIT 0xc5
_P4_6           BIT 0xc6
_P4_7           BIT 0xc7
;--------------------------------------------------------
; overlayable register banks
;--------------------------------------------------------
	rbank0 segment data overlay
;--------------------------------------------------------
; internal ram data
;--------------------------------------------------------
	rseg R_DSEG
;--------------------------------------------------------
; overlayable items in internal ram 
;--------------------------------------------------------
	rseg R_OSEG
;--------------------------------------------------------
; indirectly addressable internal ram data
;--------------------------------------------------------
	rseg R_ISEG
;--------------------------------------------------------
; absolute internal ram data
;--------------------------------------------------------
	DSEG
;--------------------------------------------------------
; bit data
;--------------------------------------------------------
	rseg R_BSEG
;--------------------------------------------------------
; paged external ram data
;--------------------------------------------------------
	rseg R_PSEG
;--------------------------------------------------------
; external ram data
;--------------------------------------------------------
	rseg R_XSEG
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	XSEG
;--------------------------------------------------------
; external initialized ram data
;--------------------------------------------------------
	rseg R_IXSEG
	rseg R_HOME
	rseg R_GSINIT
	rseg R_CSEG
;--------------------------------------------------------
; Reset entry point and interrupt vectors
;--------------------------------------------------------
	CSEG at 0x0000
	ljmp	_crt0
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	rseg R_HOME
	rseg R_GSINIT
	rseg R_GSINIT
;--------------------------------------------------------
; data variables initialization
;--------------------------------------------------------
	rseg R_DINIT
	; The linker places a 'ret' at the end of segment R_DINIT.
;--------------------------------------------------------
; code
;--------------------------------------------------------
	rseg R_CSEG
;------------------------------------------------------------
;Allocation info for local variables in function 'de2_8052_crt0'
;------------------------------------------------------------
;------------------------------------------------------------
;	C:/Source/call51/Bin/../include/mcs51/MAX10_8052.h:302: void de2_8052_crt0 (void) _naked
;	-----------------------------------------
;	 function de2_8052_crt0
;	-----------------------------------------
_de2_8052_crt0:
;	naked function: no prologue.
;	C:/Source/call51/Bin/../include/mcs51/MAX10_8052.h:371: _endasm;
	
	
	 rseg R_GSINIT
	 public _crt0
	_crt0:
	 mov sp,#_stack_start-1
	 lcall __c51_external_startup
	 mov a,dpl
	 jz __c51_init_data
	 ljmp __c51_program_startup
	__c51_init_data:
	
; Initialize xdata variables
	
	 mov dpl, #_R_XINIT_start
	 mov dph, #(_R_XINIT_start>>8)
	 mov _DPL1, #_R_IXSEG_start
	 mov _DPH1, #(_R_IXSEG_start>>8)
	 mov r0, #_R_IXSEG_size
	 mov r1, #(_R_IXSEG_size>>8)
	
	XInitLoop?repeat?:
	 mov a, r0
	 orl a, r1
	 jz XInitLoop?done?
	 clr a
	 mov _DPS, #0 ; Using dpl, dph
	 movc a,@a+dptr
	 inc dptr
	 mov _DPS, #1 ; Using DPL1, DPH1
	 movx @dptr, a
	 inc dptr
	 dec r0
	 cjne r0, #0xff, XInitLoop?repeat?
	 dec r1
	 sjmp XInitLoop?repeat?
	
	XInitLoop?done?:
	
; Clear xdata variables
	 mov _DPS, #0 ; Make sure we are using dpl, dph
	 mov dpl, #_R_XSEG_start
	 mov dph, #(_R_XSEG_start>>8)
	 mov r4, #_R_XSEG_size
	 mov r5, #(_R_XSEG_size>>8)
	
	XClearLoop?repeat?:
	 mov a, r4
	 orl a, r5
	 jz XClearLoop?done?
	 clr a
	 movx @dptr, a
	 inc dptr
	 dec r4
	 cjne r4, #0xff, XClearLoop?repeat?
	 dec r5
	 sjmp XClearLoop?repeat?
	
	XClearLoop?done?:
	 lcall _R_DINIT_start ; Initialize data/idata variables
	
	__c51_program_startup:
	 lcall _main
	
	forever?home?:
	 sjmp forever?home?
	
	 
;	naked function: no epilogue.
;------------------------------------------------------------
;Allocation info for local variables in function '_c51_external_startup'
;------------------------------------------------------------
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Test\Code\LargeHex.c:417: unsigned char _c51_external_startup(void)
;	-----------------------------------------
;	 function _c51_external_startup
;	-----------------------------------------
__c51_external_startup:
	using	0
;	C:\Source\MAX10_8052\Test\Code\LargeHex.c:419: RCAP2H=HIGH(TIMER_2_RELOAD);
	mov	_RCAP2H,#0xFF
;	C:\Source\MAX10_8052\Test\Code\LargeHex.c:420: RCAP2L=LOW(TIMER_2_RELOAD);
	mov	_RCAP2L,#0xF7
;	C:\Source\MAX10_8052\Test\Code\LargeHex.c:421: T2CON=0x34; // #00110100B
	mov	_T2CON,#0x34
;	C:\Source\MAX10_8052\Test\Code\LargeHex.c:422: SCON=0x52; // Serial port in mode 1, ren, txrdy, rxempty
	mov	_SCON,#0x52
;	C:\Source\MAX10_8052\Test\Code\LargeHex.c:424: return 0;
	mov	dpl,#0x00
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'main'
;------------------------------------------------------------
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Test\Code\LargeHex.c:427: void main (void)
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
;	C:\Source\MAX10_8052\Test\Code\LargeHex.c:430: LEDRA=0x00;
;	C:\Source\MAX10_8052\Test\Code\LargeHex.c:431: LEDRB=0x00;
;	C:\Source\MAX10_8052\Test\Code\LargeHex.c:433: printf("Very large hex file test.\r\n");
	clr	a
	mov	_LEDRA,a
	mov	_LEDRB,a
	mov	a,#__str_0
	push	acc
	mov	a,#(__str_0 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	dec	sp
	dec	sp
	dec	sp
	ret
	rseg R_CSEG

	rseg R_XINIT

	rseg R_CONST
_filler:
	db '0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXY'
	db 'Z,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGH'
	db 'IJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopq'
	db 'rstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=012345678'
	db '9abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$'
	db '^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQ'
	db 'RSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyz'
	db 'ABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefgh'
	db 'ijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0'
	db '123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
	db ',.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHI'
	db 'JKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqr'
	db 'stuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789'
	db 'abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^'
	db '*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQR'
	db 'STUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzA'
	db 'BCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghi'
	db 'jklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=01'
	db '23456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,'
	db '.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJ'
	db 'KLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrs'
	db 'tuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789a'
	db 'bcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*'
	db '()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRS'
	db 'TUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzAB'
	db 'CDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghij'
	db 'klmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=012'
	db '3456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.'
	db '?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJK'
	db 'LMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrst'
	db 'uvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789ab'
	db 'cdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*('
	db ')_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRST'
	db 'UVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABC'
	db 'DEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijk'
	db 'lmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123'
	db '456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?'
	db '~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKL'
	db 'MNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstu'
	db 'vwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abc'
	db 'defghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()'
	db '_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTU'
	db 'VWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCD'
	db 'EFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijkl'
	db 'mopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=01234'
	db '56789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~'
	db '!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLM'
	db 'NOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuv'
	db 'wxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcd'
	db 'efghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_'
	db '-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUV'
	db 'WXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDE'
	db 'FGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklm'
	db 'opqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=012345'
	db '6789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!'
	db '@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMN'
	db 'OPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvw'
	db 'xyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcde'
	db 'fghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-'
	db '+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVW'
	db 'XYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEF'
	db 'GHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmo'
	db 'pqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456'
	db '789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@'
	db '#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNO'
	db 'PQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwx'
	db 'yzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdef'
	db 'ghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+'
	db '=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWX'
	db 'YZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFG'
	db 'HIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmop'
	db 'qrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=01234567'
	db '89abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#'
	db '$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOP'
	db 'QRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxy'
	db 'zABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefg'
	db 'hijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+='
	db '0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXY'
	db 'Z,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGH'
	db 'IJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopq'
	db 'rstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=012345678'
	db '9abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$'
	db '^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQ'
	db 'RSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyz'
	db 'ABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefgh'
	db 'ijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0'
	db '123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
	db ',.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHI'
	db 'JKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqr'
	db 'stuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789'
	db 'abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^'
	db '*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQR'
	db 'STUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzA'
	db 'BCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghi'
	db 'jklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=01'
	db '23456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,'
	db '.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJ'
	db 'KLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrs'
	db 'tuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789a'
	db 'bcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*'
	db '()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRS'
	db 'TUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzAB'
	db 'CDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghij'
	db 'klmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=012'
	db '3456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.'
	db '?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJK'
	db 'LMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrst'
	db 'uvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789ab'
	db 'cdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*('
	db ')_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRST'
	db 'UVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABC'
	db 'DEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijk'
	db 'lmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123'
	db '456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?'
	db '~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKL'
	db 'MNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstu'
	db 'vwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abc'
	db 'defghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()'
	db '_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTU'
	db 'VWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCD'
	db 'EFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijkl'
	db 'mopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=01234'
	db '56789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~'
	db '!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLM'
	db 'NOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuv'
	db 'wxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcd'
	db 'efghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_'
	db '-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUV'
	db 'WXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDE'
	db 'FGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklm'
	db 'opqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=012345'
	db '6789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!'
	db '@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMN'
	db 'OPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvw'
	db 'xyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcde'
	db 'fghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-'
	db '+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVW'
	db 'XYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEF'
	db 'GHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmo'
	db 'pqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456'
	db '789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@'
	db '#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNO'
	db 'PQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwx'
	db 'yzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdef'
	db 'ghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+'
	db '=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWX'
	db 'YZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFG'
	db 'HIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmop'
	db 'qrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=01234567'
	db '89abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#'
	db '$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOP'
	db 'QRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxy'
	db 'zABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefg'
	db 'hijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+='
	db '0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXY'
	db 'Z,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGH'
	db 'IJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopq'
	db 'rstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=012345678'
	db '9abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$'
	db '^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQ'
	db 'RSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyz'
	db 'ABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefgh'
	db 'ijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0'
	db '123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
	db ',.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHI'
	db 'JKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqr'
	db 'stuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789'
	db 'abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^'
	db '*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQR'
	db 'STUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzA'
	db 'BCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghi'
	db 'jklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=01'
	db '23456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,'
	db '.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJ'
	db 'KLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrs'
	db 'tuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789a'
	db 'bcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*'
	db '()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRS'
	db 'TUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzAB'
	db 'CDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghij'
	db 'klmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=012'
	db '3456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.'
	db '?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJK'
	db 'LMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrst'
	db 'uvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789ab'
	db 'cdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*('
	db ')_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRST'
	db 'UVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABC'
	db 'DEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijk'
	db 'lmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123'
	db '456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?'
	db '~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKL'
	db 'MNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstu'
	db 'vwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abc'
	db 'defghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()'
	db '_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTU'
	db 'VWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCD'
	db 'EFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijkl'
	db 'mopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=01234'
	db '56789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~'
	db '!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLM'
	db 'NOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuv'
	db 'wxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcd'
	db 'efghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_'
	db '-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUV'
	db 'WXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDE'
	db 'FGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklm'
	db 'opqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=012345'
	db '6789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!'
	db '@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMN'
	db 'OPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvw'
	db 'xyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcde'
	db 'fghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-'
	db '+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVW'
	db 'XYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEF'
	db 'GHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmo'
	db 'pqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456'
	db '789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@'
	db '#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNO'
	db 'PQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwx'
	db 'yzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdef'
	db 'ghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+'
	db '=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWX'
	db 'YZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFG'
	db 'HIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmop'
	db 'qrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=01234567'
	db '89abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#'
	db '$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOP'
	db 'QRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxy'
	db 'zABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefg'
	db 'hijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+='
	db '0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXY'
	db 'Z,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGH'
	db 'IJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopq'
	db 'rstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=012345678'
	db '9abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$'
	db '^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQ'
	db 'RSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyz'
	db 'ABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefgh'
	db 'ijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0'
	db '123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
	db ',.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHI'
	db 'JKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqr'
	db 'stuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789'
	db 'abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^'
	db '*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQR'
	db 'STUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzA'
	db 'BCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghi'
	db 'jklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=01'
	db '23456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,'
	db '.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJ'
	db 'KLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrs'
	db 'tuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789a'
	db 'bcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*'
	db '()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRS'
	db 'TUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzAB'
	db 'CDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghij'
	db 'klmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=012'
	db '3456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.'
	db '?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJK'
	db 'LMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrst'
	db 'uvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789ab'
	db 'cdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*('
	db ')_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRST'
	db 'UVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABC'
	db 'DEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijk'
	db 'lmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123'
	db '456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?'
	db '~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKL'
	db 'MNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstu'
	db 'vwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abc'
	db 'defghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()'
	db '_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTU'
	db 'VWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCD'
	db 'EFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijkl'
	db 'mopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=01234'
	db '56789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~'
	db '!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLM'
	db 'NOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuv'
	db 'wxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcd'
	db 'efghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_'
	db '-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUV'
	db 'WXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDE'
	db 'FGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklm'
	db 'opqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=012345'
	db '6789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!'
	db '@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMN'
	db 'OPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvw'
	db 'xyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcde'
	db 'fghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-'
	db '+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVW'
	db 'XYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEF'
	db 'GHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmo'
	db 'pqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456'
	db '789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@'
	db '#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNO'
	db 'PQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwx'
	db 'yzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdef'
	db 'ghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+'
	db '=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWX'
	db 'YZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFG'
	db 'HIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmop'
	db 'qrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=01234567'
	db '89abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#'
	db '$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOP'
	db 'QRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxy'
	db 'zABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefg'
	db 'hijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+='
	db '0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXY'
	db 'Z,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGH'
	db 'IJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopq'
	db 'rstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=012345678'
	db '9abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$'
	db '^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQ'
	db 'RSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyz'
	db 'ABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefgh'
	db 'ijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0'
	db '123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
	db ',.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHI'
	db 'JKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqr'
	db 'stuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789'
	db 'abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^'
	db '*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQR'
	db 'STUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzA'
	db 'BCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghi'
	db 'jklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=01'
	db '23456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,'
	db '.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJ'
	db 'KLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrs'
	db 'tuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789a'
	db 'bcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*'
	db '()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRS'
	db 'TUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzAB'
	db 'CDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghij'
	db 'klmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=012'
	db '3456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.'
	db '?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJK'
	db 'LMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrst'
	db 'uvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789ab'
	db 'cdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*('
	db ')_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRST'
	db 'UVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABC'
	db 'DEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijk'
	db 'lmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123'
	db '456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?'
	db '~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKL'
	db 'MNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstu'
	db 'vwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abc'
	db 'defghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()'
	db '_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTU'
	db 'VWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCD'
	db 'EFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijkl'
	db 'mopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=01234'
	db '56789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~'
	db '!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLM'
	db 'NOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuv'
	db 'wxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcd'
	db 'efghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_'
	db '-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUV'
	db 'WXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDE'
	db 'FGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklm'
	db 'opqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=012345'
	db '6789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!'
	db '@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMN'
	db 'OPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvw'
	db 'xyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcde'
	db 'fghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-'
	db '+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVW'
	db 'XYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEF'
	db 'GHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmo'
	db 'pqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456'
	db '789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@'
	db '#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNO'
	db 'PQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwx'
	db 'yzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdef'
	db 'ghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+'
	db '=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWX'
	db 'YZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFG'
	db 'HIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmop'
	db 'qrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=01234567'
	db '89abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#'
	db '$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOP'
	db 'QRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxy'
	db 'zABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefg'
	db 'hijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+='
	db '0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXY'
	db 'Z,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGH'
	db 'IJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopq'
	db 'rstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=012345678'
	db '9abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$'
	db '^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQ'
	db 'RSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyz'
	db 'ABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefgh'
	db 'ijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0'
	db '123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
	db ',.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHI'
	db 'JKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqr'
	db 'stuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789'
	db 'abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^'
	db '*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQR'
	db 'STUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzA'
	db 'BCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghi'
	db 'jklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=01'
	db '23456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,'
	db '.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJ'
	db 'KLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrs'
	db 'tuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789a'
	db 'bcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*'
	db '()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRS'
	db 'TUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzAB'
	db 'CDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghij'
	db 'klmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=012'
	db '3456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.'
	db '?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJK'
	db 'LMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrst'
	db 'uvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789ab'
	db 'cdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*('
	db ')_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRST'
	db 'UVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABC'
	db 'DEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijk'
	db 'lmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123'
	db '456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?'
	db '~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKL'
	db 'MNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstu'
	db 'vwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abc'
	db 'defghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()'
	db '_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTU'
	db 'VWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCD'
	db 'EFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijkl'
	db 'mopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=01234'
	db '56789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~'
	db '!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLM'
	db 'NOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuv'
	db 'wxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcd'
	db 'efghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_'
	db '-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUV'
	db 'WXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDE'
	db 'FGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklm'
	db 'opqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=012345'
	db '6789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!'
	db '@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMN'
	db 'OPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvw'
	db 'xyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcde'
	db 'fghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-'
	db '+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVW'
	db 'XYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEF'
	db 'GHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmo'
	db 'pqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456'
	db '789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@'
	db '#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNO'
	db 'PQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwx'
	db 'yzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdef'
	db 'ghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+'
	db '=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWX'
	db 'YZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFG'
	db 'HIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmop'
	db 'qrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=01234567'
	db '89abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#'
	db '$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOP'
	db 'QRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxy'
	db 'zABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefg'
	db 'hijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+='
	db '0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXY'
	db 'Z,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGH'
	db 'IJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopq'
	db 'rstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=012345678'
	db '9abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$'
	db '^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQ'
	db 'RSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyz'
	db 'ABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefgh'
	db 'ijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0'
	db '123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
	db ',.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHI'
	db 'JKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqr'
	db 'stuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789'
	db 'abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^'
	db '*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQR'
	db 'STUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzA'
	db 'BCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghi'
	db 'jklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=01'
	db '23456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,'
	db '.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJ'
	db 'KLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrs'
	db 'tuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789a'
	db 'bcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*'
	db '()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRS'
	db 'TUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzAB'
	db 'CDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghij'
	db 'klmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=012'
	db '3456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.'
	db '?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJK'
	db 'LMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrst'
	db 'uvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789ab'
	db 'cdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*('
	db ')_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRST'
	db 'UVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABC'
	db 'DEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijk'
	db 'lmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123'
	db '456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?'
	db '~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKL'
	db 'MNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstu'
	db 'vwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abc'
	db 'defghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()'
	db '_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTU'
	db 'VWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCD'
	db 'EFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijkl'
	db 'mopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=01234'
	db '56789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~'
	db '!@#$^*()_-+=0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLM'
	db 'NOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcdefghijklmopqrstuv'
	db 'wxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_-+=0123456789abcd'
	db 'efghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.?~!@#$^*()_'
	db '-+='
	db 0x00
__str_0:
	db 'Very large hex file test.'
	db 0x0D
	db 0x0A
	db 0x00

	CSEG

end
