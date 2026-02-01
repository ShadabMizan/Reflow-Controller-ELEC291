;--------------------------------------------------------
; File Created by C51
; Version 1.0.0 #1170 (Feb 16 2022) (MSVC)
; This file was generated Fri Oct 04 23:51:37 2024
;--------------------------------------------------------
$name shared_memory_test
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
	public _seven_seg
	public _main
	public _de2_8052_crt0
	public _buff
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
_KEY_1          BIT 0xf9
_KEY_2          BIT 0xfa
_KEY_3          BIT 0xfb
_KEY_4          BIT 0xfc
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
	XSEG at 0x8000
_rxcount: ds 1
	public _rxcount
	rseg R_XSEG
	XSEG at 0x8001
_rxbuff: ds 254
	public _rxbuff
	rseg R_XSEG
	XSEG at 0x8100
_txcount: ds 1
	public _txcount
	rseg R_XSEG
	XSEG at 0x8101
_txbuff: ds 254
	public _txbuff
	rseg R_XSEG
_buff:
	ds 256
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
;Allocation info for local variables in function 'main'
;------------------------------------------------------------
;j                         Allocated to registers r2 r3 
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:24: void main (void)
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
	using	0
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:28: LEDRA=0;
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:29: LEDRB=0;
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:31: sprintf(txbuff, "******************************************************************************\r\n");
	clr	a
	mov	_LEDRA,a
	mov	_LEDRB,a
	mov	a,#__str_0
	push	acc
	mov	a,#(__str_0 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	mov	a,#_txbuff
	push	acc
	mov	a,#(_txbuff >> 8)
	push	acc
	clr	a
	push	acc
	lcall	_sprintf
	mov	a,sp
	add	a,#0xfa
	mov	sp,a
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:32: txcount=strlen(txbuff);
	mov	dptr,#_txbuff
	mov	b,#0x00
	lcall	_strlen
	mov	r2,dpl
	mov	r3,dph
	mov	dptr,#_txcount
	mov	a,r2
	movx	@dptr,a
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:33: while(txcount!=0);
L003001?:
	mov	dptr,#_txcount
	movx	a,@dptr
	mov	r2,a
	jnz	L003001?
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:34: sprintf(txbuff, "Hello, World!\r\n");
	mov	a,#__str_1
	push	acc
	mov	a,#(__str_1 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	mov	a,#_txbuff
	push	acc
	mov	a,#(_txbuff >> 8)
	push	acc
	clr	a
	push	acc
	lcall	_sprintf
	mov	a,sp
	add	a,#0xfa
	mov	sp,a
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:35: txcount=strlen(txbuff);
	mov	dptr,#_txbuff
	mov	b,#0x00
	lcall	_strlen
	mov	r2,dpl
	mov	r3,dph
	mov	dptr,#_txcount
	mov	a,r2
	movx	@dptr,a
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:36: while(txcount!=0);
L003004?:
	mov	dptr,#_txcount
	movx	a,@dptr
	mov	r2,a
	jnz	L003004?
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:37: sprintf(txbuff, "Another line for you!\r\n");
	mov	a,#__str_2
	push	acc
	mov	a,#(__str_2 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	mov	a,#_txbuff
	push	acc
	mov	a,#(_txbuff >> 8)
	push	acc
	clr	a
	push	acc
	lcall	_sprintf
	mov	a,sp
	add	a,#0xfa
	mov	sp,a
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:38: txcount=strlen(txbuff);
	mov	dptr,#_txbuff
	mov	b,#0x00
	lcall	_strlen
	mov	r2,dpl
	mov	r3,dph
	mov	dptr,#_txcount
	mov	a,r2
	movx	@dptr,a
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:39: while(txcount!=0);
L003007?:
	mov	dptr,#_txcount
	movx	a,@dptr
	mov	r2,a
	jnz	L003007?
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:40: sprintf(txbuff, "******************************************************************************\r\n");
	mov	a,#__str_0
	push	acc
	mov	a,#(__str_0 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	mov	a,#_txbuff
	push	acc
	mov	a,#(_txbuff >> 8)
	push	acc
	clr	a
	push	acc
	lcall	_sprintf
	mov	a,sp
	add	a,#0xfa
	mov	sp,a
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:41: txcount=strlen(txbuff);
	mov	dptr,#_txbuff
	mov	b,#0x00
	lcall	_strlen
	mov	r2,dpl
	mov	r3,dph
	mov	dptr,#_txcount
	mov	a,r2
	movx	@dptr,a
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:42: while(txcount!=0);
L003010?:
	mov	dptr,#_txcount
	movx	a,@dptr
	mov	r2,a
	jnz	L003010?
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:44: sprintf(txbuff, "\r\n");
	mov	a,#__str_3
	push	acc
	mov	a,#(__str_3 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	mov	a,#_txbuff
	push	acc
	mov	a,#(_txbuff >> 8)
	push	acc
	clr	a
	push	acc
	lcall	_sprintf
	mov	a,sp
	add	a,#0xfa
	mov	sp,a
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:45: for (j=0; j<100; j++)
	mov	r2,#0x00
	mov	r3,#0x00
L003051?:
	clr	c
	mov	a,r2
	subb	a,#0x64
	mov	a,r3
	xrl	a,#0x80
	subb	a,#0x80
	jnc	L003054?
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:47: sprintf(buff, "The number is %03d\r\n", j);
	push	ar2
	push	ar3
	push	ar2
	push	ar3
	mov	a,#__str_4
	push	acc
	mov	a,#(__str_4 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	mov	a,#_buff
	push	acc
	mov	a,#(_buff >> 8)
	push	acc
	clr	a
	push	acc
	lcall	_sprintf
	mov	a,sp
	add	a,#0xf8
	mov	sp,a
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:48: strcat(txbuff, buff);
	mov	_strcat_PARM_2,#_buff
	mov	(_strcat_PARM_2 + 1),#(_buff >> 8)
	mov	(_strcat_PARM_2 + 2),#0x00
	mov	dptr,#_txbuff
	mov	b,#0x00
	lcall	_strcat
	pop	ar3
	pop	ar2
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:45: for (j=0; j<100; j++)
	inc	r2
	cjne	r2,#0x00,L003051?
	inc	r3
	sjmp	L003051?
L003054?:
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:50: txcount=1;
	mov	dptr,#_txcount
	mov	a,#0x01
	movx	@dptr,a
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:51: while(txcount!=0);
L003013?:
	mov	dptr,#_txcount
	movx	a,@dptr
	mov	r2,a
	jnz	L003013?
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:53: while(1)
L003049?:
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:55: if(KEY_1==0)
	jb	_KEY_1,L003023?
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:57: sprintf(txbuff, "KEY_1=0\r\n");
	mov	a,#__str_5
	push	acc
	mov	a,#(__str_5 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	mov	a,#_txbuff
	push	acc
	mov	a,#(_txbuff >> 8)
	push	acc
	clr	a
	push	acc
	lcall	_sprintf
	mov	a,sp
	add	a,#0xfa
	mov	sp,a
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:58: txcount=strlen(txbuff);
	mov	dptr,#_txbuff
	mov	b,#0x00
	lcall	_strlen
	mov	r2,dpl
	mov	r3,dph
	mov	dptr,#_txcount
	mov	a,r2
	movx	@dptr,a
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:59: while(txcount!=0);
L003016?:
	mov	dptr,#_txcount
	movx	a,@dptr
	mov	r2,a
	jnz	L003016?
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:60: while(KEY_1==0);
L003019?:
	jnb	_KEY_1,L003019?
L003023?:
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:62: if(KEY_2==0)
	jb	_KEY_2,L003031?
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:64: sprintf(txbuff, "KEY_2=0\r\n");
	mov	a,#__str_6
	push	acc
	mov	a,#(__str_6 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	mov	a,#_txbuff
	push	acc
	mov	a,#(_txbuff >> 8)
	push	acc
	clr	a
	push	acc
	lcall	_sprintf
	mov	a,sp
	add	a,#0xfa
	mov	sp,a
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:65: txcount=strlen(txbuff);
	mov	dptr,#_txbuff
	mov	b,#0x00
	lcall	_strlen
	mov	r2,dpl
	mov	r3,dph
	mov	dptr,#_txcount
	mov	a,r2
	movx	@dptr,a
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:66: while(txcount!=0);
L003024?:
	mov	dptr,#_txcount
	movx	a,@dptr
	mov	r2,a
	jnz	L003024?
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:67: while(KEY_2==0);
L003027?:
	jnb	_KEY_2,L003027?
L003031?:
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:69: if(KEY_3==0)
	jb	_KEY_3,L003039?
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:71: sprintf(txbuff, "KEY_3=0\r\n");
	mov	a,#__str_7
	push	acc
	mov	a,#(__str_7 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	mov	a,#_txbuff
	push	acc
	mov	a,#(_txbuff >> 8)
	push	acc
	clr	a
	push	acc
	lcall	_sprintf
	mov	a,sp
	add	a,#0xfa
	mov	sp,a
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:72: txcount=strlen(txbuff);
	mov	dptr,#_txbuff
	mov	b,#0x00
	lcall	_strlen
	mov	r2,dpl
	mov	r3,dph
	mov	dptr,#_txcount
	mov	a,r2
	movx	@dptr,a
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:73: while(txcount!=0);
L003032?:
	mov	dptr,#_txcount
	movx	a,@dptr
	mov	r2,a
	jnz	L003032?
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:74: while(KEY_3==0);
L003035?:
	jnb	_KEY_3,L003035?
L003039?:
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:76: if(KEY_4==0)
	jnb	_KEY_4,L003099?
	ljmp	L003049?
L003099?:
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:78: sprintf(txbuff, "KEY_4=0\r\n");
	mov	a,#__str_8
	push	acc
	mov	a,#(__str_8 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	mov	a,#_txbuff
	push	acc
	mov	a,#(_txbuff >> 8)
	push	acc
	clr	a
	push	acc
	lcall	_sprintf
	mov	a,sp
	add	a,#0xfa
	mov	sp,a
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:79: txcount=strlen(txbuff);
	mov	dptr,#_txbuff
	mov	b,#0x00
	lcall	_strlen
	mov	r2,dpl
	mov	r3,dph
	mov	dptr,#_txcount
	mov	a,r2
	movx	@dptr,a
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:80: while(txcount!=0);
L003040?:
	mov	dptr,#_txcount
	movx	a,@dptr
	mov	r2,a
	jnz	L003040?
;	C:\Source\MAX10_8052\Boot\Test\shared_memory_test.c:81: while(KEY_4==0);
L003043?:
	jnb	_KEY_4,L003043?
	ljmp	L003049?
	rseg R_CSEG

	rseg R_XINIT

	rseg R_CONST
_seven_seg:
	db 0xc0	; 192 	À
	db 0xf9	; 249 
	db 0xa4	; 164 	¤
	db 0xb0	; 176 	°
	db 0x99	; 153 	™
	db 0x92	; 146 	’
	db 0x82	; 130 	‚
	db 0xf8	; 248 
	db 0x80	; 128 	€
	db 0x90	; 144 
	db 0x88	; 136 
	db 0x83	; 131 
	db 0xc6	; 198 
	db 0xa1	; 161 	¡
	db 0x86	; 134 	†
	db 0x8e	; 142 	Ž
__str_0:
	db '************************************************************'
	db '******************'
	db 0x0D
	db 0x0A
	db 0x00
__str_1:
	db 'Hello, World!'
	db 0x0D
	db 0x0A
	db 0x00
__str_2:
	db 'Another line for you!'
	db 0x0D
	db 0x0A
	db 0x00
__str_3:
	db 0x0D
	db 0x0A
	db 0x00
__str_4:
	db 'The number is %03d'
	db 0x0D
	db 0x0A
	db 0x00
__str_5:
	db 'KEY_1=0'
	db 0x0D
	db 0x0A
	db 0x00
__str_6:
	db 'KEY_2=0'
	db 0x0D
	db 0x0A
	db 0x00
__str_7:
	db 'KEY_3=0'
	db 0x0D
	db 0x0A
	db 0x00
__str_8:
	db 'KEY_4=0'
	db 0x0D
	db 0x0A
	db 0x00

	CSEG

end
