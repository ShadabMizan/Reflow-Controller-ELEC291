;--------------------------------------------------------
; File Created by C51
; Version 1.0.0 #1170 (Feb 16 2022) (MSVC)
; This file was generated Fri Oct 04 21:07:36 2024
;--------------------------------------------------------
$name CV_Boot_UFM
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
	public _Write_XRAM_PARM_2
	public _Write_UFM_control_PARM_2
	public _seven_seg
	public _hexval
	public _dummy_switch
	public _main
	public _Manual_Load
	public _OutWord
	public _OutByte
	public _str2hex
	public _loadintelhex
	public _Copy_XRAM_to_UFM
	public _Load_Ram_Fast_and_Run_Debugger
	public _Load_Ram_Fast_and_Run
	public _Copy_Flash_to_XRAM
	public _Clear_XRAM
	public _Read_XRAM
	public _Write_XRAM
	public _EraseSector
	public _getbyte
	public _chartohex
	public _sends
	public _getchare
	public _inituart
	public _Write_UFM_control
	public _Read_UFM_control
	public _de2_8052_crt0
	public _getchar_echo
	public _buff
	public _putchar
	public _getchar
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
_getbyte_j_1_82:
	ds 1
_loadintelhex_address_1_100:
	ds 2
_loadintelhex_j_1_100:
	ds 1
_loadintelhex_k_1_100:
	ds 1
_loadintelhex_size_1_100:
	ds 1
_loadintelhex_type_1_100:
	ds 1
_loadintelhex_checksum_1_100:
	ds 1
_loadintelhex_n_1_100:
	ds 1
_loadintelhex_echo_1_100:
	ds 1
;--------------------------------------------------------
; overlayable items in internal ram 
;--------------------------------------------------------
	rseg	R_OSEG
_Read_UFM_control_result_1_64:
	ds 4
	rseg	R_OSEG
_Write_UFM_control_PARM_2:
	ds 4
_Write_UFM_control_mybytes_1_66:
	ds 4
	rseg	R_OSEG
	rseg	R_OSEG
	rseg	R_OSEG
_Write_XRAM_PARM_2:
	ds 1
	rseg	R_OSEG
	rseg	R_OSEG
_str2hex_sloc0_1_0:
	ds 2
;--------------------------------------------------------
; indirectly addressable internal ram data
;--------------------------------------------------------
	rseg R_ISEG
_buff:
	ds 64
;--------------------------------------------------------
; absolute internal ram data
;--------------------------------------------------------
	DSEG
;--------------------------------------------------------
; bit data
;--------------------------------------------------------
	rseg R_BSEG
_getchar_echo:
	DBIT	1
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
	CSEG at 0xf000
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
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:42: bit getchar_echo=0;
	clr	_getchar_echo
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
;Allocation info for local variables in function 'Read_UFM_control'
;------------------------------------------------------------
;addr                      Allocated to registers r2 
;result                    Allocated with name '_Read_UFM_control_result_1_64'
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:50: unsigned long Read_UFM_control (unsigned char addr)
;	-----------------------------------------
;	 function Read_UFM_control
;	-----------------------------------------
_Read_UFM_control:
	using	0
	mov	r2,dpl
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:57: UFM_CONTROL_CMD=addr & 0b_001; // read=0, write=0	
	mov	a,#0x01
	anl	a,r2
	mov	_UFM_CONTROL_CMD,a
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:58: UFM_CONTROL_CMD|=0b_010; // read=1
	orl	_UFM_CONTROL_CMD,#0x02
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:59: UFM_CONTROL_CMD=0b_000; // read=0, write=0
	mov	_UFM_CONTROL_CMD,#0x00
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:61: result.byte[3]=UFM_CONTROL3;
	mov	(_Read_UFM_control_result_1_64 + 0x0003),_UFM_CONTROL3
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:62: result.byte[2]=UFM_CONTROL2;
	mov	(_Read_UFM_control_result_1_64 + 0x0002),_UFM_CONTROL2
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:63: result.byte[1]=UFM_CONTROL1;
	mov	(_Read_UFM_control_result_1_64 + 0x0001),_UFM_CONTROL1
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:64: result.byte[0]=UFM_CONTROL0;
	mov	_Read_UFM_control_result_1_64,_UFM_CONTROL0
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:66: return result.l;
	mov	dpl,_Read_UFM_control_result_1_64
	mov	dph,(_Read_UFM_control_result_1_64 + 1)
	mov	b,(_Read_UFM_control_result_1_64 + 2)
	mov	a,(_Read_UFM_control_result_1_64 + 3)
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'Write_UFM_control'
;------------------------------------------------------------
;value                     Allocated with name '_Write_UFM_control_PARM_2'
;addr                      Allocated to registers r2 
;mybytes                   Allocated with name '_Write_UFM_control_mybytes_1_66'
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:69: void Write_UFM_control (unsigned char addr, unsigned long value)
;	-----------------------------------------
;	 function Write_UFM_control
;	-----------------------------------------
_Write_UFM_control:
	mov	r2,dpl
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:76: mybytes.l=value;
	mov	_Write_UFM_control_mybytes_1_66,_Write_UFM_control_PARM_2
	mov	(_Write_UFM_control_mybytes_1_66 + 1),(_Write_UFM_control_PARM_2 + 1)
	mov	(_Write_UFM_control_mybytes_1_66 + 2),(_Write_UFM_control_PARM_2 + 2)
	mov	(_Write_UFM_control_mybytes_1_66 + 3),(_Write_UFM_control_PARM_2 + 3)
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:77: UFM_CONTROL3=mybytes.byte[3];
	mov	_UFM_CONTROL3,(_Write_UFM_control_mybytes_1_66 + 0x0003)
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:78: UFM_CONTROL2=mybytes.byte[2];
	mov	_UFM_CONTROL2,(_Write_UFM_control_mybytes_1_66 + 0x0002)
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:79: UFM_CONTROL1=mybytes.byte[1];
	mov	_UFM_CONTROL1,(_Write_UFM_control_mybytes_1_66 + 0x0001)
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:80: UFM_CONTROL0=mybytes.byte[0];
	mov	_UFM_CONTROL0,_Write_UFM_control_mybytes_1_66
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:82: UFM_CONTROL_CMD=addr & 0b_001; // read=0, write=0	
	mov	a,#0x01
	anl	a,r2
	mov	_UFM_CONTROL_CMD,a
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:83: UFM_CONTROL_CMD|=0b_100; // read=1
	orl	_UFM_CONTROL_CMD,#0x04
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:84: UFM_CONTROL_CMD=0b_000; // read=0, write=0
	mov	_UFM_CONTROL_CMD,#0x00
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'inituart'
;------------------------------------------------------------
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:136: void inituart (void)
;	-----------------------------------------
;	 function inituart
;	-----------------------------------------
_inituart:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:138: RCAP2H=HIGH(TIMER_2_RELOAD);
	mov	_RCAP2H,#0xFF
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:139: RCAP2L=LOW(TIMER_2_RELOAD);
	mov	_RCAP2L,#0xF7
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:140: T2CON=0x34; // #00110100B
	mov	_T2CON,#0x34
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:141: SCON=0x52; // Serial port in mode 1, ren, txrdy, rxempty
	mov	_SCON,#0x52
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'putchar'
;------------------------------------------------------------
;c                         Allocated to registers r2 
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:144: void putchar (char c)
;	-----------------------------------------
;	 function putchar
;	-----------------------------------------
_putchar:
	mov	r2,dpl
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:146: if (c=='\n')
	cjne	r2,#0x0A,L006006?
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:148: while (!TI);
L006001?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:149: TI=0;
	jbc	_TI,L006017?
	sjmp	L006001?
L006017?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:150: SBUF='\r';
	mov	_SBUF,#0x0D
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:152: while (!TI);
L006006?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:153: TI=0;
	jbc	_TI,L006018?
	sjmp	L006006?
L006018?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:154: SBUF=c;
	mov	_SBUF,r2
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'getchar'
;------------------------------------------------------------
;c                         Allocated to registers r2 
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:157: char getchar (void)
;	-----------------------------------------
;	 function getchar
;	-----------------------------------------
_getchar:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:161: while (!RI);
L007001?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:162: RI=0;
	jbc	_RI,L007011?
	sjmp	L007001?
L007011?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:163: c=SBUF;
	mov	r2,_SBUF
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:164: if (getchar_echo==1) putchar(c);
	jnb	_getchar_echo,L007005?
	mov	dpl,r2
	push	ar2
	lcall	_putchar
	pop	ar2
L007005?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:166: return c;
	mov	dpl,r2
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'getchare'
;------------------------------------------------------------
;c                         Allocated to registers r2 
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:169: char getchare (void)
;	-----------------------------------------
;	 function getchare
;	-----------------------------------------
_getchare:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:173: c=getchar();
	lcall	_getchar
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:174: putchar(c);
	mov  r2,dpl
	push	ar2
	lcall	_putchar
	pop	ar2
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:175: return c;
	mov	dpl,r2
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'sends'
;------------------------------------------------------------
;c                         Allocated to registers r2 r3 r4 
;n                         Allocated to registers r6 
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:178: void sends (unsigned char * c)
;	-----------------------------------------
;	 function sends
;	-----------------------------------------
_sends:
	mov	r2,dpl
	mov	r3,dph
	mov	r4,b
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:181: while(n=*c)
L009001?:
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	r5,a
	mov	r6,a
	jz	L009004?
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:183: putchar(n);
	mov	dpl,r6
	push	ar2
	push	ar3
	push	ar4
	lcall	_putchar
	pop	ar4
	pop	ar3
	pop	ar2
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:184: c++;
	inc	r2
	cjne	r2,#0x00,L009001?
	inc	r3
	sjmp	L009001?
L009004?:
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'chartohex'
;------------------------------------------------------------
;c                         Allocated to registers r2 
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:188: unsigned char chartohex(char c)
;	-----------------------------------------
;	 function chartohex
;	-----------------------------------------
_chartohex:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:190: if(c & 0x40) c+=9; //  a to f or A to F
	mov	a,dpl
	mov	r2,a
	jnb	acc.6,L010002?
	mov	a,#0x09
	add	a,r2
	mov	r2,a
L010002?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:191: return (c & 0xf);
	mov	a,#0x0F
	anl	a,r2
	mov	dpl,a
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'getbyte'
;------------------------------------------------------------
;j                         Allocated with name '_getbyte_j_1_82'
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:195: unsigned char getbyte (void)
;	-----------------------------------------
;	 function getbyte
;	-----------------------------------------
_getbyte:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:199: j=chartohex(getchare())*0x10;
	lcall	_getchare
	lcall	_chartohex
	mov	a,dpl
	swap	a
	anl	a,#0xf0
	mov	_getbyte_j_1_82,a
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:200: j|=chartohex(getchare());
	lcall	_getchare
	lcall	_chartohex
	mov	a,dpl
	orl	_getbyte_j_1_82,a
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:202: return j;
	mov	dpl,_getbyte_j_1_82
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'EraseSector'
;------------------------------------------------------------
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:205: void EraseSector (void)
;	-----------------------------------------
;	 function EraseSector
;	-----------------------------------------
_EraseSector:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:208: Write_UFM_control(1, 0x0f1fffffL); // (23 downto 20) <= '0001'
	mov	_Write_UFM_control_PARM_2,#0xFF
	mov	(_Write_UFM_control_PARM_2 + 1),#0xFF
	mov	(_Write_UFM_control_PARM_2 + 2),#0x1F
	mov	(_Write_UFM_control_PARM_2 + 3),#0x0F
	mov	dpl,#0x01
	lcall	_Write_UFM_control
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:210: while ((Read_UFM_control(0)&0x00000003L)!=0);
L012001?:
	mov	dpl,#0x00
	lcall	_Read_UFM_control
	mov	r2,dpl
	mov	r3,dph
	mov	r4,b
	mov	r5,a
	mov	a,r2
	anl	a,#0x03
	jz	L012008?
	sjmp	L012001?
L012008?:
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'Write_XRAM'
;------------------------------------------------------------
;Value                     Allocated with name '_Write_XRAM_PARM_2'
;Address                   Allocated to registers r2 r3 
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:213: void Write_XRAM (unsigned int Address, unsigned char Value)
;	-----------------------------------------
;	 function Write_XRAM
;	-----------------------------------------
_Write_XRAM:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:215: *((unsigned char xdata *) Address)=Value;
	mov	a,_Write_XRAM_PARM_2
	movx	@dptr,a
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'Read_XRAM'
;------------------------------------------------------------
;Address                   Allocated to registers r2 r3 
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:218: unsigned char Read_XRAM (unsigned int Address)
;	-----------------------------------------
;	 function Read_XRAM
;	-----------------------------------------
_Read_XRAM:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:220: return *((unsigned char xdata *) Address);
	movx	a,@dptr
	mov	dpl,a
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'Clear_XRAM'
;------------------------------------------------------------
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:225: void Clear_XRAM (void)
;	-----------------------------------------
;	 function Clear_XRAM
;	-----------------------------------------
_Clear_XRAM:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:227: XRAMUSEDAS=0x01; // 32k RAM accessed as xdata
	mov	_XRAMUSEDAS,#0x01
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:246: _endasm;
	
  ; Save used registers
	  push dpl
	  push dph
	  push acc
	  clr a
	  mov dpl, a
	  mov dph, a
	 Clear_XRAM_Loop:
	  clr a
	  movx @dptr, a
	  inc dptr
	  mov a, dph
	  jnb acc.7, Clear_XRAM_Loop ; Check when dph is equal to 0x80 after increment
	  pop acc
	  pop dph
	  pop dpl
	 
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'Copy_Flash_to_XRAM'
;------------------------------------------------------------
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:249: void Copy_Flash_to_XRAM (void)
;	-----------------------------------------
;	 function Copy_Flash_to_XRAM
;	-----------------------------------------
_Copy_Flash_to_XRAM:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:251: XRAMUSEDAS=0x01; // 32k RAM accessed as xdata
	mov	_XRAMUSEDAS,#0x01
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:299: _endasm;
	
  ; Save used registers
	  push dpl
	  push dph
	  push acc
	
  ; Init pointers
	  mov dptr, #0x0000
	  mov _UFM_ADD0, #0x00
	  mov _UFM_ADD1, #0x00
	  mov _UFM_ADD2, #0x00
	
  ; Copy loop
	 ufm2xram_loop:
	  mov _UFM_DATA_CMD, #0b_01_0001 ;
	  mov _UFM_DATA_CMD, #0b_00_0001 ;
	 ufm2xram_wait:
	  mov a, _UFM_DATA_STATUS
	  jnb acc.1, ufm2xram_wait
	
  ; Save the flash 32 bits to xram
	  mov a, _UFM_DATA0
	  movx @dptr, a
	  inc dptr
	  mov a, _UFM_DATA1
	  movx @dptr, a
	  inc dptr
	  mov a, _UFM_DATA2
	  movx @dptr, a
	  inc dptr
	  mov a, _UFM_DATA3
	  movx @dptr, a
	  inc dptr
	
  ; Increment destination address and check
	  inc _UFM_ADD0
	  mov a, _UFM_ADD0
	  jnz ufm2xram_loop
	  inc _UFM_ADD1
	  mov a, _UFM_ADD1
	  jnb acc.5, ufm2xram_loop ; UFM1 ends at 0x2000, so when bit 5 is '1' we are done.
	
  ; Restore used registers
	  pop acc
	  pop dph
	  pop dpl
	 
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'Load_Ram_Fast_and_Run'
;------------------------------------------------------------
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:302: void Load_Ram_Fast_and_Run (void)
;	-----------------------------------------
;	 function Load_Ram_Fast_and_Run
;	-----------------------------------------
_Load_Ram_Fast_and_Run:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:304: Copy_Flash_to_XRAM();
	lcall	_Copy_Flash_to_XRAM
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:306: T2CON=0;
	mov	_T2CON,#0x00
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:307: SCON=0;
	mov	_SCON,#0x00
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:308: RCAP2H=0;
	mov	_RCAP2H,#0x00
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:309: RCAP2L=0;
	mov	_RCAP2L,#0x00
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:316: _endasm;
	
	  mov _XRAMUSEDAS, #0 ; 32k RAM accessed as code
  ; RAM is loaded with user code. Run it.
	  mov sp, #7
	  ljmp 0x0000
	 
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'Load_Ram_Fast_and_Run_Debugger'
;------------------------------------------------------------
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:319: void Load_Ram_Fast_and_Run_Debugger (void)
;	-----------------------------------------
;	 function Load_Ram_Fast_and_Run_Debugger
;	-----------------------------------------
_Load_Ram_Fast_and_Run_Debugger:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:321: Copy_Flash_to_XRAM();
	lcall	_Copy_Flash_to_XRAM
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:323: T2CON=0;
	mov	_T2CON,#0x00
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:324: SCON=0;
	mov	_SCON,#0x00
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:325: RCAP2H=0;
	mov	_RCAP2H,#0x00
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:326: RCAP2L=0;
	mov	_RCAP2L,#0x00
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:327: LEDRA=0xff;
	mov	_LEDRA,#0xFF
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:328: LEDRB=0xff;
	mov	_LEDRB,#0xFF
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:336: _endasm;
	
	  mov _XRAMUSEDAS, #0 ; 32k RAM accessed as code
	  mov sp, #7
	
  ; RAM is loaded with user code. Run the debugger now.
	  ljmp 0xc000
	 
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'Copy_XRAM_to_UFM'
;------------------------------------------------------------
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:339: void Copy_XRAM_to_UFM (void)
;	-----------------------------------------
;	 function Copy_XRAM_to_UFM
;	-----------------------------------------
_Copy_XRAM_to_UFM:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:401: _endasm;
	
  ; Save used registers
	  push dpl
	  push dph
	  push acc
	  push b
	
  ; Init pointers
	  mov dptr, #0x0000
	  mov _UFM_ADD0, #0x00
	  mov _UFM_ADD1, #0x00
	  mov _UFM_ADD2, #0x00
	
  ; Copy loop
	 xram2ufm_loop:
  ; Load 32 bits from xram
	  movx a, @dptr
	  mov _UFM_DATA0, a
	  mov b, a
	  inc dptr
	  movx a, @dptr
	  mov _UFM_DATA1, a
	  orl b, a
	  inc dptr
	  movx a, @dptr
	  mov _UFM_DATA2, a
	  orl b, a
	  inc dptr
	  movx a, @dptr
	  mov _UFM_DATA3, a
	  orl a, b
	  inc dptr
	
	  jz xram2ufm_skip ; If all four bytes are zero, do not write to flash. In the implementation
                   ; of the interface to the UFM, both the input and output ports are inverted
                   ; so 0x00 is stored as 0xff in the flash. After erase, the flash is all 0xff.
	
	 xram2ufm_write:
  ; Write to flash
	  orl _UFM_DATA_CMD, #0b_10_0001 ; read=1, write=0, burstcount=0001b
	 xram2ufm_wait:
	  mov a, _UFM_DATA_STATUS
	  jb acc.0, xram2ufm_wait
	  mov _UFM_DATA_CMD, #0b_00_0001 ; read=0, write=0, burstcount=0000b
	 xram2ufm_skip:
	
  ; Increment destination address and check
	  inc _UFM_ADD0
	  mov a, _UFM_ADD0
	  jnz xram2ufm_loop
	  inc _UFM_ADD1
	  mov a, _UFM_ADD1
	  jnb acc.5, xram2ufm_loop ; UFM1 ends at 0x2000, so when bit 5 is '1' we are done.
	
	  setb _LEDRA_1
  ; Restore used registers
	  pop b
	  pop acc
	  pop dph
	  pop dpl
	 
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'loadintelhex'
;------------------------------------------------------------
;address                   Allocated with name '_loadintelhex_address_1_100'
;j                         Allocated with name '_loadintelhex_j_1_100'
;k                         Allocated with name '_loadintelhex_k_1_100'
;size                      Allocated with name '_loadintelhex_size_1_100'
;type                      Allocated with name '_loadintelhex_type_1_100'
;checksum                  Allocated with name '_loadintelhex_checksum_1_100'
;n                         Allocated with name '_loadintelhex_n_1_100'
;echo                      Allocated with name '_loadintelhex_echo_1_100'
;savedcs                   Allocated to registers r2 
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:404: void loadintelhex (void)
;	-----------------------------------------
;	 function loadintelhex
;	-----------------------------------------
_loadintelhex:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:411: while(1)
L020022?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:413: n=getchare();
	lcall	_getchare
	mov	_loadintelhex_n_1_100,dpl
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:415: if(n==(unsigned char)':')
	mov	a,#0x3A
	cjne	a,_loadintelhex_n_1_100,L020049?
	sjmp	L020050?
L020049?:
	ljmp	L020019?
L020050?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:417: echo='.'; // If everything works ok, send a period...
	mov	_loadintelhex_echo_1_100,#0x2E
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:418: size=getbyte();
	lcall	_getbyte
	mov	_loadintelhex_size_1_100,dpl
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:419: checksum=size;
	mov	_loadintelhex_checksum_1_100,_loadintelhex_size_1_100
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:421: address=getbyte();
	lcall	_getbyte
	mov	r2,dpl
	mov	_loadintelhex_address_1_100,r2
	mov	(_loadintelhex_address_1_100 + 1),#0x00
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:422: checksum+=address;
	mov	r2,_loadintelhex_address_1_100
	mov	a,r2
	add	a,_loadintelhex_checksum_1_100
	mov	_loadintelhex_checksum_1_100,a
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:423: address*=0x100;
	mov	(_loadintelhex_address_1_100 + 1),_loadintelhex_address_1_100
	mov	_loadintelhex_address_1_100,#0x00
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:424: n=getbyte();
	lcall	_getbyte
	mov	_loadintelhex_n_1_100,dpl
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:425: checksum+=n;
	mov	a,_loadintelhex_n_1_100
	add	a,_loadintelhex_checksum_1_100
	mov	_loadintelhex_checksum_1_100,a
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:426: address+=n;
	mov	r2,_loadintelhex_n_1_100
	mov	r3,#0x00
	mov	a,r2
	add	a,_loadintelhex_address_1_100
	mov	_loadintelhex_address_1_100,a
	mov	a,r3
	addc	a,(_loadintelhex_address_1_100 + 1)
	mov	(_loadintelhex_address_1_100 + 1),a
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:428: type=getbyte();
	lcall	_getbyte
	mov	_loadintelhex_type_1_100,dpl
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:429: checksum+=type;
	mov	a,_loadintelhex_type_1_100
	add	a,_loadintelhex_checksum_1_100
	mov	_loadintelhex_checksum_1_100,a
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:431: for(j=0; j<size; j++)
	mov	_loadintelhex_j_1_100,#0x00
L020024?:
	clr	c
	mov	a,_loadintelhex_j_1_100
	subb	a,_loadintelhex_size_1_100
	jnc	L020027?
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:433: n=getbyte();
	lcall	_getbyte
	mov	_loadintelhex_n_1_100,dpl
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:434: if(j<MAXBUFF) buff[j]=n; // Don't overrun the buffer
	mov	a,#0x100 - 0x40
	add	a,_loadintelhex_j_1_100
	jc	L020002?
	mov	a,_loadintelhex_j_1_100
	add	a,#_buff
	mov	r0,a
	mov	@r0,_loadintelhex_n_1_100
L020002?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:435: checksum+=n;
	mov	a,_loadintelhex_n_1_100
	add	a,_loadintelhex_checksum_1_100
	mov	_loadintelhex_checksum_1_100,a
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:431: for(j=0; j<size; j++)
	inc	_loadintelhex_j_1_100
	sjmp	L020024?
L020027?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:438: savedcs=getbyte();
	lcall	_getbyte
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:439: checksum+=savedcs;
	mov	a,dpl
	mov	r2,a
	add	a,_loadintelhex_checksum_1_100
	mov	_loadintelhex_checksum_1_100,a
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:440: if(size>MAXBUFF) checksum=1; // Force a checksum error
	mov	a,_loadintelhex_size_1_100
	add	a,#0xff - 0x40
	jnc	L020004?
	mov	_loadintelhex_checksum_1_100,#0x01
L020004?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:442: if(checksum==0) switch(type)
	mov	a,_loadintelhex_checksum_1_100
	jnz	L020012?
	mov	r2,_loadintelhex_type_1_100
	cjne	r2,#0x00,L020055?
	sjmp	L020006?
L020055?:
	cjne	r2,#0x01,L020056?
	sjmp	L020008?
L020056?:
	cjne	r2,#0x03,L020057?
	sjmp	L020007?
L020057?:
	cjne	r2,#0x04,L020009?
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:445: EraseSector();
	lcall	_EraseSector
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:446: Clear_XRAM();
	lcall	_Clear_XRAM
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:447: LEDRA_1=1; // Flash erased
	setb	_LEDRA_1
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:448: break;
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:450: case 0: // Write to XRAM
	sjmp	L020013?
L020006?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:451: for(k=0; k<j; k++)
	mov	_loadintelhex_k_1_100,#0x00
L020028?:
	clr	c
	mov	a,_loadintelhex_k_1_100
	subb	a,_loadintelhex_j_1_100
	jnc	L020013?
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:453: Write_XRAM(address, buff[k]);
	mov	a,_loadintelhex_k_1_100
	add	a,#_buff
	mov	r0,a
	mov	_Write_XRAM_PARM_2,@r0
	mov	dpl,_loadintelhex_address_1_100
	mov	dph,(_loadintelhex_address_1_100 + 1)
	lcall	_Write_XRAM
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:454: address++;
	mov	a,#0x01
	add	a,_loadintelhex_address_1_100
	mov	_loadintelhex_address_1_100,a
	clr	a
	addc	a,(_loadintelhex_address_1_100 + 1)
	mov	(_loadintelhex_address_1_100 + 1),a
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:451: for(k=0; k<j; k++)
	inc	_loadintelhex_k_1_100
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:458: case 3: // Send ID number command.
	sjmp	L020028?
L020007?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:459: sends("DE1");
	mov	dptr,#__str_0
	mov	b,#0x80
	lcall	_sends
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:460: break;
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:462: case 1: // End record: Write XRAM to flash
	sjmp	L020013?
L020008?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:463: putchar(echo); // Acknowledge inmediatly
	mov	dpl,_loadintelhex_echo_1_100
	lcall	_putchar
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:464: Copy_XRAM_to_UFM();
	lcall	_Copy_XRAM_to_UFM
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:465: LEDRA_2=1; // Flash loaded
	setb	_LEDRA_2
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:466: break;
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:468: default: // Unknown command;
	sjmp	L020013?
L020009?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:469: echo='?';
	mov	_loadintelhex_echo_1_100,#0x3F
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:470: LEDRA_2=1;
	setb	_LEDRA_2
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:472: }
	sjmp	L020013?
L020012?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:475: echo='X'; // Checksum error
	mov	_loadintelhex_echo_1_100,#0x58
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:476: LEDRA_1=1;
	setb	_LEDRA_1
L020013?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:478: if(type!=1) putchar(echo);
	mov	a,#0x01
	cjne	a,_loadintelhex_type_1_100,L020061?
	ljmp	L020022?
L020061?:
	mov	dpl,_loadintelhex_echo_1_100
	lcall	_putchar
	ljmp	L020022?
L020019?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:480: else if(n==(unsigned char)'U')
	mov	a,#0x55
	cjne	a,_loadintelhex_n_1_100,L020062?
	sjmp	L020063?
L020062?:
	ljmp	L020022?
L020063?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:482: LEDRA=0;
	mov	_LEDRA,#0x00
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:483: LEDRB=0;
	mov	_LEDRB,#0x00
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:484: LEDRA=1; // Bootloader running
	mov	_LEDRA,#0x01
	ljmp	L020022?
;------------------------------------------------------------
;Allocation info for local variables in function 'str2hex'
;------------------------------------------------------------
;s                         Allocated to registers r2 r3 r4 
;x                         Allocated to registers r5 r6 
;i                         Allocated to registers r7 
;sloc0                     Allocated with name '_str2hex_sloc0_1_0'
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:489: unsigned int str2hex (char * s)
;	-----------------------------------------
;	 function str2hex
;	-----------------------------------------
_str2hex:
	mov	r2,dpl
	mov	r3,dph
	mov	r4,b
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:491: unsigned int x=0;
	mov	r5,#0x00
	mov	r6,#0x00
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:493: while(*s)
L021013?:
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	r7,a
	jnz	L021027?
	ljmp	L021015?
L021027?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:495: if((*s>='0')&&(*s<='9')) i=*s-'0';
	clr	c
	mov	a,r7
	xrl	a,#0x80
	subb	a,#0xb0
	jc	L021010?
	mov	a,#(0x39 ^ 0x80)
	mov	b,r7
	xrl	b,#0x80
	subb	a,b
	jc	L021010?
	mov	a,r7
	add	a,#0xd0
	mov	r7,a
	sjmp	L021011?
L021010?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:496: else if ( (*s>='A') && (*s<='F') ) i=*s-'A'+10;
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	r0,a
	clr	c
	xrl	a,#0x80
	subb	a,#0xc1
	jc	L021006?
	mov	a,#(0x46 ^ 0x80)
	mov	b,r0
	xrl	b,#0x80
	subb	a,b
	jc	L021006?
	mov	a,#0xC9
	add	a,r0
	mov	r7,a
	sjmp	L021011?
L021006?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:497: else if ( (*s>='a') && (*s<='f') ) i=*s-'a'+10;
	clr	c
	mov	a,r0
	xrl	a,#0x80
	subb	a,#0xe1
	jc	L021015?
	mov	a,#(0x66 ^ 0x80)
	mov	b,r0
	xrl	b,#0x80
	subb	a,b
	jc	L021015?
	mov	a,#0xA9
	add	a,r0
	mov	r7,a
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:498: else break;
L021011?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:499: x=(x*0x10)+i;
	mov	_str2hex_sloc0_1_0,r5
	mov	a,r6
	swap	a
	anl	a,#0xf0
	xch	a,_str2hex_sloc0_1_0
	swap	a
	xch	a,_str2hex_sloc0_1_0
	xrl	a,_str2hex_sloc0_1_0
	xch	a,_str2hex_sloc0_1_0
	anl	a,#0xf0
	xch	a,_str2hex_sloc0_1_0
	xrl	a,_str2hex_sloc0_1_0
	mov	(_str2hex_sloc0_1_0 + 1),a
	mov	r0,#0x00
	mov	a,r7
	add	a,_str2hex_sloc0_1_0
	mov	r5,a
	mov	a,r0
	addc	a,(_str2hex_sloc0_1_0 + 1)
	mov	r6,a
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:500: s++;
	inc	r2
	cjne	r2,#0x00,L021034?
	inc	r3
L021034?:
	ljmp	L021013?
L021015?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:502: return x;
	mov	dpl,r5
	mov	dph,r6
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'OutByte'
;------------------------------------------------------------
;x                         Allocated to registers r2 
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:505: void OutByte (unsigned char x)
;	-----------------------------------------
;	 function OutByte
;	-----------------------------------------
_OutByte:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:507: putchar(hexval[x/0x10]);
	mov	a,dpl
	mov	r2,a
	swap	a
	anl	a,#0x0f
	mov	dptr,#_hexval
	movc	a,@a+dptr
	mov	dpl,a
	push	ar2
	lcall	_putchar
	pop	ar2
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:508: putchar(hexval[x%0x10]);
	mov	a,#0x0F
	anl	a,r2
	mov	dptr,#_hexval
	movc	a,@a+dptr
	mov	dpl,a
	ljmp	_putchar
;------------------------------------------------------------
;Allocation info for local variables in function 'OutWord'
;------------------------------------------------------------
;x                         Allocated to registers r2 r3 
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:511: void OutWord (unsigned int x)
;	-----------------------------------------
;	 function OutWord
;	-----------------------------------------
_OutWord:
	mov	r2,dpl
	mov	r3,dph
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:513: OutByte(x/0x100);
	mov	ar4,r3
	mov	dpl,r4
	push	ar2
	push	ar3
	lcall	_OutByte
	pop	ar3
	pop	ar2
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:514: OutByte(x%0x100);
	mov	dpl,r2
	ljmp	_OutByte
;------------------------------------------------------------
;Allocation info for local variables in function 'Manual_Load'
;------------------------------------------------------------
;add                       Allocated to registers r2 r3 
;val                       Allocated to registers r4 
;h_add                     Allocated to registers r4 
;l_add                     Allocated to registers r5 
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:520: void Manual_Load (void)
;	-----------------------------------------
;	 function Manual_Load
;	-----------------------------------------
_Manual_Load:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:526: Copy_Flash_to_XRAM();
	lcall	_Copy_Flash_to_XRAM
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:528: LEDRA=0;
	mov	_LEDRA,#0x00
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:529: LEDRB=0;
	mov	_LEDRB,#0x00
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:531: add=0;
	mov	r2,#0x00
	mov	r3,#0x00
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:533: while(1)
L024040?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:536: h_add=add/0x100;
	mov	ar4,r3
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:537: l_add=add%0x100;
	mov	ar5,r2
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:538: HEX5=seven_seg[h_add/0x10];
	mov	a,r4
	swap	a
	anl	a,#0x0f
	mov	dptr,#_seven_seg
	movc	a,@a+dptr
	mov	_HEX5,a
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:539: HEX4=seven_seg[h_add%0x10];
	mov	a,#0x0F
	anl	a,r4
	mov	dptr,#_seven_seg
	movc	a,@a+dptr
	mov	_HEX4,a
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:540: HEX3=seven_seg[l_add/0x10];
	mov	a,r5
	swap	a
	anl	a,#0x0f
	mov	dptr,#_seven_seg
	movc	a,@a+dptr
	mov	_HEX3,a
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:541: HEX2=seven_seg[l_add%0x10];
	mov	a,#0x0F
	anl	a,r5
	mov	dptr,#_seven_seg
	movc	a,@a+dptr
	mov	_HEX2,a
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:543: val=Read_XRAM(add);
	mov	dpl,r2
	mov	dph,r3
	push	ar2
	push	ar3
	lcall	_Read_XRAM
	mov	r4,dpl
	pop	ar3
	pop	ar2
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:544: HEX1=seven_seg[val/0x10];
	mov	a,r4
	swap	a
	anl	a,#0x0f
	mov	r5,a
	mov	dptr,#_seven_seg
	movc	a,@a+dptr
	mov	_HEX1,a
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:545: HEX0=seven_seg[val%0x10];
	mov	a,#0x0F
	anl	a,r4
	mov	dptr,#_seven_seg
	movc	a,@a+dptr
	mov	_HEX0,a
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:547: if((KEY_2==0) && (KEY_1==1))
	jb	_KEY_2,L024036?
	jnb	_KEY_1,L024036?
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:549: while (KEY_2==0); // Wait for key release
L024001?:
	jnb	_KEY_2,L024001?
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:550: if((SWB&0x01)==0x01) // Reading address low
	mov	a,#0x01
	anl	a,_SWB
	mov	r4,a
	cjne	r4,#0x01,L024010?
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:552: add&=0x7f00;
	mov	r2,#0x00
	anl	ar3,#0x7F
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:553: add|=SWA;	
	mov	r4,_SWA
	mov	r5,#0x00
	mov	a,r4
	orl	ar2,a
	mov	a,r5
	orl	ar3,a
	sjmp	L024040?
L024010?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:555: else if((SWB&0x02)==0x02) // Reading address high
	mov	a,#0x02
	anl	a,_SWB
	mov	r4,a
	cjne	r4,#0x02,L024007?
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:557: add&=0x00ff;
	mov	r3,#0x00
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:558: add|=(SWA*0x100);	
	mov	r4,_SWA
	mov	ar5,r4
	clr	a
	mov	r4,a
	orl	ar2,a
	mov	a,r5
	orl	ar3,a
	ljmp	L024040?
L024007?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:560: else if ((SWB&0x03)==0) // Reading data
	mov	a,_SWB
	anl	a,#0x03
	jz	L024068?
	ljmp	L024040?
L024068?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:562: val=SWA;
	mov	_Write_XRAM_PARM_2,_SWA
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:563: Write_XRAM(add, val);
	mov	dpl,r2
	mov	dph,r3
	push	ar2
	push	ar3
	lcall	_Write_XRAM
	pop	ar3
	pop	ar2
	ljmp	L024040?
L024036?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:567: else if(KEY_4==0) // Increment address
	jb	_KEY_4,L024033?
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:569: while(KEY_4==0); // Wait for key release
L024012?:
	jnb	_KEY_4,L024012?
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:570: LEDRA_1=0;
	clr	_LEDRA_1
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:571: LEDRA_2=0;
	clr	_LEDRA_2
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:572: add++;
	inc	r2
	cjne	r2,#0x00,L024071?
	inc	r3
L024071?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:573: if (add>0x7fff) add=0;
	clr	c
	mov	a,#0xFF
	subb	a,r2
	mov	a,#0x7F
	subb	a,r3
	jc	L024072?
	ljmp	L024040?
L024072?:
	mov	r2,#0x00
	mov	r3,#0x00
	ljmp	L024040?
L024033?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:575: else if (KEY_3==0) // Decrement address
	jb	_KEY_3,L024030?
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:577: while(KEY_3==0); // Wait for key release
L024017?:
	jnb	_KEY_3,L024017?
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:578: LEDRA_1=0;
	clr	_LEDRA_1
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:579: LEDRA_2=0;
	clr	_LEDRA_2
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:580: add--;
	dec	r2
	cjne	r2,#0xff,L024075?
	dec	r3
L024075?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:581: if (add>0x7fff) add=0x7fff;
	clr	c
	mov	a,#0xFF
	subb	a,r2
	mov	a,#0x7F
	subb	a,r3
	jc	L024076?
	ljmp	L024040?
L024076?:
	mov	r2,#0xFF
	mov	r3,#0x7F
	ljmp	L024040?
L024030?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:583: else if ( (KEY_2==0) && (KEY_1==0) ) // Save RAM to flash
	jnb	_KEY_2,L024077?
	ljmp	L024040?
L024077?:
	jnb	_KEY_1,L024078?
	ljmp	L024040?
L024078?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:585: while( (KEY_2==0) && (KEY_1==0) ); // Wait for key release
L024023?:
	jb	_KEY_2,L024025?
	jnb	_KEY_1,L024023?
L024025?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:586: EraseSector();
	push	ar2
	push	ar3
	lcall	_EraseSector
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:587: LEDRA_1=1;
	setb	_LEDRA_1
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:588: Copy_XRAM_to_UFM();
	lcall	_Copy_XRAM_to_UFM
	pop	ar3
	pop	ar2
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:589: LEDRA_2=1;
	setb	_LEDRA_2
	ljmp	L024040?
;------------------------------------------------------------
;Allocation info for local variables in function 'main'
;------------------------------------------------------------
;d                         Allocated to registers r2 
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:603: void main (void)
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:608: UFM_DATA_CMD=0x00;
	mov	_UFM_DATA_CMD,#0x00
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:609: UFM_CONTROL_CMD=0x00;
	mov	_UFM_CONTROL_CMD,#0x00
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:611: KEY_2=0; // Ground por key2
	clr	_KEY_2
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:612: KEY_3=0; // Ground por key3
	clr	_KEY_3
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:614: if( (KEY_1==1) && (KEY_3==1) && (KEY_4==1) ) Load_Ram_Fast_and_Run();
	jnb	_KEY_1,L025002?
	jnb	_KEY_3,L025002?
	jnb	_KEY_4,L025002?
	lcall	_Load_Ram_Fast_and_Run
L025002?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:616: if (KEY_4==0) // Run debugger?
	jb	_KEY_4,L025009?
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:618: HEX5=LetterD;
	mov	_HEX5,#0xA1
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:619: HEX4=LetterE;
	mov	_HEX4,#0x86
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:620: HEX3=LetterB;
	mov	_HEX3,#0x83
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:621: HEX2=LetterU;
	mov	_HEX2,#0xC1
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:622: HEX1=LetterG;
	mov	_HEX1,#0xC2
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:623: HEX0=LetterG;
	mov	_HEX0,#0xC2
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:626: while(KEY_4==0);
L025005?:
	jnb	_KEY_4,L025005?
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:628: HEX0=0xff;
	mov	_HEX0,#0xFF
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:629: HEX1=0xff;
	mov	_HEX1,#0xFF
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:630: HEX2=0xff;
	mov	_HEX2,#0xFF
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:631: HEX3=0xff;
	mov	_HEX3,#0xFF
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:632: HEX4=0xff;
	mov	_HEX4,#0xFF
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:633: HEX5=0xff;
	mov	_HEX5,#0xFF
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:635: Load_Ram_Fast_and_Run_Debugger();
	lcall	_Load_Ram_Fast_and_Run_Debugger
L025009?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:638: if (KEY_3==0)
	jb	_KEY_3,L025014?
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:640: HEX5=Dash;
	mov	_HEX5,#0xBF
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:641: HEX4=Dash;
	mov	_HEX4,#0xBF
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:642: HEX3=Dash;
	mov	_HEX3,#0xBF
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:643: HEX2=Dash;
	mov	_HEX2,#0xBF
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:644: HEX1=Dash;
	mov	_HEX1,#0xBF
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:645: HEX0=Dash;
	mov	_HEX0,#0xBF
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:647: while(KEY_3==0);
L025010?:
	jnb	_KEY_3,L025010?
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:649: Manual_Load();
	lcall	_Manual_Load
L025014?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:652: XRAMUSEDAS=1; // 32k RAM accessed as xdata
	mov	_XRAMUSEDAS,#0x01
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:654: HEX3=LetterB;
	mov	_HEX3,#0x83
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:655: HEX2=LetterO;
	mov	_HEX2,#0xA3
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:656: HEX1=LetterO;
	mov	_HEX1,#0xA3
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:657: HEX0=LetterT;
	mov	_HEX0,#0x87
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:659: while(KEY_1==0); // Wait for key release
L025015?:
	jnb	_KEY_1,L025015?
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:661: LEDRA=1;// Bootloader running
	mov	_LEDRA,#0x01
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:662: LEDRB=0;
	mov	_LEDRB,#0x00
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:664: HEX0=0xff;
	mov	_HEX0,#0xFF
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:665: HEX1=0xff;
	mov	_HEX1,#0xFF
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:666: HEX2=0xff;
	mov	_HEX2,#0xFF
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:667: HEX3=0xff;
	mov	_HEX3,#0xFF
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:668: HEX4=0xff;
	mov	_HEX4,#0xFF
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:669: HEX5=0xff;
	mov	_HEX5,#0xFF
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:671: inituart();
	lcall	_inituart
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:675: Write_XRAM(MEMORY_KEY, 0x00);
	mov	_Write_XRAM_PARM_2,#0x00
	mov	dptr,#0x7FFF
	lcall	_Write_XRAM
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:678: while(1)
L025025?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:680: if (RI==1)
	jnb	_RI,L025021?
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:682: d=SBUF;
	mov	r2,_SBUF
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:683: RI=0;
	clr	_RI
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:684: if(d==(unsigned char)'U') break;
	cjne	r2,#0x55,L025053?
	sjmp	L025026?
L025053?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:685: TI=0; // Echo what was received
	clr	_TI
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:686: SBUF=d;
	mov	_SBUF,r2
L025021?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:689: if(Read_XRAM(MEMORY_KEY)!=0x00)
	mov	dptr,#0x7FFF
	lcall	_Read_XRAM
	mov	a,dpl
	jz	L025025?
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:691: LEDRA_1=0;
	clr	_LEDRA_1
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:692: LEDRA_2=0;
	clr	_LEDRA_2
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:693: Write_XRAM(MEMORY_KEY, 0x00);
	mov	_Write_XRAM_PARM_2,#0x00
	mov	dptr,#0x7FFF
	lcall	_Write_XRAM
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:694: EraseSector();
	lcall	_EraseSector
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:695: LEDRA_1=1;
	setb	_LEDRA_1
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:696: Copy_XRAM_to_UFM();
	lcall	_Copy_XRAM_to_UFM
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:697: LEDRA_2=1;
	setb	_LEDRA_2
	sjmp	L025025?
L025026?:
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:701: loadintelhex();
	ljmp	_loadintelhex
;------------------------------------------------------------
;Allocation info for local variables in function 'dummy_switch'
;------------------------------------------------------------
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:704: void dummy_switch(void) __naked
;	-----------------------------------------
;	 function dummy_switch
;	-----------------------------------------
_dummy_switch:
;	naked function: no prologue.
;	C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c:716: _endasm;
	
	  CSEG at 0xFFE0
	  mov _XRAMUSEDAS, #0x00 ; 32k RAM accessed as code
	  nop
	  ret
	
	  CSEG at 0xffE8
	  mov _XRAMUSEDAS, #0x01 ; 32k RAM accessed as xdata
	  nop
	  ret
	 
;	naked function: no epilogue.
	rseg R_CSEG

	rseg R_XINIT

	rseg R_CONST
_hexval:
	db '0123456789ABCDEF'
	db 0x00
__str_0:
	db 'DE1'
	db 0x00
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

	CSEG

end
