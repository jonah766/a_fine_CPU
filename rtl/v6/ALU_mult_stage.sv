module ALU_mult_stage #(
    parameter BUS_WIDTH = 8
) (
    input  logic clk,
    input  logic a_en, b_en, c_en, d_en,
    input  logic [BUS_WIDTH-1:0] data_a, data_b, coeff,
    output logic [BUS_WIDTH-1:0] mult_a, mult_b
);
`ifdef COCOTB_SIM
initial begin
    $dumpfile ("ALU_mult_stage.vcd");
    $dumpvars (0, ALU_mult_stage);
    #1;
end
`endif

// input registers
logic [BUS_WIDTH-1:0] op_a_reg, op_b_reg, op_c_reg, op_d_reg;

always_ff @( posedge clk ) begin 
    if (a_en) 
        op_a_reg <= data_a;
end

always_ff @( posedge clk ) begin 
    if (b_en) 
        op_b_reg <= coeff;
end

always_ff @( posedge clk ) begin 
    if (c_en) begin
        op_c_reg <= data_b;
    end
end

always_ff @( posedge clk ) begin 
    if (d_en)
        op_d_reg <= coeff;
end

(* keep *) sfixed_mult_9x9_x3 #(
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
    
endmodule
