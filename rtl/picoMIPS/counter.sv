// counter for slow clock
module counter #(parameter n = 24) //clock divides by 2^n, adjust n if necessary
  (input logic fastclk, output logic clk);
  
logic [n-1:0] count;

always_ff @(posedge fastclk)
    if (count == (1<<n)-1)
        count <= '0;
    else
        count <= count + 1;

assign clk = count[n-1]; // slow clock

endmodule