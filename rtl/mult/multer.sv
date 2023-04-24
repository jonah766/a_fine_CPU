module multer (
    input  logic clk,
    input  logic [3:0] en,
    input  logic signed [7:0] a,b,c,d,
    output logic signed [15:0] result_a, result_b
);

logic signed [7:0] a_reg,b_reg,c_reg,d_reg;

always_ff @(posedge clk)
begin
    if (en[0])
        a_reg <= a;
    if (en[1])
        c_reg <= c;
end

lpm_mult m0 (
    .dataa (a_reg   ),
    .datab (b   ),
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
    .dataa (c_reg   ),
    .datab (d   ),
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

endmodule
