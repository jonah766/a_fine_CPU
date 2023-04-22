module sfixed_mult_independent_9x9 #(
    parameter A_LEFT    = 3, 
    parameter A_RIGHT   = 4,
    parameter B_LEFT    = 3, 
    parameter B_RIGHT   = 4,
    parameter OUT_LEFT  = 7, 
    parameter OUT_RIGHT = 8
) (
    input  logic signed [(A_LEFT+A_RIGHT+1)-1:0]     a_x,   a_y,   a_z,
    input  logic signed [(B_LEFT+B_RIGHT+1)-1:0]     b_x,   b_y,   b_z,
    output logic signed [(OUT_LEFT+OUT_RIGHT+1)-1:0] out_x, out_y, out_z
);
`ifdef COCOTB_SIM
initial begin
    $dumpfile ("sfixed_mult_independent_9x9.vcd");
    $dumpvars (0, sfixed_mult_independent_9x9);
    #1;
end
`endif

localparam A_SIZE      = (A_LEFT+A_RIGHT+1);
localparam B_SIZE      = (B_LEFT+B_RIGHT+1);
localparam A_PAD       = 9 - A_SIZE;
localparam B_PAD       = 9 - B_SIZE;
localparam OUTPUT_SIZE = (A_LEFT+B_LEFT+1)+(A_RIGHT+B_RIGHT)+1; 
                                                                
logic signed [2:0][17:0] mult_out;

logic [8:0] op_a_x, op_b_x;
logic [8:0] op_a_y, op_b_y;
logic [8:0] op_a_z, op_b_z;

assign op_a_x = { {A_PAD{a_x[A_SIZE-1]}}, a_x };
assign op_a_y = { {A_PAD{a_y[A_SIZE-1]}}, a_y };
assign op_a_z = { {A_PAD{a_z[A_SIZE-1]}}, a_z };

assign op_b_x = { {B_PAD{b_x[B_SIZE-1]}}, b_x };
assign op_b_y = { {B_PAD{b_y[B_SIZE-1]}}, b_y };
assign op_b_z = { {B_PAD{b_z[B_SIZE-1]}}, b_z };


always_comb 
begin
    mult_out[0] = op_a_x * op_b_x;
    mult_out[1] = op_a_y * op_b_y;
    mult_out[2] = op_a_z * op_b_z;
end

assign out_x = mult_out[0][(A_RIGHT+B_RIGHT)+OUT_LEFT:(A_RIGHT+B_RIGHT)-OUT_RIGHT];
assign out_y = mult_out[1][(A_RIGHT+B_RIGHT)+OUT_LEFT:(A_RIGHT+B_RIGHT)-OUT_RIGHT]; //
assign out_z = mult_out[2][(A_RIGHT+B_RIGHT)+OUT_LEFT:(A_RIGHT+B_RIGHT)-OUT_RIGHT];

endmodule