module CPU_top (
    input  logic       fastclk,
    input  logic       n_reset,
    input  logic       ready_in,
    input  logic [7:0] sw,
    output logic [7:0] led,
    output logic [6:0] ss_0
);

logic clk;

clk_divider #(
    25 //divide 50MHz clk by 2^25 \approx 1s period
) cd0 (
    .fastclk(fastclk),
    .clk    (clk    )
);

CPU cpu0 (
    .clk     (clk     ),
    .n_reset (n_reset ),
    .ready_in(ready_in),
    .in_port (sw      ),
    .out_port(led     ),
    .prog_cnt(prog_cnt)
);

logic [3:0] prog_cnt;

seven_seg_decoder ssd0 (
    .address(prog_cnt),
    .data   (ss_0    ),
);

endmodule
