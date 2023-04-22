module ALU_regs #(
    parameter BUS_WIDTH = 8
) (
    input  logic                      clk,
    input  logic                      f_add,
    input  logic [4:0][BUS_WIDTH-1:0] ops,  
    input  logic [BUS_WIDTH-1:0]      op_e,  
    input  logic [4:0]                reg_en,
    output logic [BUS_WIDTH-1:0]      op_a_reg, 
    output logic [BUS_WIDTH-1:0]      op_b_reg, 
    output logic [BUS_WIDTH-1:0]      op_c_reg, 
    output logic [BUS_WIDTH-1:0]      op_d_reg, 
    output logic [BUS_WIDTH-1:0]      op_e_reg
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

endmodule