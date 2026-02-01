;--------------------------------------------------------
; File Created by C51
; Version 1.0.0 #1034 (May  5 2015) (MSVC)
; This file was generated Wed Oct 02 13:11:38 2024
;--------------------------------------------------------
$name NewRegsTest
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
	public _Write_UFM_data_bytes_PARM_2
	public _Read_UFM_data_bytes_PARM_2
	public _Write_UFM_data_PARM_2
	public _Write_UFM_control_PARM_2
	public _main
	public _Write_UFM_data_bytes
	public _Read_UFM_data_bytes
	public _Write_UFM_data
	public _Read_UFM_data
	public _Write_UFM_control
	public _Read_UFM_control
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
_LCD_CMD        DATA 0xd8
_LCD_DATA       DATA 0xd9
_LCD_MOD        DATA 0xda
_JCMD           DATA 0xc0
_JBUF           DATA 0xc1
_JCNT           DATA 0xc2
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
_P4             DATA 0xb1
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
_LCD_RW         BIT 0xd8
_LCD_EN         BIT 0xd9
_LCD_RS         BIT 0xda
_LCD_ON         BIT 0xdb
_LCD_BLON       BIT 0xdc
_JRXRDY         BIT 0xc0
_JTXRDY         BIT 0xc1
_JRXEN          BIT 0xc2
_JTXEN          BIT 0xc3
_JTXFULL        BIT 0xc4
_JRXFULL        BIT 0xc5
_JTXEMPTY       BIT 0xc6
_JTDI           BIT 0xc7
;--------------------------------------------------------
; overlayable register banks
;--------------------------------------------------------
	rbank0 segment data overlay
;--------------------------------------------------------
; internal ram data
;--------------------------------------------------------
	rseg R_DSEG
_main_mybytes_1_59:
	ds 4
_main_sloc0_1_0:
	ds 2
;--------------------------------------------------------
; overlayable items in internal ram 
;--------------------------------------------------------
	rseg	R_OSEG
_Read_UFM_control_result_1_47:
	ds 4
	rseg	R_OSEG
_Write_UFM_control_PARM_2:
	ds 4
_Write_UFM_control_mybytes_1_49:
	ds 4
	rseg	R_OSEG
_Read_UFM_data_result_1_51:
	ds 4
	rseg	R_OSEG
_Write_UFM_data_PARM_2:
	ds 4
_Write_UFM_data_mybytes_1_53:
	ds 4
	rseg	R_OSEG
_Read_UFM_data_bytes_PARM_2:
	ds 3
	rseg	R_OSEG
_Write_UFM_data_bytes_PARM_2:
	ds 3
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
;	C:/Source/call51/bin/../include/mcs51/MAX10_8052.h:314: void de2_8052_crt0 (void) _naked
;	-----------------------------------------
;	 function de2_8052_crt0
;	-----------------------------------------
_de2_8052_crt0:
;	naked function: no prologue.
;	C:/Source/call51/bin/../include/mcs51/MAX10_8052.h:383: _endasm;
	
	
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
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:21: unsigned char _c51_external_startup(void)
;	-----------------------------------------
;	 function _c51_external_startup
;	-----------------------------------------
__c51_external_startup:
	using	0
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:23: RCAP2H=HIGH(TIMER_2_RELOAD);
	mov	_RCAP2H,#0xFF
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:24: RCAP2L=LOW(TIMER_2_RELOAD);
	mov	_RCAP2L,#0xF7
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:25: T2CON=0x34; // #00110100B
	mov	_T2CON,#0x34
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:26: SCON=0x52; // Serial port in mode 1, ren, txrdy, rxempty
	mov	_SCON,#0x52
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:28: return 0;
	mov	dpl,#0x00
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'Read_UFM_control'
;------------------------------------------------------------
;addr                      Allocated to registers r2 
;result                    Allocated with name '_Read_UFM_control_result_1_47'
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:31: unsigned long Read_UFM_control (unsigned char addr)
;	-----------------------------------------
;	 function Read_UFM_control
;	-----------------------------------------
_Read_UFM_control:
	mov	r2,dpl
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:38: UFM_CONTROL_CMD=addr & 0b_001; // read=0, write=0	
	mov	a,#0x01
	anl	a,r2
	mov	_UFM_CONTROL_CMD,a
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:39: UFM_CONTROL_CMD|=0b_010; // read=1
	orl	_UFM_CONTROL_CMD,#0x02
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:40: UFM_CONTROL_CMD=0b_000; // read=0, write=0
	mov	_UFM_CONTROL_CMD,#0x00
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:42: result.byte[3]=UFM_CONTROL3;
	mov	(_Read_UFM_control_result_1_47 + 0x0003),_UFM_CONTROL3
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:43: result.byte[2]=UFM_CONTROL2;
	mov	(_Read_UFM_control_result_1_47 + 0x0002),_UFM_CONTROL2
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:44: result.byte[1]=UFM_CONTROL1;
	mov	(_Read_UFM_control_result_1_47 + 0x0001),_UFM_CONTROL1
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:45: result.byte[0]=UFM_CONTROL0;
	mov	_Read_UFM_control_result_1_47,_UFM_CONTROL0
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:47: return result.l;
	mov	dpl,_Read_UFM_control_result_1_47
	mov	dph,(_Read_UFM_control_result_1_47 + 1)
	mov	b,(_Read_UFM_control_result_1_47 + 2)
	mov	a,(_Read_UFM_control_result_1_47 + 3)
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'Write_UFM_control'
;------------------------------------------------------------
;value                     Allocated with name '_Write_UFM_control_PARM_2'
;addr                      Allocated to registers r2 
;mybytes                   Allocated with name '_Write_UFM_control_mybytes_1_49'
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:50: void Write_UFM_control (unsigned char addr, unsigned long value)
;	-----------------------------------------
;	 function Write_UFM_control
;	-----------------------------------------
_Write_UFM_control:
	mov	r2,dpl
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:57: mybytes.l=value;
	mov	_Write_UFM_control_mybytes_1_49,_Write_UFM_control_PARM_2
	mov	(_Write_UFM_control_mybytes_1_49 + 1),(_Write_UFM_control_PARM_2 + 1)
	mov	(_Write_UFM_control_mybytes_1_49 + 2),(_Write_UFM_control_PARM_2 + 2)
	mov	(_Write_UFM_control_mybytes_1_49 + 3),(_Write_UFM_control_PARM_2 + 3)
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:58: UFM_CONTROL3=mybytes.byte[3];
	mov	_UFM_CONTROL3,(_Write_UFM_control_mybytes_1_49 + 0x0003)
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:59: UFM_CONTROL2=mybytes.byte[2];
	mov	_UFM_CONTROL2,(_Write_UFM_control_mybytes_1_49 + 0x0002)
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:60: UFM_CONTROL1=mybytes.byte[1];
	mov	_UFM_CONTROL1,(_Write_UFM_control_mybytes_1_49 + 0x0001)
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:61: UFM_CONTROL0=mybytes.byte[0];
	mov	_UFM_CONTROL0,_Write_UFM_control_mybytes_1_49
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:63: UFM_CONTROL_CMD=addr & 0b_001; // read=0, write=0	
	mov	a,#0x01
	anl	a,r2
	mov	_UFM_CONTROL_CMD,a
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:64: UFM_CONTROL_CMD|=0b_100; // read=1
	orl	_UFM_CONTROL_CMD,#0x04
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:65: UFM_CONTROL_CMD=0b_000; // read=0, write=0
	mov	_UFM_CONTROL_CMD,#0x00
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'Read_UFM_data'
;------------------------------------------------------------
;addr                      Allocated to registers r2 r3 r4 r5 
;result                    Allocated with name '_Read_UFM_data_result_1_51'
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:68: unsigned long Read_UFM_data (unsigned long addr)
;	-----------------------------------------
;	 function Read_UFM_data
;	-----------------------------------------
_Read_UFM_data:
	mov	r2,dpl
	mov	r3,dph
	mov	r4,b
	mov	r5,a
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:77: result.l=addr;
	mov	_Read_UFM_data_result_1_51,r2
	mov	(_Read_UFM_data_result_1_51 + 1),r3
	mov	(_Read_UFM_data_result_1_51 + 2),r4
	mov	(_Read_UFM_data_result_1_51 + 3),r5
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:78: UFM_ADD0=result.byte[0];
	mov	_UFM_ADD0,_Read_UFM_data_result_1_51
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:79: UFM_ADD1=result.byte[1];
	mov	_UFM_ADD1,(_Read_UFM_data_result_1_51 + 0x0001)
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:80: UFM_ADD2=result.byte[2];
	mov	_UFM_ADD2,(_Read_UFM_data_result_1_51 + 0x0002)
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:84: UFM_DATA_CMD=0b_01_0001; // write=0, read=1, burstcount=0001b
	mov	_UFM_DATA_CMD,#0x11
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:85: UFM_DATA_CMD=0b_00_0001; // read=0, write=0
	mov	_UFM_DATA_CMD,#0x01
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:87: while((UFM_DATA_STATUS&0x02)!=0x02);// Wait for readdatavalid
L006001?:
	mov	a,#0x02
	anl	a,_UFM_DATA_STATUS
	mov	r2,a
	cjne	r2,#0x02,L006001?
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:89: result.byte[3]=UFM_DATA3;
	mov	(_Read_UFM_data_result_1_51 + 0x0003),_UFM_DATA3
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:90: result.byte[2]=UFM_DATA2;
	mov	(_Read_UFM_data_result_1_51 + 0x0002),_UFM_DATA2
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:91: result.byte[1]=UFM_DATA1;
	mov	(_Read_UFM_data_result_1_51 + 0x0001),_UFM_DATA1
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:92: result.byte[0]=UFM_DATA0;
	mov	_Read_UFM_data_result_1_51,_UFM_DATA0
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:94: return result.l;
	mov	dpl,_Read_UFM_data_result_1_51
	mov	dph,(_Read_UFM_data_result_1_51 + 1)
	mov	b,(_Read_UFM_data_result_1_51 + 2)
	mov	a,(_Read_UFM_data_result_1_51 + 3)
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'Write_UFM_data'
;------------------------------------------------------------
;value                     Allocated with name '_Write_UFM_data_PARM_2'
;addr                      Allocated to registers r2 r3 r4 r5 
;mybytes                   Allocated with name '_Write_UFM_data_mybytes_1_53'
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:97: void Write_UFM_data (unsigned long addr, unsigned long value)
;	-----------------------------------------
;	 function Write_UFM_data
;	-----------------------------------------
_Write_UFM_data:
	mov	r2,dpl
	mov	r3,dph
	mov	r4,b
	mov	r5,a
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:106: mybytes.l=addr;
	mov	_Write_UFM_data_mybytes_1_53,r2
	mov	(_Write_UFM_data_mybytes_1_53 + 1),r3
	mov	(_Write_UFM_data_mybytes_1_53 + 2),r4
	mov	(_Write_UFM_data_mybytes_1_53 + 3),r5
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:107: UFM_ADD0=mybytes.byte[0];
	mov	_UFM_ADD0,_Write_UFM_data_mybytes_1_53
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:108: UFM_ADD1=mybytes.byte[1];
	mov	_UFM_ADD1,(_Write_UFM_data_mybytes_1_53 + 0x0001)
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:109: UFM_ADD2=mybytes.byte[2];
	mov	_UFM_ADD2,(_Write_UFM_data_mybytes_1_53 + 0x0002)
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:111: mybytes.l=value;
	mov	_Write_UFM_data_mybytes_1_53,_Write_UFM_data_PARM_2
	mov	(_Write_UFM_data_mybytes_1_53 + 1),(_Write_UFM_data_PARM_2 + 1)
	mov	(_Write_UFM_data_mybytes_1_53 + 2),(_Write_UFM_data_PARM_2 + 2)
	mov	(_Write_UFM_data_mybytes_1_53 + 3),(_Write_UFM_data_PARM_2 + 3)
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:112: UFM_DATA3=mybytes.byte[3];
	mov	_UFM_DATA3,(_Write_UFM_data_mybytes_1_53 + 0x0003)
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:113: UFM_DATA2=mybytes.byte[2];
	mov	_UFM_DATA2,(_Write_UFM_data_mybytes_1_53 + 0x0002)
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:114: UFM_DATA1=mybytes.byte[1];
	mov	_UFM_DATA1,(_Write_UFM_data_mybytes_1_53 + 0x0001)
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:115: UFM_DATA0=mybytes.byte[0];
	mov	_UFM_DATA0,_Write_UFM_data_mybytes_1_53
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:117: UFM_DATA_CMD=0b_00_0001;  // read=0, write=0, burstcount=0001b
	mov	_UFM_DATA_CMD,#0x01
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:118: UFM_DATA_CMD|=0b_10_0001; // read=1, write=0, burstcount=0001b
	orl	_UFM_DATA_CMD,#0x21
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:119: while((UFM_DATA_STATUS&0x01)==0x01);// Wait for write to finish
L007001?:
	mov	a,#0x01
	anl	a,_UFM_DATA_STATUS
	mov	r2,a
	cjne	r2,#0x01,L007008?
	sjmp	L007001?
L007008?:
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:120: UFM_DATA_CMD=0b_00_0001;  // read=0, write=0, burstcount=0000b
	mov	_UFM_DATA_CMD,#0x01
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'Read_UFM_data_bytes'
;------------------------------------------------------------
;mybytes                   Allocated with name '_Read_UFM_data_bytes_PARM_2'
;addr                      Allocated to registers r2 r3 r4 r5 
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:123: void Read_UFM_data_bytes (unsigned long addr, unsigned char * mybytes)
;	-----------------------------------------
;	 function Read_UFM_data_bytes
;	-----------------------------------------
_Read_UFM_data_bytes:
	mov	r2,dpl
	mov	r3,dph
	mov	r4,b
	mov	r5,a
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:131: UFM_ADD0=addr%0x100;
	mov	ar6,r2
	mov	r7,#0x00
	mov	r0,#0x00
	mov	r1,#0x00
	mov	_UFM_ADD0,r6
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:132: UFM_ADD1=addr/0x100;
	mov	ar2,r3
	mov	ar3,r4
	mov	ar4,r5
	mov	r5,#0x00
	mov	_UFM_ADD1,r2
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:133: UFM_ADD2=0;
	mov	_UFM_ADD2,#0x00
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:135: UFM_DATA_CMD=0b_01_0001; // write=0, read=1, burstcount=0001b
	mov	_UFM_DATA_CMD,#0x11
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:136: UFM_DATA_CMD=0b_00_0001; // read=0, write=0
	mov	_UFM_DATA_CMD,#0x01
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:137: while((UFM_DATA_STATUS&0x02)!=0x02);// Wait for readdatavalid
L008001?:
	mov	a,#0x02
	anl	a,_UFM_DATA_STATUS
	mov	r2,a
	cjne	r2,#0x02,L008001?
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:139: mybytes[3]=UFM_DATA3;
	mov	a,#0x03
	add	a,_Read_UFM_data_bytes_PARM_2
	mov	r2,a
	clr	a
	addc	a,(_Read_UFM_data_bytes_PARM_2 + 1)
	mov	r3,a
	mov	r4,(_Read_UFM_data_bytes_PARM_2 + 2)
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	a,_UFM_DATA3
	lcall	__gptrput
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:140: mybytes[2]=UFM_DATA2;
	mov	a,#0x02
	add	a,_Read_UFM_data_bytes_PARM_2
	mov	r2,a
	clr	a
	addc	a,(_Read_UFM_data_bytes_PARM_2 + 1)
	mov	r3,a
	mov	r4,(_Read_UFM_data_bytes_PARM_2 + 2)
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	a,_UFM_DATA2
	lcall	__gptrput
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:141: mybytes[1]=UFM_DATA1;
	mov	a,#0x01
	add	a,_Read_UFM_data_bytes_PARM_2
	mov	r2,a
	clr	a
	addc	a,(_Read_UFM_data_bytes_PARM_2 + 1)
	mov	r3,a
	mov	r4,(_Read_UFM_data_bytes_PARM_2 + 2)
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	a,_UFM_DATA1
	lcall	__gptrput
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:142: mybytes[0]=UFM_DATA0;
	mov	r2,_Read_UFM_data_bytes_PARM_2
	mov	r3,(_Read_UFM_data_bytes_PARM_2 + 1)
	mov	r4,(_Read_UFM_data_bytes_PARM_2 + 2)
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	a,_UFM_DATA0
	ljmp	__gptrput
;------------------------------------------------------------
;Allocation info for local variables in function 'Write_UFM_data_bytes'
;------------------------------------------------------------
;mybytes                   Allocated with name '_Write_UFM_data_bytes_PARM_2'
;addr                      Allocated to registers r2 r3 
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:145: void Write_UFM_data_bytes (unsigned int addr, unsigned char * mybytes)
;	-----------------------------------------
;	 function Write_UFM_data_bytes
;	-----------------------------------------
_Write_UFM_data_bytes:
	mov	r2,dpl
	mov	r3,dph
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:153: UFM_ADD0=addr%0x100;
	mov	ar4,r2
	mov	r5,#0x00
	mov	_UFM_ADD0,r4
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:154: UFM_ADD1=addr/0x100;
	mov	ar2,r3
	mov	_UFM_ADD1,r2
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:155: UFM_ADD2=0;
	mov	_UFM_ADD2,#0x00
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:157: UFM_DATA3=mybytes[3];
	mov	a,#0x03
	add	a,_Write_UFM_data_bytes_PARM_2
	mov	r2,a
	clr	a
	addc	a,(_Write_UFM_data_bytes_PARM_2 + 1)
	mov	r3,a
	mov	r4,(_Write_UFM_data_bytes_PARM_2 + 2)
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	_UFM_DATA3,a
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:158: UFM_DATA2=mybytes[2];
	mov	a,#0x02
	add	a,_Write_UFM_data_bytes_PARM_2
	mov	r2,a
	clr	a
	addc	a,(_Write_UFM_data_bytes_PARM_2 + 1)
	mov	r3,a
	mov	r4,(_Write_UFM_data_bytes_PARM_2 + 2)
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	_UFM_DATA2,a
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:159: UFM_DATA1=mybytes[1];
	mov	a,#0x01
	add	a,_Write_UFM_data_bytes_PARM_2
	mov	r2,a
	clr	a
	addc	a,(_Write_UFM_data_bytes_PARM_2 + 1)
	mov	r3,a
	mov	r4,(_Write_UFM_data_bytes_PARM_2 + 2)
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	_UFM_DATA1,a
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:160: UFM_DATA0=mybytes[0];
	mov	r2,_Write_UFM_data_bytes_PARM_2
	mov	r3,(_Write_UFM_data_bytes_PARM_2 + 1)
	mov	r4,(_Write_UFM_data_bytes_PARM_2 + 2)
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	_UFM_DATA0,a
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:162: UFM_DATA_CMD=0b_00_0001;  // read=0, write=0, burstcount=0001b
	mov	_UFM_DATA_CMD,#0x01
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:163: UFM_DATA_CMD|=0b_10_0001; // read=1, write=0, burstcount=0001b
	orl	_UFM_DATA_CMD,#0x21
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:164: while((UFM_DATA_STATUS&0x01)==0x01);// Wait for write to finish
L009001?:
	mov	a,#0x01
	anl	a,_UFM_DATA_STATUS
	mov	r2,a
	cjne	r2,#0x01,L009008?
	sjmp	L009001?
L009008?:
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:165: UFM_DATA_CMD=0b_00_0001;  // read=0, write=0, burstcount=0000b
	mov	_UFM_DATA_CMD,#0x01
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'main'
;------------------------------------------------------------
;mybytes                   Allocated with name '_main_mybytes_1_59'
;j                         Allocated to registers r2 r3 
;sloc0                     Allocated with name '_main_sloc0_1_0'
;------------------------------------------------------------
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:168: void main (void)
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:174: LEDRA=0x00;
	mov	_LEDRA,#0x00
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:175: LEDRB=0x00;
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:178: UFM_DATA_CMD=0x00;
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:179: UFM_CONTROL_CMD=0x00;
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:181: printf("User Flash Memory test.\r\n");
	clr	a
	mov	_LEDRB,a
	mov	_UFM_DATA_CMD,a
	mov	_UFM_CONTROL_CMD,a
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
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:182: printf("flash_status_reg=0x%08lx\r\n", Read_UFM_control(0));
	mov	dpl,#0x00
	lcall	_Read_UFM_control
	mov	r2,dpl
	mov	r3,dph
	mov	r4,b
	mov	r5,a
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	mov	a,#__str_1
	push	acc
	mov	a,#(__str_1 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xf9
	mov	sp,a
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:183: printf("flash_control_reg=0x%08lx\r\n", Read_UFM_control(1));
	mov	dpl,#0x01
	lcall	_Read_UFM_control
	mov	r2,dpl
	mov	r3,dph
	mov	r4,b
	mov	r5,a
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	mov	a,#__str_2
	push	acc
	mov	a,#(__str_2 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xf9
	mov	sp,a
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:184: printf("flash_data(0)=0x%08lx\r\n", Read_UFM_data(0x0000L));
	mov	dptr,#(0x00&0x00ff)
	clr	a
	mov	b,a
	lcall	_Read_UFM_data
	mov	r2,dpl
	mov	r3,dph
	mov	r4,b
	mov	r5,a
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	mov	a,#__str_3
	push	acc
	mov	a,#(__str_3 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xf9
	mov	sp,a
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:185: printf("flash_data(1)=0x%08lx\r\n", Read_UFM_data(0x0001L));
	mov	dptr,#(0x01&0x00ff)
	clr	a
	mov	b,a
	lcall	_Read_UFM_data
	mov	r2,dpl
	mov	r3,dph
	mov	r4,b
	mov	r5,a
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	mov	a,#__str_4
	push	acc
	mov	a,#(__str_4 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xf9
	mov	sp,a
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:186: printf("flash_data(2)=0x%08lx\r\n", Read_UFM_data(0x0002L));
	mov	dptr,#(0x02&0x00ff)
	clr	a
	mov	b,a
	lcall	_Read_UFM_data
	mov	r2,dpl
	mov	r3,dph
	mov	r4,b
	mov	r5,a
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	mov	a,#__str_5
	push	acc
	mov	a,#(__str_5 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xf9
	mov	sp,a
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:187: printf("flash_status_reg=0x%08lx\r\n", Read_UFM_control(0));
	mov	dpl,#0x00
	lcall	_Read_UFM_control
	mov	r2,dpl
	mov	r3,dph
	mov	r4,b
	mov	r5,a
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	mov	a,#__str_1
	push	acc
	mov	a,#(__str_1 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xf9
	mov	sp,a
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:212: printf("\r\nErasing UFM1\r\n");
	mov	a,#__str_6
	push	acc
	mov	a,#(__str_6 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	dec	sp
	dec	sp
	dec	sp
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:214: Write_UFM_control(1, 0x0f1fffffL); // (23 downto 20) <= '0001'
	mov	_Write_UFM_control_PARM_2,#0xFF
	mov	(_Write_UFM_control_PARM_2 + 1),#0xFF
	mov	(_Write_UFM_control_PARM_2 + 2),#0x1F
	mov	(_Write_UFM_control_PARM_2 + 3),#0x0F
	mov	dpl,#0x01
	lcall	_Write_UFM_control
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:216: while ((Read_UFM_control(0)&0x00000003L)!=0);
L010001?:
	mov	dpl,#0x00
	lcall	_Read_UFM_control
	mov	r2,dpl
	mov	r3,dph
	mov	r4,b
	mov	r5,a
	mov	a,r2
	anl	a,#0x03
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:217: printf("flash_status_reg=0x%08lx\r\n", Read_UFM_control(0));
	jnz	L010001?
	mov	dpl,a
	lcall	_Read_UFM_control
	mov	r2,dpl
	mov	r3,dph
	mov	r4,b
	mov	r5,a
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	mov	a,#__str_1
	push	acc
	mov	a,#(__str_1 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xf9
	mov	sp,a
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:218: Read_UFM_data_bytes(0, mybytes);
	mov	_Read_UFM_data_bytes_PARM_2,#_main_mybytes_1_59
	mov	(_Read_UFM_data_bytes_PARM_2 + 1),#0x00
	mov	(_Read_UFM_data_bytes_PARM_2 + 2),#0x40
	mov	dptr,#(0x00&0x00ff)
	clr	a
	mov	b,a
	lcall	_Read_UFM_data_bytes
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:219: printf("flash_data(0)=0x%02x%02x%02x%02x\r\n", mybytes[3], mybytes[2], mybytes[1], mybytes[0]);
	mov	r2,_main_mybytes_1_59
	mov	r3,#0x00
	mov	r4,(_main_mybytes_1_59 + 0x0001)
	mov	r5,#0x00
	mov	_main_sloc0_1_0,(_main_mybytes_1_59 + 0x0002)
	mov	(_main_sloc0_1_0 + 1),#0x00
	mov	r6,(_main_mybytes_1_59 + 0x0003)
	mov	r7,#0x00
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	push	_main_sloc0_1_0
	push	(_main_sloc0_1_0 + 1)
	push	ar6
	push	ar7
	mov	a,#__str_7
	push	acc
	mov	a,#(__str_7 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xf5
	mov	sp,a
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:220: Read_UFM_data_bytes(1, mybytes);
	mov	_Read_UFM_data_bytes_PARM_2,#_main_mybytes_1_59
	mov	(_Read_UFM_data_bytes_PARM_2 + 1),#0x00
	mov	(_Read_UFM_data_bytes_PARM_2 + 2),#0x40
	mov	dptr,#(0x01&0x00ff)
	clr	a
	mov	b,a
	lcall	_Read_UFM_data_bytes
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:221: printf("flash_data(1)=0x%02x%02x%02x%02x\r\n", mybytes[3], mybytes[2], mybytes[1], mybytes[0]);
	mov	r2,_main_mybytes_1_59
	mov	r3,#0x00
	mov	r4,(_main_mybytes_1_59 + 0x0001)
	mov	r5,#0x00
	mov	_main_sloc0_1_0,(_main_mybytes_1_59 + 0x0002)
	mov	(_main_sloc0_1_0 + 1),#0x00
	mov	r6,(_main_mybytes_1_59 + 0x0003)
	mov	r7,#0x00
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	push	_main_sloc0_1_0
	push	(_main_sloc0_1_0 + 1)
	push	ar6
	push	ar7
	mov	a,#__str_8
	push	acc
	mov	a,#(__str_8 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xf5
	mov	sp,a
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:222: Read_UFM_data_bytes(2, mybytes);
	mov	_Read_UFM_data_bytes_PARM_2,#_main_mybytes_1_59
	mov	(_Read_UFM_data_bytes_PARM_2 + 1),#0x00
	mov	(_Read_UFM_data_bytes_PARM_2 + 2),#0x40
	mov	dptr,#(0x02&0x00ff)
	clr	a
	mov	b,a
	lcall	_Read_UFM_data_bytes
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:223: printf("flash_data(2)=0x%02x%02x%02x%02x\r\n", mybytes[3], mybytes[2], mybytes[1], mybytes[0]);
	mov	r2,_main_mybytes_1_59
	mov	r3,#0x00
	mov	r4,(_main_mybytes_1_59 + 0x0001)
	mov	r5,#0x00
	mov	_main_sloc0_1_0,(_main_mybytes_1_59 + 0x0002)
	mov	(_main_sloc0_1_0 + 1),#0x00
	mov	r6,(_main_mybytes_1_59 + 0x0003)
	mov	r7,#0x00
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	push	_main_sloc0_1_0
	push	(_main_sloc0_1_0 + 1)
	push	ar6
	push	ar7
	mov	a,#__str_9
	push	acc
	mov	a,#(__str_9 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xf5
	mov	sp,a
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:225: printf("\r\nWriting to UFM1\r\n");
	mov	a,#__str_10
	push	acc
	mov	a,#(__str_10 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	dec	sp
	dec	sp
	dec	sp
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:226: mybytes[3]=0x12; mybytes[2]=0x34; mybytes[1]=0x56; mybytes[0]=0x78;
	mov	(_main_mybytes_1_59 + 0x0003),#0x12
	mov	(_main_mybytes_1_59 + 0x0002),#0x34
	mov	(_main_mybytes_1_59 + 0x0001),#0x56
	mov	_main_mybytes_1_59,#0x78
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:227: Write_UFM_data_bytes(0, mybytes);	
	mov	_Write_UFM_data_bytes_PARM_2,#_main_mybytes_1_59
	mov	(_Write_UFM_data_bytes_PARM_2 + 1),#0x00
	mov	(_Write_UFM_data_bytes_PARM_2 + 2),#0x40
	mov	dptr,#0x0000
	lcall	_Write_UFM_data_bytes
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:228: mybytes[3]=0x55; mybytes[2]=0x55; mybytes[1]=0x55; mybytes[0]=0x55;
	mov	(_main_mybytes_1_59 + 0x0003),#0x55
	mov	(_main_mybytes_1_59 + 0x0002),#0x55
	mov	(_main_mybytes_1_59 + 0x0001),#0x55
	mov	_main_mybytes_1_59,#0x55
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:229: Write_UFM_data_bytes(1, mybytes);	
	mov	_Write_UFM_data_bytes_PARM_2,#_main_mybytes_1_59
	mov	(_Write_UFM_data_bytes_PARM_2 + 1),#0x00
	mov	(_Write_UFM_data_bytes_PARM_2 + 2),#0x40
	mov	dptr,#0x0001
	lcall	_Write_UFM_data_bytes
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:230: mybytes[3]=0xaa; mybytes[2]=0xaa; mybytes[1]=0xaa; mybytes[0]=0xaa;
	mov	(_main_mybytes_1_59 + 0x0003),#0xAA
	mov	(_main_mybytes_1_59 + 0x0002),#0xAA
	mov	(_main_mybytes_1_59 + 0x0001),#0xAA
	mov	_main_mybytes_1_59,#0xAA
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:231: Write_UFM_data_bytes(2, mybytes);
	mov	_Write_UFM_data_bytes_PARM_2,#_main_mybytes_1_59
	mov	(_Write_UFM_data_bytes_PARM_2 + 1),#0x00
	mov	(_Write_UFM_data_bytes_PARM_2 + 2),#0x40
	mov	dptr,#0x0002
	lcall	_Write_UFM_data_bytes
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:233: for(j=0; j<292; j++); // Need some delay after writing to read.  275 fails.  300 works.
	mov	r2,#0x24
	mov	r3,#0x01
L010006?:
	dec	r2
	cjne	r2,#0xff,L010016?
	dec	r3
L010016?:
	mov	a,r2
	orl	a,r3
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:235: Read_UFM_data_bytes(0, mybytes);
	jnz	L010006?
	mov	_Read_UFM_data_bytes_PARM_2,#_main_mybytes_1_59
	mov	(_Read_UFM_data_bytes_PARM_2 + 1),a
	mov	(_Read_UFM_data_bytes_PARM_2 + 2),#0x40
	mov	dptr,#(0x00&0x00ff)
	clr	a
	mov	b,a
	lcall	_Read_UFM_data_bytes
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:236: printf("flash_data(0)=0x%02x%02x%02x%02x\r\n", mybytes[3], mybytes[2], mybytes[1], mybytes[0]);
	mov	r2,_main_mybytes_1_59
	mov	r3,#0x00
	mov	r4,(_main_mybytes_1_59 + 0x0001)
	mov	r5,#0x00
	mov	_main_sloc0_1_0,(_main_mybytes_1_59 + 0x0002)
	mov	(_main_sloc0_1_0 + 1),#0x00
	mov	r6,(_main_mybytes_1_59 + 0x0003)
	mov	r7,#0x00
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	push	_main_sloc0_1_0
	push	(_main_sloc0_1_0 + 1)
	push	ar6
	push	ar7
	mov	a,#__str_7
	push	acc
	mov	a,#(__str_7 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xf5
	mov	sp,a
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:237: Read_UFM_data_bytes(1, mybytes);
	mov	_Read_UFM_data_bytes_PARM_2,#_main_mybytes_1_59
	mov	(_Read_UFM_data_bytes_PARM_2 + 1),#0x00
	mov	(_Read_UFM_data_bytes_PARM_2 + 2),#0x40
	mov	dptr,#(0x01&0x00ff)
	clr	a
	mov	b,a
	lcall	_Read_UFM_data_bytes
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:238: printf("flash_data(1)=0x%02x%02x%02x%02x\r\n", mybytes[3], mybytes[2], mybytes[1], mybytes[0]);
	mov	r2,_main_mybytes_1_59
	mov	r3,#0x00
	mov	r4,(_main_mybytes_1_59 + 0x0001)
	mov	r5,#0x00
	mov	_main_sloc0_1_0,(_main_mybytes_1_59 + 0x0002)
	mov	(_main_sloc0_1_0 + 1),#0x00
	mov	r6,(_main_mybytes_1_59 + 0x0003)
	mov	r7,#0x00
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	push	_main_sloc0_1_0
	push	(_main_sloc0_1_0 + 1)
	push	ar6
	push	ar7
	mov	a,#__str_8
	push	acc
	mov	a,#(__str_8 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xf5
	mov	sp,a
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:239: Read_UFM_data_bytes(2, mybytes);
	mov	_Read_UFM_data_bytes_PARM_2,#_main_mybytes_1_59
	mov	(_Read_UFM_data_bytes_PARM_2 + 1),#0x00
	mov	(_Read_UFM_data_bytes_PARM_2 + 2),#0x40
	mov	dptr,#(0x02&0x00ff)
	clr	a
	mov	b,a
	lcall	_Read_UFM_data_bytes
;	C:\Source\MAX10_8052\Test\Code\NewRegsTest.c:240: printf("flash_data(2)=0x%02x%02x%02x%02x\r\n", mybytes[3], mybytes[2], mybytes[1], mybytes[0]);
	mov	r2,_main_mybytes_1_59
	mov	r3,#0x00
	mov	r4,(_main_mybytes_1_59 + 0x0001)
	mov	r5,#0x00
	mov	_main_sloc0_1_0,(_main_mybytes_1_59 + 0x0002)
	mov	(_main_sloc0_1_0 + 1),#0x00
	mov	r6,(_main_mybytes_1_59 + 0x0003)
	mov	r7,#0x00
	push	ar2
	push	ar3
	push	ar4
	push	ar5
	push	_main_sloc0_1_0
	push	(_main_sloc0_1_0 + 1)
	push	ar6
	push	ar7
	mov	a,#__str_9
	push	acc
	mov	a,#(__str_9 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_printf
	mov	a,sp
	add	a,#0xf5
	mov	sp,a
	ret
	rseg R_CSEG

	rseg R_XINIT

	rseg R_CONST
__str_0:
	db 'User Flash Memory test.'
	db 0x0D
	db 0x0A
	db 0x00
__str_1:
	db 'flash_status_reg=0x%08lx'
	db 0x0D
	db 0x0A
	db 0x00
__str_2:
	db 'flash_control_reg=0x%08lx'
	db 0x0D
	db 0x0A
	db 0x00
__str_3:
	db 'flash_data(0)=0x%08lx'
	db 0x0D
	db 0x0A
	db 0x00
__str_4:
	db 'flash_data(1)=0x%08lx'
	db 0x0D
	db 0x0A
	db 0x00
__str_5:
	db 'flash_data(2)=0x%08lx'
	db 0x0D
	db 0x0A
	db 0x00
__str_6:
	db 0x0D
	db 0x0A
	db 'Erasing UFM1'
	db 0x0D
	db 0x0A
	db 0x00
__str_7:
	db 'flash_data(0)=0x%02x%02x%02x%02x'
	db 0x0D
	db 0x0A
	db 0x00
__str_8:
	db 'flash_data(1)=0x%02x%02x%02x%02x'
	db 0x0D
	db 0x0A
	db 0x00
__str_9:
	db 'flash_data(2)=0x%02x%02x%02x%02x'
	db 0x0D
	db 0x0A
	db 0x00
__str_10:
	db 0x0D
	db 0x0A
	db 'Writing to UFM1'
	db 0x0D
	db 0x0A
	db 0x00

	CSEG

end
