
//clock divides by 2^DIV_FACTOR, adjust DIV_FACTOR
module Clock_Divider #(
    parameter int DIV_FACTOR = 24
) (
    input logic fast_clk, 
    output logic clk
);
  
logic [DIV_FACTOR-1:0] count;

always_ff @(posedge fast_clk)
begin
    if (count == (1<<DIV_FACTOR) - 1)
        count <= '0;
    else
        count <= count + 1;
end

assign clk = count[DIV_FACTOR-1]; // slow clock

endmodule