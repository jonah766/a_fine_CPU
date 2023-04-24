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

logic signed [OUTPUT_SIZE-1:0] result_a, result_b;
		
always_comb 
begin   
    result_a = a_x * b_x;
    result_b = a_y * b_y;
end

assign out_x = result_a[(A_RIGHT+B_RIGHT)+OUT_LEFT:(A_RIGHT+B_RIGHT)-OUT_RIGHT];
assign out_y = result_b[(A_RIGHT+B_RIGHT)+OUT_LEFT:(A_RIGHT+B_RIGHT)-OUT_RIGHT]; 
    
endmodule
