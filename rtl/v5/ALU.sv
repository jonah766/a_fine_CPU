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

always_ff @( posedge clk ) begin 
    if (reg_en[0]) begin
        op_a_reg <= ops[0];
    end
end

always_ff @( posedge clk ) begin 
    if (reg_en[1]) begin
        if (f_add)
            op_b_reg <= '0;
        else 
            op_b_reg <= ops[1];
    end
end

always_ff @( posedge clk ) begin 
    if (reg_en[2]) begin
        op_c_reg <= ops[2];
    end
end

always_ff @( posedge clk ) begin 
    if (reg_en[3]) begin
        if (f_add)
            op_d_reg <= '0;
        else 
            op_d_reg <= ops[3];
    end
end

always_ff @(posedge clk)  
begin
    if (reg_en[4])
        op_e_reg <= op_e;
end

// the computational part
logic[BUS_WIDTH-1:0] mult_a, mult_b, add_a;

sfixed_mult_independent_9x9 #(
    7, 
    0,
    0, 
    7,
    7,
    0 
) m0 (
    .a_x  (op_a_reg), 
    .a_y  (op_c_reg),
    .a_z  ('0      ),
    .b_x  (op_b_reg), 
    .b_y  (op_d_reg),
    .b_z  ('0      ),
    .out_x(mult_a  ), 
    .out_y(mult_b  ),
    .out_z() // unconnected
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


