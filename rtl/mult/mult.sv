module mult (
    input  logic       clk,
    input  logic [7:0] a, c, b, d,
    output logic [7:0] result
);

logic [15:0] result_a, result_b, result_c;

lpm_mult m0 (
    .dataa (a       ),
    .datab (b       ),
    .result(result_a),
    .aclr  (1'b0     ),
    .clken (1'b1     ),
    .clock (1'b0     ),
    .sclr  (1'b0     ),
    .sum   (1'b0     )
);
	defparam
		m0.lpm_hint           = "DEDICATED_MULTIPLIER_CIRCUITRY=YES,MAXIMIZE_SPEED=0",
		m0.lpm_representation = "SIGNED",
		m0.lpm_type           = "LPM_MULT",
		m0.lpm_widtha         = 8,
		m0.lpm_widthb         = 8,
		m0.lpm_widthp         = 16;

lpm_mult m1 (
    .dataa (c       ),
    .datab (d       ),
    .result(result_b),
    .aclr  (1'b0     ),
    .clken (1'b1     ),
    .clock (1'b0     ),
    .sclr  (1'b0     ),
    .sum   (1'b0     )
);
	defparam
		m1.lpm_hint           = "DEDICATED_MULTIPLIER_CIRCUITRY=YES,MAXIMIZE_SPEED=0",
		m1.lpm_representation = "SIGNED",
		m1.lpm_type           = "LPM_MULT",
		m1.lpm_widtha         = 8,
		m1.lpm_widthb         = 8,
		m1.lpm_widthp         = 16;

lpm_mult m2 (
    .dataa (a       ),
    .datab (c       ),
    .result(result_c),
    .aclr  (1'b0     ),
    .clken (1'b1     ),
    .clock (1'b0     ),
    .sclr  (1'b0     ),
    .sum   (1'b0     )
);
	defparam
		m2.lpm_hint           = "DEDICATED_MULTIPLIER_CIRCUITRY=YES,MAXIMIZE_SPEED=0",
		m2.lpm_representation = "SIGNED",
		m2.lpm_type           = "LPM_MULT",
		m2.lpm_widtha         = 8,
		m2.lpm_widthb         = 8,
		m2.lpm_widthp         = 16;


assign result = {result_a[2:0], result_b[2:0], result_c[1:0]};

//lpm_add_sub	a1 (
//    .dataa   ({result_a[14:11], result_c[14:11]}),
//    .datab   (result_b[14:7]),
//    .result  (result        ),
//    .aclr    (              ),
//    .add_sub (              ),
//    .cin     (              ),
//    .clken   (              ),
//    .clock   (              ),
//    .cout    (              ),
//    .overflow(              )
//);
//	defparam
//		a1.lpm_direction      = "ADD",
//		a1.lpm_hint           = "ONE_INPUT_IS_CONSTANT=NO,CIN_USED=NO",
//		a1.lpm_representation = "SIGNED",
//		a1.lpm_type           = "LPM_ADD_SUB",
//		a1.lpm_width          = 8;

endmodule