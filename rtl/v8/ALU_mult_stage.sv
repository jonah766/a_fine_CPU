module ALU_mult_stage #(
    parameter BUS_WIDTH = 8
) (
    input  logic clk, f_clr,
    input  logic b_en, d_en,
    input  logic [BUS_WIDTH-1:0] data_a, data_b, imm,
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
logic [BUS_WIDTH-1:0] op_b_reg, op_d_reg;

always_ff @( posedge clk ) begin 
    if (b_en) begin
       if (f_clr)
          op_b_reg <= '0;
       else 
          op_b_reg <= imm;
    end   
end

always_ff @( posedge clk ) begin 
    if (d_en) begin
        if (f_clr)
          op_d_reg <= '0;
       else 
          op_d_reg <= imm;
    end
end

sfixed_mult #(
    7, 
    0,
    0, 
    7,
    7,
    0 
) m0 (
    .a  (data_a  ), // int
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
    .a  (data_b  ), // int
    .b  (op_d_reg), // tf
    .out(mult_b  )
);

    
endmodule
