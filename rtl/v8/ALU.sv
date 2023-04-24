module ALU #(
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
logic [BUS_WIDTH-1:0] op_a_reg, op_b_reg, op_c_reg, op_d_reg, op_e_reg;

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
    .out(coeff              )
);


// input registers
always_ff @( posedge clk ) begin 
    if (reg_en[0]) 
        op_a_reg <= data_a;
end

always_ff @( posedge clk ) begin 
    if (reg_en[1]) 
        op_b_reg <= coeff;
end

always_ff @( posedge clk ) begin 
    if (reg_en[2]) begin
        op_c_reg <= data_b;
    end
end

always_ff @( posedge clk ) begin 
    if (reg_en[3])
        op_d_reg <= coeff;
end

always_ff @( posedge clk ) begin
    if (reg_en[4])
        op_e_reg <= op_e;
end

// the computational part
logic [BUS_WIDTH-1:0] mult_a, mult_b, add_a;

sfixed_mult_9x9_x3 #(
    7, 
    0,
    0, 
    7,
    7, 
    0
) m0 (
    .a_x  (op_a_reg),
    .a_y  (op_c_reg), 
    .b_x  (op_b_reg),
    .b_y  (op_d_reg), 
    .out_x(mult_a  ),
    .out_y(mult_b  )
);

(* keep *) sfixed_adder #(
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

(* keep *) sfixed_adder #(
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


