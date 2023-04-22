module clk_divider #(
    parameter DIV_FACTOR = 24 //clock divides by 2^n, adjust n if necessary
) (
    input  logic fastclk, 
    output logic clk
);
  
logic [DIV_FACTOR-1:0] count;

always_ff @(posedge fastclk)
    count <= count + {{DIV_FACTOR-1{1'b0}}, 1'b1};

assign clk = count[DIV_FACTOR-1]; // slow clock

endmodule