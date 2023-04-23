module ALU #(
    parameter BUS_WIDTH  = 8
) (
    input  logic [BUS_WIDTH-1:0] imm,
    input  logic [BUS_WIDTH-1:0] data_a,    
    input  logic [BUS_WIDTH-1:0] data_b,    
    input  logic                 f_imm,
    input  logic                 f_add,
    output logic [BUS_WIDTH-1:0] result 
);       

// setting up of add/subtract inputs
logic [BUS_WIDTH-1:0] op_e, e_add, coeff;
logic [BUS_WIDTH-1:0] op_a_reg, op_b_reg, op_c_reg, op_d_reg, op_e_reg;
logic [BUS_WIDTH-1:0] b_mux_out;

mux_21 #(
    BUS_WIDTH
) b_mux (   
    .s  (f_imm    ), 
    .a  (imm      ), 
    .b  (data_b   ),
    .out(b_mux_out)
);

// the computational part
logic [BUS_WIDTH-1:0] mult_out, add_out;

sfixed_mult #(
    7, 
    0,
    0, 
    7,
    7,
    0 
) m0 (
    .a  (data_a   ), // int
    .b  (b_mux_out), // tf
    .out(mult_out )
);

sfixed_adder #(
    7, 
    0, 
    7, 
    0,
    7, 
    0
) a0 ( 
    .a  (data_a   ), // int
    .b  (b_mux_out), // int
    .out(add_out  )
);

mux_21 #(
    BUS_WIDTH
) output_mux (   
    .s  (f_add   ), 
    .a  (add_out ), 
    .b  (mult_out),
    .out(result  )
);

endmodule 


