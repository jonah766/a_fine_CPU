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
logic [BUS_WIDTH-1:0] op_e, e_add;
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
    .s  (f_add), 
    .a  ('0   ), 
    .b  (imm  ),
    .out(coeff)
);

mux_21 #(
    BUS_WIDTH
) op_d_mux (   
    .s  (f_add), 
    .a  (e_add), 
    .b  (imm  ),
    .out(op_e )
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

always_ff @(posedge clk)  
begin
    if (reg_en[4])
        op_e_reg <= op_e;
end



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


