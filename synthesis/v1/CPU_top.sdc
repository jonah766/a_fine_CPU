## Generated SDC file "butterfly_top.out.sdc"

## Copyright (C) 2023  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details, at
## https://fpgasoftware.intel.com/eula.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 22.1std.1 Build 917 02/14/2023 SC Lite Edition"

## DATE    "Sun Apr  9 23:14:26 2023"

##
## DEVICE  "5CSEMA5F31C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk50MHz} -period 20 -waveform {0 10} [get_ports {fastclk}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {clk50MHz}] -rise_to [get_clocks {clk50MHz}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {clk50MHz}] -rise_to [get_clocks {clk50MHz}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {clk50MHz}] -fall_to [get_clocks {clk50MHz}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {clk50MHz}] -fall_to [get_clocks {clk50MHz}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {clk50MHz}] -rise_to [get_clocks {clk50MHz}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {clk50MHz}] -rise_to [get_clocks {clk50MHz}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {clk50MHz}] -fall_to [get_clocks {clk50MHz}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {clk50MHz}] -fall_to [get_clocks {clk50MHz}] -hold 0.060  


#**************************************************************
# Set Input Delay
#**************************************************************
set_input_delay -clock clk50MHz -max 0.5 [all_inputs]
set_input_delay -clock clk50MHz -min 0.5 [all_inputs]


#**************************************************************
# Set Output Delay
#**************************************************************
set_output_delay -clock clk50MHz -max -rise 0.5 [all_outputs]
set_output_delay -clock clk50MHz -max -fall 0.5 [all_outputs]
set_output_delay -clock clk50MHz -min -rise 0.5 [all_outputs]
set_output_delay -clock clk50MHz -min -fall 0.5 [all_outputs]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



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

