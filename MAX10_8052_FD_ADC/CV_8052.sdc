## Generated SDC file "CV_8052.sdc"

## Copyright (C) 2016  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel MegaCore Function License Agreement, or other 
## applicable license agreement, including, without limitation, 
## that your use is for the sole purpose of programming logic 
## devices manufactured by Intel and sold by Intel or its 
## authorized distributors.  Please refer to the applicable 
## agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 16.1.0 Build 196 10/24/2016 SJ Lite Edition"

## DATE    "Tue Oct 01 22:06:03 2024"

##
## DEVICE  "10M50DAF484C7G"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
create_clock -name {CLOCK_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLOCK_50}]
create_clock -name {max10_onchip_flash|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc} -period 181.818 -waveform { 0.000 90.909 } [get_pins {max10_onchip_flash|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {pll_33_MHz|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {pll_33_MHz|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 2 -divide_by 3 -master_clock {CLOCK_50} [get_pins {pll_33_MHz|altpll_component|auto_generated|pll1|clk[0]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {pll_33_MHz|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {pll_33_MHz|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {pll_33_MHz|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {pll_33_MHz|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {pll_33_MHz|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {max10_onchip_flash|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll_33_MHz|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {max10_onchip_flash|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {pll_33_MHz|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {max10_onchip_flash|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll_33_MHz|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {max10_onchip_flash|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {pll_33_MHz|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {pll_33_MHz|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll_33_MHz|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {pll_33_MHz|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll_33_MHz|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {max10_onchip_flash|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll_33_MHz|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {max10_onchip_flash|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {pll_33_MHz|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {max10_onchip_flash|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll_33_MHz|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {max10_onchip_flash|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {max10_onchip_flash|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc}] -rise_to [get_clocks {pll_33_MHz|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {max10_onchip_flash|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc}] -rise_to [get_clocks {pll_33_MHz|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {max10_onchip_flash|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc}] -fall_to [get_clocks {pll_33_MHz|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {max10_onchip_flash|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc}] -fall_to [get_clocks {pll_33_MHz|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {max10_onchip_flash|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc}] -rise_to [get_clocks {max10_onchip_flash|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {max10_onchip_flash|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc}] -fall_to [get_clocks {max10_onchip_flash|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {max10_onchip_flash|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc}] -rise_to [get_clocks {pll_33_MHz|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {max10_onchip_flash|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc}] -rise_to [get_clocks {pll_33_MHz|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {max10_onchip_flash|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc}] -fall_to [get_clocks {pll_33_MHz|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {max10_onchip_flash|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc}] -fall_to [get_clocks {pll_33_MHz|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {max10_onchip_flash|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc}] -rise_to [get_clocks {max10_onchip_flash|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {max10_onchip_flash|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc}] -fall_to [get_clocks {max10_onchip_flash|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 


#**************************************************************
# Set False Path
#**************************************************************

set_false_path -to [get_keepers {*altera_std_synchronizer:*|din_s1}]
set_false_path -to [get_registers {*|flash_busy_reg}]
set_false_path -to [get_registers {*|flash_busy_clear_reg}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

