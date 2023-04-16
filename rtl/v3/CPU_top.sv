module CPU_top (
    input  logic       fastclk,
    input  logic       n_reset,
    input  logic       ReadyIn,
    input  logic [7:0] sw,
    output logic [7:0] led
);

logic clk;

clk_divider #(
    25 //divide 50MHz clk by 2^25 \approx 1s period
) cd0 (
    .fastclk(fastclk),
    .clk    (clk    )
);

CPU cpu0 (
    .clk     (clk    ),
    .n_reset (n_reset),
    .ready_in(ReadyIn),
    .in_port (sw     ),
    .out_port(led    )
);

endmodule