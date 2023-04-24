module adder (
    input  logic signed [7:0] a,b,
    output logic signed [7:0] result
);

(* keep *) lpm_add_sub a1 (
    .dataa  (a),
    .datab  (b),
    .result (result),
    .aclr   (),
    .add_sub(),
    .cin    (),
    .clken  (),
    .clock  (),
    .cout   (),
    .overflow()
);
	defparam
		a1.lpm_direction      = "ADD",
		a1.lpm_hint           = "ONE_INPUT_IS_CONSTANT=NO,CIN_USED=NO",
		a1.lpm_representation = "SIGNED",
		a1.lpm_type           = "LPM_ADD_SUB",
		a1.lpm_width          = 8;

//assign result = a + b;

endmodule
