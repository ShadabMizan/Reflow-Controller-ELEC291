--
-- 8052 compatible microcontroller, with internal RAM & ROM
--
-- Version : 0300
--
-- Copyright (c) 2001-2002 Daniel Wallner (jesus@opencores.org)
--           (c) 2004-2005 Andreas Voggeneder (andreas.voggeneder@fh-hagenberg.at)
--
-- All rights reserved
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- Please report bugs to the author, but before you do so, please
-- make sure that this is not a derivative work and that
-- you have the latest version of this file.
--
-- The latest version of this file can be found at:
--	http://www.opencores.org/cvsweb.shtml/t51/
--
-- Limitations :
--
-- File history :
--

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.T51_Pack.all;

entity CV_8052 is
	generic(
	  tristate          : integer := 0;
		ROMAddressWidth		: integer := 14;
		IRAMAddressWidth	: integer := 8;
		XRAMAddressWidth	: integer := 16);
	port(
		CLOCK_50	: in std_logic;
		RstIn		: in std_logic;
		LEDR0_in	: in  std_logic_vector(7 downto 0);
		LEDR1_in	: in  std_logic_vector(1 downto 0);
		KEY	: in  std_logic_vector(3 downto 0);
		GNDKEY2 : out std_logic; -- The ground for KEY[2] push button in the arduino uno connector
		GNDKEY3 : out std_logic; -- The ground for KEY[3] push button in the arduino uno connector
		P0		    : inout std_logic_vector(7 downto 0);
		P1		    : inout std_logic_vector(7 downto 0);
		P2		    : inout std_logic_vector(7 downto 0);
		P3		    : inout std_logic_vector(7 downto 0);
		P4		    : inout std_logic_vector(7 downto 0);
		
		HEX0_out	: out std_logic_vector(7 downto 0);
		HEX1_out	: out std_logic_vector(7 downto 0);
		HEX2_out	: out std_logic_vector(7 downto 0);
		HEX3_out	: out std_logic_vector(7 downto 0);
		HEX4_out	: out std_logic_vector(7 downto 0);
		HEX5_out	: out std_logic_vector(7 downto 0);
		LEDR0_out	: out std_logic_vector(7 downto 0);
		LEDR1_out	: out std_logic_vector(1 downto 0);
		INT0		: in std_logic;
		INT1		: in std_logic;
		T0			: in std_logic;
		T1			: in std_logic;
		T2			: in std_logic;
		T2EX		: in std_logic;
		RXD			: in std_logic;
		TXD			: out std_logic;
		GSENSOR_SCLK : out std_logic;
		GSENSOR_SDI  : out  std_logic;
		GSENSOR_SDO  : in std_logic;
		GSENSOR_CS_n : out std_logic;
		GSENSOR_INT1 : in  std_logic;
		GSENSOR_INT2 : in  std_logic
	);
end CV_8052;

architecture rtl of CV_8052 is

	component ROM52
	generic(
		AddrWidth	: integer := 14;
		DataWidth	: integer := 8
	);
		port(
			Clk	: in std_logic;
			A	: in std_logic_vector(AddrWidth - 1 downto 0);
			D	: out std_logic_vector(DataWidth-1 downto 0)
		);
	end component;

	component SSRAM
	generic(
		AddrWidth	: integer := 16;
		DataWidth	: integer := 8
	);
	port(
		Clk			: in std_logic;
		CE_n		: in std_logic;
		WE_n		: in std_logic;
		A			: in std_logic_vector(AddrWidth - 1 downto 0);
		DIn			: in std_logic_vector(DataWidth - 1 downto 0);
		DOut		: out std_logic_vector(DataWidth - 1 downto 0)
	);
	end component;

	component SSRAM2
	generic(
		AddrWidth	: integer := 15;
		DataWidth	: integer := 8;
		Inst_Name	: STRING := "ENABLE_RUNTIME_MOD=NO,INSTANCE_NAME=NONE"
	);
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (AddrWidth - 1 DOWNTO 0);
		clock			: IN STD_LOGIC  := '1';
		data			: IN STD_LOGIC_VECTOR (DataWidth - 1 DOWNTO 0);
		wren			: IN STD_LOGIC ;
		q				: OUT STD_LOGIC_VECTOR (DataWidth - 1 DOWNTO 0)
	);
	end component;
		
	component CV_PLL is
		port (
			inclk0   : in  std_logic := 'X'; -- clk
			areset      : in  std_logic := 'X'; -- reset
			c0 : out std_logic         -- output
		);
	end component CV_PLL;	
	
	component onchip_flash is
	port (
		clock                   : in  std_logic;
		avmm_csr_addr           : in  std_logic;
		avmm_csr_read           : in  std_logic;
		avmm_csr_writedata      : in  std_logic_vector(31 downto 0);
		avmm_csr_write          : in  std_logic;
		avmm_csr_readdata       : out std_logic_vector(31 downto 0);
		avmm_data_addr          : in  std_logic_vector(18 downto 0);
		avmm_data_read          : in  std_logic;
		avmm_data_writedata     : in  std_logic_vector(31 downto 0);
		avmm_data_write         : in  std_logic;
		avmm_data_readdata      : out std_logic_vector(31 downto 0);
		avmm_data_waitrequest   : out std_logic;
		avmm_data_readdatavalid : out std_logic;
		avmm_data_burstcount    : in  std_logic_vector(3 downto 0);
		reset_n                 : in  std_logic
	);
	end component;
	
	component ADC is
	port (
		CLOCK : in  std_logic; --      clk.clk
		CH0   : out std_logic_vector(11 downto 0);        -- readings.CH0
		CH1   : out std_logic_vector(11 downto 0);        --         .CH1
		CH2   : out std_logic_vector(11 downto 0);        --         .CH2
		CH3   : out std_logic_vector(11 downto 0);        --         .CH3
		CH4   : out std_logic_vector(11 downto 0);        --         .CH4
		CH5   : out std_logic_vector(11 downto 0);        --         .CH5
		CH6   : out std_logic_vector(11 downto 0);        --         .CH6
		CH7   : out std_logic_vector(11 downto 0);        --         .CH7
		RESET : in  std_logic   --    reset.reset
	);
   end component;
	
	constant ram1_bits : integer := 15; -- 32k
	constant ram2_bits : integer := 15; -- 32k  (used to be 13 bits for and 8k)
	constant ram3_bits : integer := 14; -- 16k

	constant ext_mux_in_num : integer := 37; --63;
	type ext_mux_din_type is array(0 to ext_mux_in_num-1) of std_logic_vector(7 downto 0);
	subtype ext_mux_en_type  is std_logic_vector(0 to ext_mux_in_num-1);

	signal  Clk			           : std_logic;
	signal  Rst_n	               : std_logic;
	signal	Ready		           : std_logic;
	signal	ROM_Addr	           : std_logic_vector(15 downto 0);
	signal	ROM_Data	           : std_logic_vector(7 downto 0);
	signal	ROM_Data_Boot          : std_logic_vector(7 downto 0);
	signal	ROM_Data_User          : std_logic_vector(7 downto 0);
	signal	RAM_Addr,RAM_Addr_r    : std_logic_vector(15 downto 0);
	signal	XRAM_Addr              : std_logic_vector(15 downto 0);
	signal	RAM_RData	           : std_logic_vector(7 downto 0);
	signal	RAM_DO		           : std_logic_vector(7 downto 0);
	signal	RAM_WData	           : std_logic_vector(7 downto 0);
	signal	RAM_Rd		           : std_logic;
	signal	RAM_Wr		           : std_logic;
	signal	RAM_RD_n	           : std_logic;
	signal	RAM_WE_n	           : std_logic;
	signal	zeros                  : std_logic_vector(21 downto 0);
	signal  ext_ram_en             : std_logic;
	signal	IO_Rd		           : std_logic;
	signal	IO_Wr		           : std_logic;
	signal	IO_Addr		           : std_logic_vector(6 downto 0);
	signal	IO_Addr_r	           : std_logic_vector(6 downto 0);
	signal	IO_WData	           : std_logic_vector(7 downto 0);
	signal	IO_RData	           : std_logic_vector(7 downto 0);
	signal  IO_RData_arr           : ext_mux_din_type;
	signal  IO_RData_en            : ext_mux_en_type;

	signal	P0_Sel		: std_logic;
	signal	P1_Sel		: std_logic;
	signal	P2_Sel		: std_logic;
	signal	P3_Sel		: std_logic;
	signal	P4_Sel		: std_logic;
	signal	HEX0_Sel	: std_logic;
	signal	HEX1_Sel	: std_logic;
	signal	HEX2_Sel	: std_logic;
	signal	HEX3_Sel	: std_logic;
	signal	HEX4_Sel	: std_logic;
	signal	HEX5_Sel	: std_logic;
	signal	LEDR0_Sel	: std_logic;
	signal	LEDR1_Sel	: std_logic;
	signal	KEY_Sel	: std_logic;
	signal	TMOD_Sel	: std_logic;
	signal	TL0_Sel		: std_logic;
	signal	TL1_Sel		: std_logic;
	signal	TH0_Sel		: std_logic;
	signal	TH1_Sel		: std_logic;
	signal	T2CON_Sel	: std_logic;
	signal	RCAP2L_Sel	: std_logic;
	signal	RCAP2H_Sel	: std_logic;
	signal	TL2_Sel		: std_logic;
	signal	TH2_Sel		: std_logic;
	signal	SCON_Sel	: std_logic;
	signal	SBUF_Sel	: std_logic;
	signal  P0MOD_Sel   : std_logic;
	signal  P1MOD_Sel   : std_logic;
	signal  P2MOD_Sel   : std_logic;
	signal  P3MOD_Sel   : std_logic;
	signal  P4MOD_Sel   : std_logic;
   signal  BPC_Sel 	: std_logic;
	signal  BPS_Sel 	: std_logic;
	signal  BPAL_Sel 	: std_logic;
	signal  BPAH_Sel 	: std_logic;
	signal  LCall_Addr_L_Sel : std_logic;
	signal  LCall_Addr_H_Sel : std_logic;
	signal  Rep_Addr_L_Sel   : std_logic;
	signal  Rep_Addr_H_Sel   : std_logic;
	signal  Rep_Value_Sel    : std_logic;
	signal  SharedRamReg_Sel : std_logic;
	signal  UFM_ADD0_Sel    : std_logic;
	signal  UFM_ADD1_Sel    : std_logic;
	signal  UFM_ADD2_Sel    : std_logic;
	signal  UFM_DATA0_Sel    : std_logic;
	signal  UFM_DATA1_Sel    : std_logic;
	signal  UFM_DATA2_Sel    : std_logic;
	signal  UFM_DATA3_Sel    : std_logic;
	signal  UFM_CONTROL0_Sel : std_logic;
	signal  UFM_CONTROL1_Sel : std_logic;
	signal  UFM_CONTROL2_Sel : std_logic;
	signal  UFM_CONTROL3_Sel : std_logic;
	signal  UFM_DATA_CMD_Sel    : std_logic;
	signal  UFM_DATA_STATUS_Sel : std_logic;
	signal  UFM_CONTROL_CMD_Sel : std_logic;

	signal ADC_C_Sel : std_logic;
	signal ADC_L_Sel : std_logic;
	signal ADC_H_Sel : std_logic;

	signal	P0_Wr		: std_logic;
	signal	P1_Wr		: std_logic;
	signal	P2_Wr		: std_logic;
	signal	P3_Wr		: std_logic;
	signal	P4_Wr		: std_logic;
	signal	HEX0_Wr		: std_logic;
	signal	HEX1_Wr		: std_logic;
	signal	HEX2_Wr		: std_logic;
	signal	HEX3_Wr		: std_logic;
	signal	HEX4_Wr		: std_logic;
	signal	HEX5_Wr		: std_logic;
	signal	LEDR0_Wr	: std_logic;
	signal	LEDR1_Wr	: std_logic;
	signal	KEY_Wr		: std_logic;
	signal	TMOD_Wr		: std_logic;
	signal	TL0_Wr		: std_logic;
	signal	TL1_Wr		: std_logic;
	signal	TH0_Wr		: std_logic;
	signal	TH1_Wr		: std_logic;
	signal	T2CON_Wr	: std_logic;
	signal	RCAP2L_Wr	: std_logic;
	signal	RCAP2H_Wr	: std_logic;
	signal	TL2_Wr		: std_logic;
	signal	TH2_Wr		: std_logic;
	signal	SCON_Wr		: std_logic;
	signal	SBUF_Wr		: std_logic;
	signal  P0MOD_Wr    : std_logic;
	signal  P1MOD_Wr    : std_logic;
	signal  P2MOD_Wr    : std_logic;
	signal  P3MOD_Wr    : std_logic;
	signal  P4MOD_Wr    : std_logic;
	signal  SharedRamReg_Wr : std_logic;
   signal  BPC_Wr 		: std_logic;
	signal  BPS_Wr 		: std_logic;
	signal  BPAL_Wr 	: std_logic;
	signal  BPAH_Wr 	: std_logic;
	signal  LCall_Addr_L_Wr  : std_logic;
	signal  LCall_Addr_H_Wr  : std_logic;
	signal  Rep_Addr_L_Wr   : std_logic;
	signal  Rep_Addr_H_Wr   : std_logic;
	signal  Rep_Value_Wr    : std_logic;
	signal  UFM_ADD0_Wr : std_logic;
	signal  UFM_ADD1_Wr : std_logic;
	signal  UFM_ADD2_Wr : std_logic;
	signal  UFM_DATA0_Wr    : std_logic;
	signal  UFM_DATA1_Wr    : std_logic;
	signal  UFM_DATA2_Wr    : std_logic;
	signal  UFM_DATA3_Wr    : std_logic;
	signal  UFM_CONTROL0_Wr : std_logic;
	signal  UFM_CONTROL1_Wr : std_logic;
	signal  UFM_CONTROL2_Wr : std_logic;
	signal  UFM_CONTROL3_Wr : std_logic;
	signal  UFM_DATA_CMD_Wr    : std_logic;
	signal  UFM_DATA_STATUS_Wr : std_logic;
	signal  UFM_CONTROL_CMD_Wr : std_logic;

	signal ADC_C_Wr : std_logic;
	signal ADC_L_Wr : std_logic;
	signal ADC_H_Wr : std_logic;
	
	signal	UseR2		: std_logic;
	signal	UseT2		: std_logic;
	signal	UART_Clk	: std_logic;
	signal	R0			: std_logic;
	signal	R1			: std_logic;
	signal	SMOD		: std_logic;

	signal	Int_Trig	: std_logic_vector(6 downto 0);
	signal	Int_Acc		: std_logic_vector(6 downto 0);

	signal	RI			: std_logic;
	signal	TI			: std_logic;
	signal	OF0			: std_logic;
	signal	OF1			: std_logic;
	signal	OF2			: std_logic;
	signal  BPI         : std_logic; -- Break Point Interrupt
	signal  Break_point_signal : std_logic;
	
	--Registered input/output ports
	signal	HEX0_in		: std_logic_vector(7 downto 0);
	signal	HEX1_in		: std_logic_vector(7 downto 0);
	signal	HEX2_in		: std_logic_vector(7 downto 0);
	signal	HEX3_in		: std_logic_vector(7 downto 0);
	signal	HEX4_in		: std_logic_vector(7 downto 0);
	signal	HEX5_in		: std_logic_vector(7 downto 0);
	signal	HEX0_out_r	: std_logic_vector(7 downto 0);
	signal	HEX1_out_r	: std_logic_vector(7 downto 0);
	signal	HEX2_out_r	: std_logic_vector(7 downto 0);
	signal	HEX3_out_r	: std_logic_vector(7 downto 0);
	signal	HEX4_out_r	: std_logic_vector(7 downto 0);
	signal	HEX5_out_r	: std_logic_vector(7 downto 0);
	signal	LEDR1_out_r	: std_logic_vector(7 downto 0);
	signal	KEY_out_r	: std_logic_vector(7 downto 0);
	signal  LEDR1_in_r  : std_logic_vector(7 downto 0);
	signal  KEY_in_r   : std_logic_vector(7 downto 0);
	signal	UFM_ADD0_out_r		: std_logic_vector(7 downto 0);
	signal	UFM_ADD0_in_r		: std_logic_vector(7 downto 0);
	signal	UFM_ADD1_out_r		: std_logic_vector(7 downto 0);
	signal	UFM_ADD1_in_r		: std_logic_vector(7 downto 0);
	signal	UFM_ADD2_out_r		: std_logic_vector(7 downto 0);
	signal	UFM_ADD2_in_r		: std_logic_vector(7 downto 0);
	signal	UFM_DATA0_out_r	: std_logic_vector(7 downto 0);
	signal	UFM_DATA0_in_r		: std_logic_vector(7 downto 0);
	signal	UFM_DATA1_out_r	: std_logic_vector(7 downto 0);
	signal	UFM_DATA1_in_r		: std_logic_vector(7 downto 0);
	signal	UFM_DATA2_out_r	: std_logic_vector(7 downto 0);
	signal	UFM_DATA2_in_r		: std_logic_vector(7 downto 0);
	signal	UFM_DATA3_out_r	: std_logic_vector(7 downto 0);
	signal	UFM_DATA3_in_r		: std_logic_vector(7 downto 0);
	signal	UFM_CONTROL0_out_r: std_logic_vector(7 downto 0);
	signal	UFM_CONTROL0_in_r	: std_logic_vector(7 downto 0);
	signal	UFM_CONTROL1_out_r: std_logic_vector(7 downto 0);
	signal	UFM_CONTROL1_in_r	: std_logic_vector(7 downto 0);
	signal	UFM_CONTROL2_out_r: std_logic_vector(7 downto 0);
	signal	UFM_CONTROL2_in_r	: std_logic_vector(7 downto 0);
	signal	UFM_CONTROL3_out_r: std_logic_vector(7 downto 0);
	signal	UFM_CONTROL3_in_r	: std_logic_vector(7 downto 0);
	signal	UFM_DATA_CMD_out_r	: std_logic_vector(7 downto 0);
	signal	UFM_DATA_CMD_in_r		: std_logic_vector(7 downto 0);
	signal	UFM_DATA_STATUS_out_r	: std_logic_vector(7 downto 0);
	signal	UFM_DATA_STATUS_in_r		: std_logic_vector(7 downto 0);
	signal	UFM_CONTROL_CMD_out_r	: std_logic_vector(7 downto 0);
	signal	UFM_CONTROL_CMD_in_r		: std_logic_vector(7 downto 0);

	signal UFM_DATA           : std_logic_vector(31 downto 0);
	signal UFM_DATA_LATCHED   : std_logic_vector(31 downto 0);
	signal UFM_readdatavalid  : std_logic;
	
	Signal ADC_CH0_r : std_logic_vector(11 downto 0);
	Signal ADC_CH1_r : std_logic_vector(11 downto 0);
	Signal ADC_CH2_r : std_logic_vector(11 downto 0);
	Signal ADC_CH3_r : std_logic_vector(11 downto 0);
	Signal ADC_CH4_r : std_logic_vector(11 downto 0);
	Signal ADC_CH5_r : std_logic_vector(11 downto 0);
	Signal ADC_CH6_r : std_logic_vector(11 downto 0);
	Signal ADC_CH7_r : std_logic_vector(11 downto 0);

	signal	ADC_C_in		: std_logic_vector(7 downto 0);
	signal	ADC_C_out_r	: std_logic_vector(7 downto 0);
	signal	ADC_L_in		: std_logic_vector(7 downto 0);
	signal	ADC_L_out_r	: std_logic_vector(7 downto 0);
	signal	ADC_H_in		: std_logic_vector(7 downto 0);
	signal	ADC_H_out_r	: std_logic_vector(7 downto 0);
	
	signal  Boot_n      : std_logic;
	
	signal SharedRamReg : std_logic_vector(7 downto 0);
	signal LCall_Addr  	: std_logic_vector(15 downto 0);
	signal Rep_Addr  	: std_logic_vector(15 downto 0);
	signal Rep_Value  	: std_logic_vector(7 downto 0);
	
	--These two signals were originaly input pins, but I don't know what they do so...
	signal RXD_IsO	: std_logic;
	signal RXD_O	: std_logic;

	signal int_xram_sel_n1   : std_logic;
	signal SRAM_Addr1	     : std_logic_vector(ram1_bits-1 downto 0);
	signal SRAM_Q1 		     : std_logic_vector(7 downto 0);
	signal XRAM_WE_N1        : std_logic;

	signal int_xram_sel_n2   : std_logic;
	signal SRAM_Addr2	     : std_logic_vector(ram2_bits-1 downto 0);
	signal SRAM_Q2 		     : std_logic_vector(7 downto 0);
	signal XRAM_WE_N2        : std_logic;

	signal int_xram_sel_n3   : std_logic;
	signal SRAM_Addr3	     : std_logic_vector(ram3_bits-1 downto 0);
	signal SRAM_Q3 		     : std_logic_vector(7 downto 0);
	signal XRAM_WE_N3        : std_logic;

	signal Boot_flag, Replace_flag : std_logic;
	--signal dummy_in	: std_logic_vector(2 downto 0);

begin

	HEX0_in <= HEX0_out_r;
	HEX1_in <= HEX1_out_r;
	HEX2_in <= HEX2_out_r;
	HEX3_in <= HEX3_out_r;
	HEX4_in <= HEX4_out_r;
	HEX5_in <= HEX5_out_r;
	HEX0_out  <= HEX0_out_r;
	HEX1_out  <= HEX1_out_r;
	HEX2_out  <= HEX2_out_r;
	HEX3_out  <= HEX3_out_r;
	HEX4_out  <= HEX4_out_r;
	HEX5_out  <= HEX5_out_r;
	
	ADC_C_in <= ADC_C_out_r;

	LEDR1_out <= LEDR1_out_r(1 downto 0);
	LEDR1_in_r(1 downto 0) <= LEDR1_in(1 downto 0);
	LEDR1_in_r(7 downto 2) <= LEDR1_out_r(7 downto 2);
	
	KEY_in_r(4 downto 1) <= KEY; -- The KEY buttons
	GNDKEY2 <= KEY_out_r(2); -- This allows for easily adding a pushbutton in the arduino connector header
	GNDKEY3 <= KEY_out_r(3); -- This allows for easily adding a pushbutton in the arduino connector header
	
	KEY_in_r(5) <= GSENSOR_SDO;
	KEY_in_r(6) <= GSENSOR_INT1;
	KEY_in_r(7) <= GSENSOR_INT2;
	GSENSOR_SDI <= KEY_out_r(5);
	GSENSOR_SCLK <= KEY_out_r(6);
	GSENSOR_CS_n <= KEY_out_r(7);

	KEY_in_r(0) <= ext_ram_en or RAM_Rd or RXD_IsO or RXD_O or KEY_out_r(5); -- Saved here to get rid of warning
	
	max10_onchip_flash: onchip_flash
	port map(
		clock                   				=> Clk,
		avmm_csr_addr           				=> UFM_CONTROL_CMD_out_r(0),				
		avmm_csr_read           				=> UFM_CONTROL_CMD_out_r(1),
		avmm_csr_write          				=> UFM_CONTROL_CMD_out_r(2),
		-- avmm_csr_writedata      : in  std_logic_vector(31 downto 0);
		avmm_csr_writedata(31 downto 24)		=> UFM_CONTROL3_out_r,
		avmm_csr_writedata(23 downto 16)		=> UFM_CONTROL2_out_r,
		avmm_csr_writedata(15 downto 8)		=> UFM_CONTROL1_out_r,
		avmm_csr_writedata(7 downto 0)		=> UFM_CONTROL0_out_r,
		
		--avmm_csr_readdata       : out std_logic_vector(31 downto 0);
		avmm_csr_readdata(31 downto 24)		=> UFM_CONTROL3_in_r,
		avmm_csr_readdata(23 downto 16)		=> UFM_CONTROL2_in_r,
		avmm_csr_readdata(15 downto 8)		=> UFM_CONTROL1_in_r,
		avmm_csr_readdata(7 downto 0)			=> UFM_CONTROL0_in_r,
		
		--avmm_data_addr          : in  std_logic_vector(18 downto 0);
		avmm_data_addr(18 downto 16)			=> UFM_ADD2_out_r(2 downto 0),
		avmm_data_addr(15 downto 8)			=> UFM_ADD1_out_r,
		avmm_data_addr(7 downto 0)				=> UFM_ADD0_out_r,
		
		avmm_data_read          				=> UFM_DATA_CMD_out_r(4),
		--avmm_data_writedata     : in  std_logic_vector(31 downto 0);
		avmm_data_writedata(31 downto 24)	=> not UFM_DATA3_out_r,
		avmm_data_writedata(23 downto 16)	=> not UFM_DATA2_out_r,
		avmm_data_writedata(15 downto 8)		=> not UFM_DATA1_out_r,
		avmm_data_writedata(7 downto 0)		=> not UFM_DATA0_out_r,
		
		avmm_data_write         				=> UFM_DATA_CMD_out_r(5),
		--avmm_data_readdata      : out std_logic_vector(31 downto 0);
		--avmm_data_readdata(31 downto 24)		=> UFM_DATA3_in_r,
		--avmm_data_readdata(23 downto 16)		=> UFM_DATA2_in_r,
		--avmm_data_readdata(15 downto 8)		=> UFM_DATA1_in_r,
		--avmm_data_readdata(7 downto 0)		=> UFM_DATA0_in_r,
		avmm_data_readdata                  => UFM_DATA,
		
		avmm_data_waitrequest   				=> UFM_DATA_STATUS_in_r(0),
		avmm_data_readdatavalid 				=> UFM_readdatavalid,
		avmm_data_burstcount    				=> UFM_DATA_CMD_out_r(3 downto 0),
		reset_n                 				=> Rst_n
	);
	
	UFM_ADD0_in_r	<=	UFM_ADD0_out_r;
	UFM_ADD1_in_r	<=	UFM_ADD1_out_r;
	UFM_ADD2_in_r	<=	UFM_ADD2_out_r;
	
	UFM_DATA0_in_r	<=	not UFM_DATA_LATCHED(7 downto 0);
	UFM_DATA1_in_r	<=	not UFM_DATA_LATCHED(15 downto 8);
	UFM_DATA2_in_r	<=	not UFM_DATA_LATCHED(23 downto 16);
	UFM_DATA3_in_r	<=	not UFM_DATA_LATCHED(31 downto 24);
	
	UFM_DATA_CMD_in_r	<=	UFM_DATA_CMD_out_r;
	UFM_DATA_STATUS_in_r(7 downto 2)	<=	UFM_DATA_STATUS_out_r(7 downto 2);
	UFM_CONTROL_CMD_in_r	<=	UFM_CONTROL_CMD_out_r;
	
	-- The flash data output of the UFM in the MAX10 is only available when readdatavalid is one for one clock cycle
	process (Rst_n, clk, UFM_readdatavalid, UFM_DATA_CMD_out_r(6))
	begin
		if Rst_n='0' then
			UFM_DATA_LATCHED<=(others =>'0');
		elsif clk'event and clk = '1' then
			if UFM_readdatavalid = '1' then
				UFM_DATA_LATCHED<=UFM_DATA;
			end if;
			if UFM_readdatavalid = '1' and UFM_DATA_CMD_out_r(4) = '0' then
				UFM_DATA_STATUS_in_r(1)<='1'; -- Latched readdatavalid available in data status register
			end if;
			if UFM_DATA_CMD_out_r(4) = '1' then
				UFM_DATA_STATUS_in_r(1)<='0'; -- Starting a write data command clears readdatavalid in the data status register
			end if;
		end if;
	end process;
		
	adc_mega_0 : component ADC
	port map (
		CLOCK    => clk, --      clk.clk
		RESET    => ADC_C_out_r(7), --    reset.reset (Using the most significant bit of SFR ADC_C)
		CH0      => ADC_CH0_r,   -- readings.export
		CH1      => ADC_CH1_r,   --         .export
		CH2      => ADC_CH2_r,   --         .export
		CH3      => ADC_CH3_r,   --         .export
		CH4      => ADC_CH4_r,   --         .export
		CH5      => ADC_CH5_r,   --         .export
		CH6      => ADC_CH6_r,   --         .export
		CH7      => ADC_CH7_r    --         .export
	);
	
	Rst_n<=RstIn;
   Ready <= '1'; -- No wait states here!
   Boot_n <= SharedRamReg(0);

	process (Rst_n, clk)
	begin
		if Rst_n='0' then
			IO_Addr_r    <= (others =>'0');
			RAM_Addr_r   <= (others =>'0');
		elsif clk'event and clk = '1' then
			IO_Addr_r <= IO_Addr;
			if Ready = '1' then
				RAM_Addr_r  <= RAM_Addr;
			end if;
		end if;
	end process;

	XRAM_Addr <= RAM_Addr_r;

	rom : ROM52 
	generic map(
			AddrWidth =>ROMAddressWidth)
	port map(
			Clk => Clk,
			A => ROM_Addr(ROMAddressWidth - 1 downto 0),
			D => ROM_Data_Boot);
	
	pll_33_MHz:  CV_PLL
	port map(
			inclk0 => CLOCK_50,
			areset    => not Rst_n,
			c0 => Clk
		);
	
	g_rams0 : if XRAMAddressWidth > 15 generate
		ext_ram_en <= '0'; -- no external XRAM
	end generate;

	g_rams1 : if XRAMAddressWidth < 16 and  XRAMAddressWidth > 0 generate
		zeros <= (others => '0');
		ext_ram_en <= '1' when XRAM_Addr(15 downto XRAMAddressWidth) /= zeros(15 downto XRAMAddressWidth) else 
					  '0';
	end generate;

	-- xram bus access is pipelined.
	-- so use registered signal for selecting read data
 	RAM_RData <= RAM_DO;

	-- internal XRAM select signal is active low.
	-- so internal xram is selected when external XRAM is not selected (ext_ram_en = '0')
	--int_xram_sel_n <= ext_ram_en;
	RAM_WE_n       <= not RAM_Wr;
		
	-- User program.  When the bootloader is active behaves as RAM.
	ram1b: SSRAM2
	generic map(
		AddrWidth => ram1_bits,
		Inst_Name => "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=CODE")
	PORT map
	(
		address		=> SRAM_Addr1,
		clock			=> Clk,
		data			=> RAM_WData,
		wren			=> int_xram_sel_n1 nor XRAM_WE_N1,
		q				=> SRAM_Q1	);

	-- User xdata.  When the bootloader is active, not accesible.
	ram2b: SSRAM2
	generic map(
		AddrWidth => ram2_bits,
		Inst_Name => "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=XDAT")
	PORT map
	(
		address		=> SRAM_Addr2,
		clock			=> Clk,
		data			=> RAM_WData,
		wren			=> int_xram_sel_n2 nor XRAM_WE_N2,
		q				=> SRAM_Q2	);
			
	-- Debugger data.  Use with the debugger and bootloader.
	ram3b: SSRAM2
	generic map(
		AddrWidth => ram3_bits,
		Inst_Name => "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=DEBU")
	PORT map
	(
		address		=> SRAM_Addr3,
		clock			=> Clk,
		data			=> RAM_WData,
		wren			=> int_xram_sel_n3 nor XRAM_WE_N3,
		q				=> SRAM_Q3	);
			
	-- Toggle between SRAM1 and SRAM2 by using signal Boot_n
	SRAM_Addr1 <= XRAM_Addr(ram1_bits-1 downto 0) when Boot_n='1' else ROM_Addr(ram1_bits-1 downto 0);
	SRAM_Addr2 <= XRAM_Addr(ram2_bits-1 downto 0) when Boot_n='0' else ROM_Addr(ram2_bits-1 downto 0);
	SRAM_Addr3 <= XRAM_Addr(ram3_bits-1 downto 0);
	XRAM_WE_N1 <= RAM_WE_n when (Boot_n='1') and (XRAM_Addr(15)='0') else '1';
	XRAM_WE_N2 <= RAM_WE_n when (Boot_n='0') and (XRAM_Addr(15)='0') else '1';
	XRAM_WE_N3 <= RAM_WE_n when (XRAM_Addr(15)='1') else '1';
	-- If the sram is not used for xdata then is used for code and the enable must be zero (always enabled)
	int_xram_sel_n1 <= '0';
	int_xram_sel_n2 <= '0';
	int_xram_sel_n3 <= '0';

	RAM_DO <= SRAM_Q1 when (Boot_n='1') and (XRAM_Addr(15)='0') else 
	          SRAM_Q2 when (Boot_n='0') and (XRAM_Addr(15)='0') else
	          SRAM_Q3;

	-- Compare the ROM address on the rising edge of the clock
	clk_compare_address: process(clk) is
	begin
		if clk'event and clk='1' then
		
			-- Bootloader is at address 0xf000, debugger is at address 0xc000
			-- together they use 16k , sharing the same memory space from 0xc000 to 0xffff
			if ROM_Addr(15 downto 14)="11" then
				Boot_flag<='1';
			else
				Boot_flag<='0';
			end if;
			
			-- Check for byte replacemente address.  Usefull to read/write SFR using a 'pointer'
			if ROM_Addr=Rep_Addr then
				Replace_flag<=SharedRamReg(1); -- Bit one of SFR at address 0xC3 enables/disables byte replacement
			else
				Replace_flag<='0';
			end if;
			
		end if;
	end process;
	
	-- Multiplexer to select from the boot ROM, replacemente byte register, or the user code.
	ROM_Data <= ROM_Data_Boot when ( (Replace_flag='0') and (Boot_flag='1') ) else 
				Rep_Value     when ( (Replace_flag='1') and (Boot_flag='1') ) else
				Rep_Value     when ( (Replace_flag='1') and (Boot_flag='0') ) else
				SRAM_Q2       when ( (Replace_flag='0') and (Boot_flag='0') and (Boot_n='1') ) else
				SRAM_Q1;
	
	core51 : T51
		generic map(
			DualBus         => 1,
			SecondDPTR      => 1,
			tristate        => tristate,
			t8032           => 0,
			RAMAddressWidth => IRAMAddressWidth)
		port map(
			Clk          => Clk,
			Rst_n        => Rst_n,
			Ready        => Ready,
			ROM_Addr     => ROM_Addr,
			ROM_Data     => ROM_Data,
			RAM_Addr     => RAM_Addr,
			RAM_RData    => RAM_RData,
			RAM_WData    => RAM_WData,
			RAM_Rd       => RAM_Rd,
			RAM_Wr       => RAM_Wr,
			Int_Trig     => Int_Trig,
			Int_Acc      => Int_Acc,
			SFR_Rd_RMW   => IO_Rd,
			SFR_Wr       => IO_Wr,
			SFR_Addr     => IO_Addr,
			SFR_WData    => IO_WData,
			SFR_RData_in => IO_RData,
			LCall_Addr  	=> LCall_Addr,
			Break_point_in  => Break_point_signal);

	glue51 : T51_Glue
	  generic map(
        tristate   => tristate)
		port map(
		Clk        => Clk,
        Rst_n      => Rst_n,
        INT0       => INT0,
        INT1       => INT1,
        RI         => RI,
        TI         => TI,
        OF0        => OF0,
        OF1        => OF1,
        OF2        => OF2,
        BPI        => BPI,
        IO_Wr      => IO_Wr,
        IO_Addr    => IO_Addr,
        IO_Addr_r  => IO_Addr_r,
        IO_WData   => IO_WData,
        IO_RData   => IO_RData_arr(0),
        Selected   => IO_RData_en(0),
        Int_Acc    => Int_Acc,
        R0         => R0,
        R1         => R1,
        SMOD       => SMOD,
        P0_Sel     => P0_Sel,
        P1_Sel     => P1_Sel,
        P2_Sel     => P2_Sel,
        P3_Sel     => P3_Sel,
        P4_Sel     => P4_Sel,
        HEX0_Sel   => HEX0_Sel,
        HEX1_Sel   => HEX1_Sel,
        HEX2_Sel   => HEX2_Sel,
        HEX3_Sel   => HEX3_Sel,
        HEX4_Sel   => HEX4_Sel,
        HEX5_Sel   => HEX5_Sel,
        LEDR0_Sel  => LEDR0_Sel,
        LEDR1_Sel  => LEDR1_Sel,
        KEY_Sel   => KEY_Sel,
        TMOD_Sel   => TMOD_Sel,
        TL0_Sel    => TL0_Sel,
        TL1_Sel    => TL1_Sel,
        TH0_Sel    => TH0_Sel,
        TH1_Sel    => TH1_Sel,
        T2CON_Sel  => T2CON_Sel,
        RCAP2L_Sel => RCAP2L_Sel,
        RCAP2H_Sel => RCAP2H_Sel,
        TL2_Sel    => TL2_Sel,
        TH2_Sel    => TH2_Sel,
        SCON_Sel   => SCON_Sel,
        SBUF_Sel   => SBUF_Sel,
		P0MOD_Sel  => P0MOD_Sel,
		P1MOD_Sel  => P1MOD_Sel,
		P2MOD_Sel  => P2MOD_Sel,
		P3MOD_Sel  => P3MOD_Sel,
		P4MOD_Sel  => P4MOD_Sel,
		SharedRamReg_Sel  => SharedRamReg_Sel,
		BPC_Sel    => BPC_Sel,
		BPS_Sel    => BPS_Sel,
		BPAL_Sel   => BPAL_Sel,
		BPAH_Sel   => BPAH_Sel,
		LCall_Addr_L_Sel => LCall_Addr_L_Sel,
		LCall_Addr_H_Sel => LCall_Addr_H_Sel,
		Rep_Addr_L_Sel => Rep_Addr_L_Sel,
		Rep_Addr_H_Sel => Rep_Addr_H_Sel,
		Rep_Value_Sel => Rep_Value_Sel,
		UFM_ADD0_Sel => UFM_ADD0_Sel,
		UFM_ADD1_Sel => UFM_ADD1_Sel,
		UFM_ADD2_Sel => UFM_ADD2_Sel,
		UFM_DATA0_Sel => UFM_DATA0_Sel,
		UFM_DATA1_Sel => UFM_DATA1_Sel,
		UFM_DATA2_Sel => UFM_DATA2_Sel,
		UFM_DATA3_Sel => UFM_DATA3_Sel,
		UFM_CONTROL0_Sel => UFM_CONTROL0_Sel,
		UFM_CONTROL1_Sel => UFM_CONTROL1_Sel,
		UFM_CONTROL2_Sel => UFM_CONTROL2_Sel,
		UFM_CONTROL3_Sel => UFM_CONTROL3_Sel,
		UFM_DATA_CMD_Sel => UFM_DATA_CMD_Sel,
		UFM_DATA_STATUS_Sel => UFM_DATA_STATUS_Sel,
		UFM_CONTROL_CMD_Sel => UFM_CONTROL_CMD_Sel,
		ADC_C_Sel => ADC_C_Sel,
		ADC_L_Sel => ADC_L_Sel,
		ADC_H_Sel => ADC_H_Sel,
		
        P0_Wr      => P0_Wr,
        P1_Wr      => P1_Wr,
        P2_Wr      => P2_Wr,
        P3_Wr      => P3_Wr,
        P4_Wr      => P4_Wr,
        HEX0_Wr    => HEX0_Wr,
        HEX1_Wr    => HEX1_Wr,
        HEX2_Wr    => HEX2_Wr,
        HEX3_Wr    => HEX3_Wr,
        HEX4_Wr    => HEX4_Wr,
        HEX5_Wr    => HEX5_Wr,
        LEDR0_Wr   => LEDR0_Wr,
        LEDR1_Wr   => LEDR1_Wr,
        KEY_Wr    => KEY_Wr,
        TMOD_Wr    => TMOD_Wr,
        TL0_Wr     => TL0_Wr,
        TL1_Wr     => TL1_Wr,
        TH0_Wr     => TH0_Wr,
        TH1_Wr     => TH1_Wr,
        T2CON_Wr   => T2CON_Wr,
        RCAP2L_Wr  => RCAP2L_Wr,
        RCAP2H_Wr  => RCAP2H_Wr,
        TL2_Wr     => TL2_Wr,
        TH2_Wr     => TH2_Wr,
        SCON_Wr    => SCON_Wr,
        SBUF_Wr    => SBUF_Wr,
		P0MOD_Wr   => P0MOD_Wr,
		P1MOD_Wr   => P1MOD_Wr,
		P2MOD_Wr   => P2MOD_Wr,
		P3MOD_Wr   => P3MOD_Wr,
		P4MOD_Wr   => P4MOD_Wr,
  		SharedRamReg_Wr => SharedRamReg_Wr,
  		BPC_Wr    => BPC_Wr,
		BPS_Wr    => BPS_Wr,
		BPAL_Wr   => BPAL_Wr,
		BPAH_Wr   => BPAH_Wr,
 		LCall_Addr_L_Wr => LCall_Addr_L_Wr,
		LCall_Addr_H_Wr => LCall_Addr_H_Wr,
 		Rep_Addr_L_Wr => Rep_Addr_L_Wr,
		Rep_Addr_H_Wr => Rep_Addr_H_Wr,
		Rep_Value_Wr => Rep_Value_Wr,
		UFM_ADD0_Wr => UFM_ADD0_Wr,
		UFM_ADD1_Wr => UFM_ADD1_Wr,
		UFM_ADD2_Wr => UFM_ADD2_Wr,
		UFM_DATA0_Wr => UFM_DATA0_Wr,
		UFM_DATA1_Wr => UFM_DATA1_Wr,
		UFM_DATA2_Wr => UFM_DATA2_Wr,
		UFM_DATA3_Wr => UFM_DATA3_Wr,
		UFM_CONTROL0_Wr => UFM_CONTROL0_Wr,
		UFM_CONTROL1_Wr => UFM_CONTROL1_Wr,
		UFM_CONTROL2_Wr => UFM_CONTROL2_Wr,
		UFM_CONTROL3_Wr => UFM_CONTROL3_Wr,
		UFM_DATA_CMD_Wr => UFM_DATA_CMD_Wr,
		UFM_DATA_STATUS_Wr => UFM_DATA_STATUS_Wr,
		UFM_CONTROL_CMD_Wr => UFM_CONTROL_CMD_Wr,
		ADC_C_Wr => ADC_C_Wr,
		ADC_L_Wr => ADC_L_Wr,
		ADC_H_Wr => ADC_H_Wr,

        Int_Trig   => Int_Trig);

    ADC_C : T51_Port
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Sel        => ADC_C_Sel,
        Rd_RMW     => IO_Rd,
        Wr         => ADC_C_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(34),
        IOPort_in  => ADC_C_in,
        IOPort_out => ADC_C_out_r);
   
	 IO_RData_en(34) <= ADC_C_Sel;

    ADC_L : T51_Port
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Sel        => ADC_L_Sel,
        Rd_RMW     => IO_Rd,
        Wr         => ADC_L_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(35),
        IOPort_in  => ADC_L_in,
        IOPort_out => ADC_L_out_r);
   
	 IO_RData_en(35) <= ADC_L_Sel;

    ADC_H : T51_Port
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Sel        => ADC_H_Sel,
        Rd_RMW     => IO_Rd,
        Wr         => ADC_H_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(36),
        IOPort_in  => ADC_H_in,
        IOPort_out => ADC_H_out_r);
   
	 IO_RData_en(36) <= ADC_H_Sel;
	 

	process (ADC_C_out_r, ADC_CH0_r, ADC_CH1_r, ADC_CH2_r, ADC_CH3_r, ADC_CH4_r, ADC_CH5_r, ADC_CH6_r, ADC_CH7_r)
	begin
		 -- Now select what channel to read
		 case ADC_C_out_r(2 downto 0) is
			when "000" =>
			  ADC_L_in<=ADC_CH0_r(7 downto 0);
			  ADC_H_in(3 downto 0)<=ADC_CH0_r(11 downto 8);
			  ADC_H_in(7 downto 4)<="0000";
			when "001" =>
			  ADC_L_in<=ADC_CH1_r(7 downto 0);
			  ADC_H_in(3 downto 0)<=ADC_CH1_r(11 downto 8);
			  ADC_H_in(7 downto 4)<="0000";
			when "010" =>
			  ADC_L_in<=ADC_CH2_r(7 downto 0);
			  ADC_H_in(3 downto 0)<=ADC_CH2_r(11 downto 8);
			  ADC_H_in(7 downto 4)<="0000";
			when "011" =>
			  ADC_L_in<=ADC_CH3_r(7 downto 0);
			  ADC_H_in(3 downto 0)<=ADC_CH3_r(11 downto 8);
			  ADC_H_in(7 downto 4)<="0000";
			when "100" =>
			  ADC_L_in<=ADC_CH4_r(7 downto 0);
			  ADC_H_in(3 downto 0)<=ADC_CH4_r(11 downto 8);
			  ADC_H_in(7 downto 4)<="0000";
			when "101" =>
			  ADC_L_in<=ADC_CH5_r(7 downto 0);
			  ADC_H_in(3 downto 0)<=ADC_CH5_r(11 downto 8);
			  ADC_H_in(7 downto 4)<="0000";
			when "110" =>
			  ADC_L_in<=ADC_CH6_r(7 downto 0);
			  ADC_H_in(3 downto 0)<=ADC_CH6_r(11 downto 8);
			  ADC_H_in(7 downto 4)<="0000";
			when "111" =>
			  ADC_L_in<=ADC_CH7_r(7 downto 0);
			  ADC_H_in(3 downto 0)<=ADC_CH7_r(11 downto 8);
			  ADC_H_in(7 downto 4)<="0000";
			when others =>
			  ADC_L_in<=ADC_CH0_r(7 downto 0);
			  ADC_H_in(3 downto 0)<=ADC_CH0_r(11 downto 8);
			  ADC_H_in(7 downto 4)<="0000";
		 end case;
	end process;
		  
    tp0 : CV_PortIO
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Port_Sel   => P0_Sel,
        Mode_Sel   => P0MOD_Sel,
        Port_Wr    => P0_Wr,
        Mode_Wr    => P0MOD_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(1),
        IOPort     => P0);

    IO_RData_en(1) <= P0_Sel or P0MOD_Sel;

    tp1 : CV_PortIO
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Port_Sel   => P1_Sel,
        Mode_Sel   => P1MOD_Sel,
        Port_Wr    => P1_Wr,
        Mode_Wr    => P1MOD_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(2),
        IOPort     => P1);

    IO_RData_en(2) <= P1_Sel or P1MOD_Sel;

    tp2 : CV_PortIO
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Port_Sel   => P2_Sel,
        Mode_Sel   => P2MOD_Sel,
        Port_Wr    => P2_Wr,
        Mode_Wr    => P2MOD_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(3),
        IOPort     => P2);

    IO_RData_en(3) <= P2_Sel or P2MOD_Sel;

    tp3 : CV_PortIO
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Port_Sel   => P3_Sel,
        Mode_Sel   => P3MOD_Sel,
        Port_Wr    => P3_Wr,
        Mode_Wr    => P3MOD_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(4),
        IOPort     => P3);

    IO_RData_en(4) <= P3_Sel or P3MOD_Sel;


    thex0 : T51_Port
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Sel        => HEX0_Sel,
        Rd_RMW     => IO_Rd,
        Wr         => HEX0_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(8),
        IOPort_in  => HEX0_in,
        IOPort_out => HEX0_out_r);

    IO_RData_en(8) <= HEX0_Sel;

    thex1 : T51_Port
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Sel        => HEX1_Sel,
        Rd_RMW     => IO_Rd,
        Wr         => HEX1_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(9),
        IOPort_in  => HEX1_in,
        IOPort_out => HEX1_out_r);

    IO_RData_en(9) <= HEX1_Sel;

    thex2 : T51_Port
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Sel        => HEX2_Sel,
        Rd_RMW     => IO_Rd,
        Wr         => HEX2_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(10),
        IOPort_in  => HEX2_in,
        IOPort_out => HEX2_out_r);

    IO_RData_en(10) <= HEX2_Sel;

    thex3 : T51_Port
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Sel        => HEX3_Sel,
        Rd_RMW     => IO_Rd,
        Wr         => HEX3_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(11),
        IOPort_in  => HEX3_in,
        IOPort_out => HEX3_out_r);

    IO_RData_en(11) <= HEX3_Sel;

    tledr0 : T51_Port
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Sel        => LEDR0_Sel,
        Rd_RMW     => IO_Rd,
        Wr         => LEDR0_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(12),
        IOPort_in  => LEDR0_in,
        IOPort_out => LEDR0_out);

    IO_RData_en(12) <= LEDR0_Sel;

    tledr1 : T51_Port
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Sel        => LEDR1_Sel,
        Rd_RMW     => IO_Rd,
        Wr         => LEDR1_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(13),
        IOPort_in  => LEDR1_in_r,
        IOPort_out => LEDR1_out_r);

    IO_RData_en(13) <= LEDR1_Sel;

    tkey : T51_Port
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Sel        => KEY_Sel,
        Rd_RMW     => IO_Rd,
        Wr         => KEY_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(14),
        IOPort_in  => KEY_in_r,
        IOPort_out => KEY_out_r);

    IO_RData_en(14) <= KEY_Sel;


    tc01 : T51_TC01
      generic map(
        FastCount => 0,
        tristate  => tristate)
      port map(
        Clk      => Clk,
        Rst_n    => Rst_n,
        T0       => T0,
        T1       => T1,
        INT0     => INT0,
        INT1     => INT1,
        M_Sel    => TMOD_Sel,
        H0_Sel   => TH0_Sel,
        L0_Sel   => TL0_Sel,
        H1_Sel   => TH1_Sel,
        L1_Sel   => TL1_Sel,
        R0       => R0,
        R1       => R1,
        M_Wr     => TMOD_Wr,
        H0_Wr    => TH0_Wr,
        L0_Wr    => TL0_Wr,
        H1_Wr    => TH1_Wr,
        L1_Wr    => TL1_Wr,
        Data_In  => IO_WData,
        Data_Out => IO_RData_arr(5),
        OF0      => OF0,
        OF1      => OF1);

    IO_RData_en(5) <= TMOD_Sel or TH0_Sel or TL0_Sel or TH1_Sel or TL1_Sel;

    tc2 : T51_TC2
      generic map(
        FastCount => 0,
        tristate  => tristate)
      port map(
        Clk      => Clk,
        Rst_n    => Rst_n,
        T2       => T2,
        T2EX     => T2EX,
        C_Sel    => T2CON_Sel,
        CH_Sel   => RCAP2H_Sel,
        CL_Sel   => RCAP2L_Sel,
        H_Sel    => TH2_Sel,
        L_Sel    => TL2_Sel,
        C_Wr     => T2CON_Wr,
        CH_Wr    => RCAP2H_Wr,
        CL_Wr    => RCAP2L_Wr,
        H_Wr     => TH2_Wr,
        L_Wr     => TL2_Wr,
        Data_In  => IO_WData,
        Data_Out => IO_RData_arr(6),
        UseR2    => UseR2,
        UseT2    => UseT2,
        UART_Clk => UART_Clk,
        F        => OF2);

    IO_RData_en(6) <= T2CON_Sel or RCAP2H_Sel or RCAP2L_Sel or TH2_Sel or TL2_Sel;

    uart : T51_UART
      generic map(
        FastCount => 0,
        tristate  => tristate)
      port map(
        Clk      => Clk,
        Rst_n    => Rst_n,
        UseR2    => UseR2,
        UseT2    => UseT2,
        BaudC2   => UART_Clk,
        BaudC1   => OF1,
        SC_Sel   => SCON_Sel,
        SB_Sel   => SBUF_Sel,
        SC_Wr    => SCON_Wr,
        SB_Wr    => SBUF_Wr,
        SMOD     => SMOD,
        Data_In  => IO_WData,
        Data_Out => IO_RData_arr(7),
        RXD      => RXD,
        RXD_IsO  => RXD_IsO,
        RXD_O    => RXD_O,
        TXD      => TXD,
        RI       => RI,
        TI       => TI);
        
    IO_RData_en(7) <= SCON_Sel or SBUF_Sel;
    

	memctrl: Memory_Control
	generic map(
		tristate  => tristate )
	port map(
        Clk              => Clk,
        Rst_n            => Rst_n,
		SharedRamReg_Sel => SharedRamReg_Sel,
		SharedRamReg_Wr  => SharedRamReg_Wr,
		Data_In		     => IO_WData,
		Data_Out	     => IO_RData_arr(16),
		SharedRamReg_Out => SharedRamReg);

    IO_RData_en(16) <= SharedRamReg_Sel;
    
    BPctrl: CV_Debug
	 generic map(
		tristate => tristate)
    PORT map(
 		Clk			     => Clk,
		Rst_n		     => Rst_n,
		BPC_Sel 		 => BPC_Sel,
		BPC_Wr  		 => BPC_Wr,
		BPS_Sel 		 => BPS_Sel,
		BPS_Wr  		 => BPS_Wr,
		BPAL_Sel 		 => BPAL_Sel,
		BPAL_Wr  		 => BPAL_Wr,
		BPAH_Sel 		 => BPAH_Sel,
		BPAH_Wr  		 => BPAH_Wr,
		LCall_Addr_L_Sel => LCall_Addr_L_Sel,
		LCall_Addr_L_Wr  => LCall_Addr_L_Wr,
		LCall_Addr_H_Sel => LCall_Addr_H_Sel,
		LCall_Addr_H_Wr  => LCall_Addr_H_Wr,
		Rep_Addr_L_Sel => Rep_Addr_L_Sel,
		Rep_Addr_L_Wr  => Rep_Addr_L_Wr,
		Rep_Addr_H_Sel => Rep_Addr_H_Sel,
		Rep_Addr_H_Wr  => Rep_Addr_H_Wr,
		Rep_Value_Sel => Rep_Value_Sel,
		Rep_Value_Wr  => Rep_Value_Wr,
		Data_In		     => IO_WData,
		Data_Out	     => IO_RData_arr(17),
		ROM_Addr  		 => ROM_Addr,
		LCall_Addr  	 => LCall_Addr,
		Rep_Addr 	 	 => Rep_Addr,
		Rep_Value 	 	 => Rep_Value,
		BPI              => BPI,
		Break_point_out  => Break_point_signal
  );
   
   IO_RData_en(17) <= BPC_Sel or BPS_Sel or BPAL_Sel or BPAH_Sel or LCall_Addr_L_Sel or LCall_Addr_H_Sel
                      or Rep_Addr_L_Sel or Rep_Addr_H_Sel or Rep_Value_Sel;


    thex4 : T51_Port
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Sel        => HEX4_Sel,
        Rd_RMW     => IO_Rd,
        Wr         => HEX4_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(18),
        IOPort_in  => HEX4_in,
        IOPort_out => HEX4_out_r);

    IO_RData_en(18) <= HEX4_Sel;

    thex5 : T51_Port
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Sel        => HEX5_Sel,
        Rd_RMW     => IO_Rd,
        Wr         => HEX5_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(19),
        IOPort_in  => HEX5_in,
        IOPort_out => HEX5_out_r);

    IO_RData_en(19) <= HEX5_Sel;

    UFM_ADD0_Port : T51_Port
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Sel        => UFM_ADD0_Sel,
        Rd_RMW     => IO_Rd,
        Wr         => UFM_ADD0_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(27),
        IOPort_in  => UFM_ADD0_in_r,
        IOPort_out => UFM_ADD0_out_r);

    IO_RData_en(27) <= UFM_ADD0_Sel;

    UFM_ADD1_Port : T51_Port
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Sel        => UFM_ADD1_Sel,
        Rd_RMW     => IO_Rd,
        Wr         => UFM_ADD1_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(28),
        IOPort_in  => UFM_ADD1_in_r,
        IOPort_out => UFM_ADD1_out_r);

    IO_RData_en(28) <= UFM_ADD1_Sel;

    UFM_ADD2_Port : T51_Port
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Sel        => UFM_ADD2_Sel,
        Rd_RMW     => IO_Rd,
        Wr         => UFM_ADD2_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(29),
        IOPort_in  => UFM_ADD2_in_r,
        IOPort_out => UFM_ADD2_out_r);

    IO_RData_en(29) <= UFM_ADD2_Sel;
	 
	 tp4 : CV_PortIO
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Port_Sel   => P4_Sel,
        Mode_Sel   => P4MOD_Sel,
        Port_Wr    => P4_Wr,
        Mode_Wr    => P4MOD_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(30),
        IOPort     => P4);

    IO_RData_en(30) <= P4_Sel or P4MOD_Sel;
	  
    UFM_DATA0_Port : T51_Port
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Sel        => UFM_DATA0_Sel,
        Rd_RMW     => IO_Rd,
        Wr         => UFM_DATA0_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(31),
        IOPort_in  => UFM_DATA0_in_r,
        IOPort_out => UFM_DATA0_out_r);
		  
    IO_RData_en(31) <= UFM_DATA0_Sel;

	 UFM_DATA1_Port : T51_Port
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Sel        => UFM_DATA1_Sel,
        Rd_RMW     => IO_Rd,
        Wr         => UFM_DATA1_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(32),
        IOPort_in  => UFM_DATA1_in_r,
        IOPort_out => UFM_DATA1_out_r);
		  
    IO_RData_en(32) <= UFM_DATA1_Sel;

	 UFM_DATA2_Port : T51_Port
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Sel        => UFM_DATA2_Sel,
        Rd_RMW     => IO_Rd,
        Wr         => UFM_DATA2_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(33),
        IOPort_in  => UFM_DATA2_in_r,
        IOPort_out => UFM_DATA2_out_r);
		  
    IO_RData_en(33) <= UFM_DATA2_Sel;

	 UFM_DATA3_Port : T51_Port
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Sel        => UFM_DATA3_Sel,
        Rd_RMW     => IO_Rd,
        Wr         => UFM_DATA3_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(22),
        IOPort_in  => UFM_DATA3_in_r,
        IOPort_out => UFM_DATA3_out_r);
		  
    IO_RData_en(22) <= UFM_DATA3_Sel;

	 UFM_CONTROL0_Port : T51_Port
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Sel        => UFM_CONTROL0_Sel,
        Rd_RMW     => IO_Rd,
        Wr         => UFM_CONTROL0_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(20),
        IOPort_in  => UFM_CONTROL0_in_r,
        IOPort_out => UFM_CONTROL0_out_r);
		  
    IO_RData_en(20) <= UFM_CONTROL0_Sel;

	 UFM_CONTROL1_Port : T51_Port
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Sel        => UFM_CONTROL1_Sel,
        Rd_RMW     => IO_Rd,
        Wr         => UFM_CONTROL1_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(21),
        IOPort_in  => UFM_CONTROL1_in_r,
        IOPort_out => UFM_CONTROL1_out_r);
		  
    IO_RData_en(21) <= UFM_CONTROL1_Sel;

	 UFM_CONTROL2_Port : T51_Port
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Sel        => UFM_CONTROL2_Sel,
        Rd_RMW     => IO_Rd,
        Wr         => UFM_CONTROL2_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(25),
        IOPort_in  => UFM_CONTROL2_in_r,
        IOPort_out => UFM_CONTROL2_out_r);
		  
    IO_RData_en(25) <= UFM_CONTROL2_Sel;

	 UFM_CONTROL3_Port : T51_Port
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Sel        => UFM_CONTROL3_Sel,
        Rd_RMW     => IO_Rd,
        Wr         => UFM_CONTROL3_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(26),
        IOPort_in  => UFM_CONTROL3_in_r,
        IOPort_out => UFM_CONTROL3_out_r);
		  
    IO_RData_en(26) <= UFM_CONTROL3_Sel;

	 UFM_DATA_CMD_Port : T51_Port
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Sel        => UFM_DATA_CMD_Sel,
        Rd_RMW     => IO_Rd,
        Wr         => UFM_DATA_CMD_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(15),
        IOPort_in  => UFM_DATA_CMD_in_r,
        IOPort_out => UFM_DATA_CMD_out_r);
		  
    IO_RData_en(15) <= UFM_DATA_CMD_Sel;

	 UFM_DATA_STATUS_Port : T51_Port
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Sel        => UFM_DATA_STATUS_Sel,
        Rd_RMW     => IO_Rd,
        Wr         => UFM_DATA_STATUS_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(23),
        IOPort_in  => UFM_DATA_STATUS_in_r,
        IOPort_out => UFM_DATA_STATUS_out_r);
		  
    IO_RData_en(23) <= UFM_DATA_STATUS_Sel;

	 UFM_CONTROL_CMD_Port : T51_Port
      generic map(
        tristate   => tristate)
      port map(
        Clk        => Clk,
        Rst_n      => Rst_n,
        Sel        => UFM_CONTROL_CMD_Sel,
        Rd_RMW     => IO_Rd,
        Wr         => UFM_CONTROL_CMD_Wr,
        Data_In    => IO_WData,
        Data_Out   => IO_RData_arr(24),
        IOPort_in  => UFM_CONTROL_CMD_in_r,
        IOPort_out => UFM_CONTROL_CMD_out_r);
		  
    IO_RData_en(24) <= UFM_CONTROL_CMD_Sel;

    tristate_mux: if tristate/=0 generate
      drive: for i in 0 to ext_mux_in_num-1 generate
        IO_RData <= IO_RData_arr(i);
      end generate;
    end generate;

	  std_mux: if tristate=0 generate
	    process(IO_RData_en,IO_RData_arr)
	    begin
	      IO_RData <= IO_RData_arr(0);
	      for i in 1 to ext_mux_in_num-1 loop
	        if IO_RData_en(i)='1' then
	          IO_RData <= IO_RData_arr(i);
	        end if;
	      end loop;
	    end process;
	  end generate;

end;
