module input_regs #(
    parameter BUS_WIDTH = 8
) (
    input  logic                      clk, n_reset,
    input  logic [4:0]                reg_en,
    input  logic [4:0][BUS_WIDTH-1:0] ops,
    output logic [4:0][BUS_WIDTH-1:0] ops_reg
);

// enable registered inputs
always_ff @(posedge clk) 
begin
    if (~n_reset) 
        ops_reg <= '0;
    else begin
        for (int i = 0; i < 5; i=i+1) begin
            if (reg_en[i] == 1'b1)
                ops_reg[i] <= ops[i];
        end
    end
end

endmodule
