module sfixed_mult #(
    parameter A_LEFT    = 3, 
    parameter A_RIGHT   = 4,
    parameter B_LEFT    = 3, 
    parameter B_RIGHT   = 4,
    parameter OUT_LEFT  = 7, 
    parameter OUT_RIGHT = 8
) (
    input  logic signed [(A_LEFT+A_RIGHT+1)-1:0]     a,
    input  logic signed [(B_LEFT+B_RIGHT+1)-1:0]     b,
    output logic signed [(OUT_LEFT+OUT_RIGHT+1)-1:0] out
);
`ifdef COCOTB_SIM
initial begin
    $dumpfile ("sfixed_mult.vcd");
    $dumpvars (0, sfixed_mult);
    #1;
end
`endif

localparam OUTPUT_SIZE = (A_LEFT+B_LEFT+1)+(A_RIGHT+B_RIGHT)+1; 
                                                                
logic signed [OUTPUT_SIZE-1:0] mult_out;

always_comb
    mult_out = a * b;

assign out = mult_out[(A_RIGHT+B_RIGHT)+OUT_LEFT:(A_RIGHT+B_RIGHT)-OUT_RIGHT];

endmodule