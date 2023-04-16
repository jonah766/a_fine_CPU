module ALU #(
    parameter BUS_WIDTH  = 8
) (
    input  logic                      clk, n_reset,
    input  logic [4:0][BUS_WIDTH-1:0] ops,    
    input  logic [4:0]                reg_en,
    input  logic                      f_add,
    output logic [BUS_WIDTH-1:0]      result 
);       

logic [4:0][BUS_WIDTH-1:0] ops_reg;

input_regs #(
    BUS_WIDTH
) regs (
    .clk(clk),
    .n_reset(n_reset),
    .reg_en(reg_en),
    .ops(ops),
    .ops_reg(ops_reg)
);

// setting up of add/subtract inputs
logic [4:0][BUS_WIDTH-1:0] ops_in;

mux_21 #(
    BUS_WIDTH
) b_mux (   
    .s(f_add), 
    .a({1'b1, {BUS_WIDTH-1{1'b0}}}), 
    .b(ops_reg[1]),
    .out(ops_in[1])
);

mux_21 #(
    BUS_WIDTH
) d_mux (   
    .s(f_add), 
    .a({1'b1, {BUS_WIDTH-1{1'b0}}}), 
    .b(ops_reg[3]),
    .out(ops_in[3])
);

mux_21 #(
    BUS_WIDTH
) e_mux (   
    .s(f_add), 
    .a({BUS_WIDTH{1'b0}}), 
    .b(ops_reg[4]),
    .out(ops_in[4])
);

assign ops_in[0] = ops_reg[0];
assign ops_in[2] = ops_reg[2];

// the computational part
logic[BUS_WIDTH-1:0] mult_a, mult_b, add_a, add_b;
sfixed_mult #(
    7, 
    0,
    0, 
    7,
    7, 
    0
) m0 (
    .a(ops_in[0]), // int
    .b(ops_in[1]), // tf
    .out(mult_a)
);

sfixed_mult #(
    7, 
    0,
    0, 
    7,
    7, 
    0
) m1 (
    .a(ops_in[2]),  // int
    .b(ops_in[3]),  // tf
    .out(mult_b)
);

sfixed_adder #(
    7, 
    0, 
    7, 
    0,
    7, 
    0 
) a0 (   
    .a(mult_a), // int
    .b(mult_b), // int
    .out(add_a)
);

sfixed_adder #(
    7, 
    0, 
    7, 
    0,
    7, 
    0
) a1 (   
    .a(add_a),      // int
    .b(ops_in[4]),  // int
    .out(add_b)
);

mux_21 #(
    BUS_WIDTH
) out_mux (   
    .s(f_add), 
    .a(~add_b + 1'b1), 
    .b(add_b),
    .out(result)
);

endmodule 


