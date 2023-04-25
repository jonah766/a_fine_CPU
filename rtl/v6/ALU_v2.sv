module ALU_v2 #(
    parameter BUS_WIDTH  = 8
) (
    input  logic                 clk, 
    input  logic [BUS_WIDTH-1:0] sw,
    input  logic [BUS_WIDTH-1:0] imm,
    input  logic [BUS_WIDTH-1:0] data_a,    
    input  logic [BUS_WIDTH-1:0] data_b,    
    input  logic [4:0]           reg_en,
    input  logic                 f_add,
    input  logic                 f_load,
    output logic [BUS_WIDTH-1:0] result 
);       

// setting up of add/subtract inputs
logic [BUS_WIDTH-1:0] op_e, e_add, coeff;
logic [BUS_WIDTH-1:0] op_e_reg;


mux_21 #(
    BUS_WIDTH
) e_add_mux (   
    .s  (f_load), 
    .a  (sw    ), 
    .b  (data_a),
    .out(e_add )
);

mux_21 #(
    BUS_WIDTH
) op_e_mux (   
    .s  (f_add), 
    .a  (e_add), 
    .b  (imm  ),
    .out(op_e )
);

mux_21 #(
    BUS_WIDTH
) coeff_mux (   
    .s  (f_add              ), 
    .a  ({BUS_WIDTH-1{1'b0}}), 
    .b  (imm                ),
    .out(coeff               )
);


// input registers
always_ff @( posedge clk ) begin
    if (reg_en[4])
        op_e_reg <= op_e;
end

// the computational part
logic [BUS_WIDTH-1:0] mult_a, mult_b, add_a;

ALU_mult_stage #(
    BUS_WIDTH
) am1 (
    .clk   (clk),
    .a_en  (reg_en[0]), 
    .b_en  (reg_en[1]), 
    .c_en  (reg_en[2]), 
    .d_en  (reg_en[3]),
    .data_a(data_a),
    .data_b(data_b),
    .coeff  (coeff  ),
    .mult_a(mult_a),
    .mult_b(mult_b)
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


