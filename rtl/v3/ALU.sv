module ALU #(
    parameter BUS_WIDTH  = 8
) (
    input  logic                      clk, 
    input  logic [4:0][BUS_WIDTH-1:0] ops,    
    input  logic [4:0]                reg_en,
    input  logic                      f_add,
    output logic [BUS_WIDTH-1:0]      result 
);       

// setting up of add/subtract inputs
logic [BUS_WIDTH-1:0] op_e;
logic [BUS_WIDTH-1:0] op_a_reg, op_b_reg, op_c_reg, op_d_reg, op_e_reg;

mux_21 #(
    BUS_WIDTH
) e_mux (   
    .s  (f_add ), 
    .a  (ops[0]), 
    .b  (ops[4]),
    .out(op_e  )
);

// input registers
ALU_regs #(
    BUS_WIDTH
) alur0 (
    .clk(clk),
    .f_add(f_add),
    .ops(ops),  
    .op_e(op_e),  
    .reg_en(reg_en),
    .op_a_reg(op_a_reg), 
    .op_b_reg(op_b_reg), 
    .op_c_reg(op_c_reg), 
    .op_d_reg(op_d_reg), 
    .op_e_reg(op_e_reg)
);

//assign op_a_reg = ops[0];
//assign op_b_reg = ops[1];
//assign op_c_reg = ops[2];
//assign op_d_reg = ops[3];

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
    .a  (op_a_reg), // int
    .b  (op_b_reg), // tf
    .out(mult_a  )
);

sfixed_mult #(
    7, 
    0,
    0, 
    7,
    7, 
    0
) m1 (
    .a  (op_c_reg), // int
    .b  (op_d_reg), // tf
    .out(mult_b  )
);

sfixed_adder #(
    7, 
    0, 
    7, 
    0,
    7, 
    0 
) a0 (   
    .a  (mult_a), // int
    .b  (mult_b), // int
    .out(add_a )
);

sfixed_adder #(
    7, 
    0, 
    7, 
    0,
    7, 
    0
) a1 (   
    .a  (add_a   ), // int
    .b  (op_e_reg), // int
    .out(result  )
);

endmodule 


