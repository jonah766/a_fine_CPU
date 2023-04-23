module sfixed_mult_9x9_x3 #(
    parameter A_LEFT    = 3, 
    parameter A_RIGHT   = 4,
    parameter B_LEFT    = 3, 
    parameter B_RIGHT   = 4,
    parameter OUT_LEFT  = 7, 
    parameter OUT_RIGHT = 8
) (
    input  logic signed [(A_LEFT+A_RIGHT+1)-1:0]     a_x,   a_y, //   a_z,
    input  logic signed [(B_LEFT+B_RIGHT+1)-1:0]     b_x,   b_y, //   b_z,
    output logic signed [(OUT_LEFT+OUT_RIGHT+1)-1:0] out_x, out_y//, out_z
);
`ifdef COCOTB_SIM
initial begin
    $dumpfile ("sfixed_mult_9x9_x3.vcd");
    $dumpvars (0, sfixed_mult_9x9_x3);
    #1;
end
`endif

localparam A_SIZE      = (A_LEFT+A_RIGHT+1);
localparam B_SIZE      = (B_LEFT+B_RIGHT+1);
localparam OUTPUT_SIZE = (A_LEFT+B_LEFT+1)+(A_RIGHT+B_RIGHT)+1; 

logic [OUTPUT_SIZE-1:0] result_a, result_b;

lpm_mult m0 (
    .dataa (a_x     ),
    .datab (b_x     ),
    .result(result_a),
    .aclr  (1'b0    ),
    .clken (1'b1    ),
    .clock (1'b0    ),
    .sclr  (1'b0    ),
    .sum   (1'b0    )
);
	defparam
		m0.lpm_hint           = "DEDICATED_MULTIPLIER_CIRCUITRY=YES,MAXIMIZE_SPEED=0",
		m0.lpm_representation = "SIGNED",
		m0.lpm_type           = "LPM_MULT",
		m0.lpm_widtha         = 8,
		m0.lpm_widthb         = 8,
		m0.lpm_widthp         = 16;

lpm_mult m1 (
    .dataa (a_y     ),
    .datab (b_y     ),
    .result(result_b),
    .aclr  (1'b0    ),
    .clken (1'b1    ),
    .clock (1'b0    ),
    .sclr  (1'b0    ),
    .sum   (1'b0    )
);
	defparam
		m1.lpm_hint           = "DEDICATED_MULTIPLIER_CIRCUITRY=YES,MAXIMIZE_SPEED=0",
		m1.lpm_representation = "SIGNED",
		m1.lpm_type           = "LPM_MULT",
		m1.lpm_widtha         = 8,
		m1.lpm_widthb         = 8,
		m1.lpm_widthp         = 16;

assign out_x = result_a[(A_RIGHT+B_RIGHT)+OUT_LEFT:(A_RIGHT+B_RIGHT)-OUT_RIGHT];
assign out_y = result_b[(A_RIGHT+B_RIGHT)+OUT_LEFT:(A_RIGHT+B_RIGHT)-OUT_RIGHT]; 
    
endmodule