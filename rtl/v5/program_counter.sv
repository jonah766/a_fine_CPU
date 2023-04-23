module program_counter #(
    parameter ADDR_WIDTH = 3
) (
    input  logic                  clk, n_reset,
    input  logic                  en,
    output logic [ADDR_WIDTH-1:0] count
);
 
always_ff @(posedge clk, negedge n_reset) 
begin   
    if (~n_reset) 
        count <= '0;
    else begin
        if (en)
            count <= count + { {ADDR_WIDTH-1{1'b0}}, 1'b1 };
    end
end

endmodule