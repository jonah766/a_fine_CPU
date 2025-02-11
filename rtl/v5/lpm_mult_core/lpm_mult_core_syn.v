// megafunction wizard: %LPM_MULT%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: lpm_mult 

// ============================================================
// File Name: lpm_mult_core.v
// Megafunction Name(s):
// 			lpm_mult
//
// Simulation Library Files(s):
// 			lpm
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 22.1std.1 Build 917 02/14/2023 SC Lite Edition
// ************************************************************


//Copyright (C) 2023  Intel Corporation. All rights reserved.
//Your use of Intel Corporation's design tools, logic functions 
//and other software and tools, and any partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Intel Program License 
//Subscription Agreement, the Intel Quartus Prime License Agreement,
//the Intel FPGA IP License Agreement, or other applicable license
//agreement, including, without limitation, that your use is for
//the sole purpose of programming logic devices manufactured by
//Intel and sold by Intel or its authorized distributors.  Please
//refer to the applicable agreement for further details, at
//https://fpgasoftware.intel.com/eula.


//lpm_mult DEDICATED_MULTIPLIER_CIRCUITRY="YES" DEVICE_FAMILY="Cyclone V" LPM_REPRESENTATION="SIGNED" LPM_WIDTHA=8 LPM_WIDTHB=8 LPM_WIDTHP=16 MAXIMIZE_SPEED=1 dataa datab result
//VERSION_BEGIN 22.1 cbx_cycloneii 2023:02:14:18:02:23:SC cbx_lpm_add_sub 2023:02:14:18:02:23:SC cbx_lpm_mult 2023:02:14:18:02:23:SC cbx_mgl 2023:02:14:18:15:38:SC cbx_nadder 2023:02:14:18:02:23:SC cbx_padd 2023:02:14:18:02:23:SC cbx_stratix 2023:02:14:18:02:23:SC cbx_stratixii 2023:02:14:18:02:23:SC cbx_util_mgl 2023:02:14:18:02:23:SC  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463


//synthesis_resources = 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  lpm_mult_core_mult
	( 
	dataa,
	datab,
	result) /* synthesis synthesis_clearbox=1 */;
	input   [7:0]  dataa;
	input   [7:0]  datab;
	output   [15:0]  result;

	wire signed	[7:0]    dataa_wire;
	wire signed	[7:0]    datab_wire;
	wire signed	[15:0]    result_wire;



	assign dataa_wire = dataa;
	assign datab_wire = datab;
	assign result_wire = dataa_wire * datab_wire;
	assign result = ({result_wire[15:0]});

endmodule //lpm_mult_core_mult
//VALID FILE


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module lpm_mult_core (
	dataa,
	datab,
	result)/* synthesis synthesis_clearbox = 1 */;

	input	[7:0]  dataa;
	input	[7:0]  datab;
	output	[15:0]  result;

	wire [15:0] sub_wire0;
	wire [15:0] result = sub_wire0[15:0];

	lpm_mult_core_mult	lpm_mult_core_mult_component (
				.dataa (dataa),
				.datab (datab),
				.result (sub_wire0));

endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: AutoSizeResult NUMERIC "0"
// Retrieval info: PRIVATE: B_isConstant NUMERIC "0"
// Retrieval info: PRIVATE: ConstantB NUMERIC "0"
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone V"
// Retrieval info: PRIVATE: LPM_PIPELINE NUMERIC "0"
// Retrieval info: PRIVATE: Latency NUMERIC "0"
// Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "1"
// Retrieval info: PRIVATE: SignedMult NUMERIC "1"
// Retrieval info: PRIVATE: USE_MULT NUMERIC "1"
// Retrieval info: PRIVATE: ValidConstant NUMERIC "0"
// Retrieval info: PRIVATE: WidthA NUMERIC "8"
// Retrieval info: PRIVATE: WidthB NUMERIC "8"
// Retrieval info: PRIVATE: WidthP NUMERIC "16"
// Retrieval info: PRIVATE: aclr NUMERIC "0"
// Retrieval info: PRIVATE: clken NUMERIC "0"
// Retrieval info: PRIVATE: new_diagram STRING "1"
// Retrieval info: PRIVATE: optimize NUMERIC "2"
// Retrieval info: LIBRARY: lpm lpm.lpm_components.all
// Retrieval info: CONSTANT: LPM_HINT STRING "DEDICATED_MULTIPLIER_CIRCUITRY=YES,MAXIMIZE_SPEED=1"
// Retrieval info: CONSTANT: LPM_REPRESENTATION STRING "SIGNED"
// Retrieval info: CONSTANT: LPM_TYPE STRING "LPM_MULT"
// Retrieval info: CONSTANT: LPM_WIDTHA NUMERIC "8"
// Retrieval info: CONSTANT: LPM_WIDTHB NUMERIC "8"
// Retrieval info: CONSTANT: LPM_WIDTHP NUMERIC "16"
// Retrieval info: USED_PORT: dataa 0 0 8 0 INPUT NODEFVAL "dataa[7..0]"
// Retrieval info: USED_PORT: datab 0 0 8 0 INPUT NODEFVAL "datab[7..0]"
// Retrieval info: USED_PORT: result 0 0 16 0 OUTPUT NODEFVAL "result[15..0]"
// Retrieval info: CONNECT: @dataa 0 0 8 0 dataa 0 0 8 0
// Retrieval info: CONNECT: @datab 0 0 8 0 datab 0 0 8 0
// Retrieval info: CONNECT: result 0 0 16 0 @result 0 0 16 0
// Retrieval info: GEN_FILE: TYPE_NORMAL lpm_mult_core.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL lpm_mult_core.inc TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL lpm_mult_core.cmp TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL lpm_mult_core.bsf TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL lpm_mult_core_inst.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL lpm_mult_core_bb.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL lpm_mult_core_syn.v TRUE
// Retrieval info: LIB_FILE: lpm
