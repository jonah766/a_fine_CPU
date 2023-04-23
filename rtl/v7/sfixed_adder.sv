import datatypes::max;

module sfixed_adder #(
    parameter A_LEFT    = 3, 
    parameter A_RIGHT   = 4, 
    parameter B_LEFT    = 3, 
    parameter B_RIGHT   = 4,
    parameter OUT_LEFT  = 4, 
    parameter OUT_RIGHT = 4
) (   
    input  logic signed [(A_LEFT+A_RIGHT+1)-1:0]     a,
    input  logic signed [(B_LEFT+B_RIGHT+1)-1:0]     b,
    output logic signed [(OUT_LEFT+OUT_RIGHT+1)-1:0] out
);

`ifdef COCOTB_SIM
initial begin
    $dumpfile ("sfixed_adder.vcd");
    $dumpvars (0, sfixed_adder);
    #1;
end
`endif

localparam OUTPUT_SIZE = (max(A_LEFT,B_LEFT)+1)+max(A_RIGHT,B_RIGHT)+1; 

logic signed [OUTPUT_SIZE-1:0] add_out;

always_comb
    add_out = a + b;

assign out = add_out[max(A_RIGHT,B_RIGHT)+OUT_LEFT:max(A_RIGHT,B_RIGHT)-OUT_RIGHT];

endmodule
