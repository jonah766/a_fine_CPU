module mult (
    input  logic clk,
    input  logic signed [7:0] a, b, c, d,
    input  logic [3:0]  en,
    output logic signed [7:0] result
);

logic signed [15:0] result_a, result_b;

(* keep *) multer multer0(
    .clk(clk),
    .en(en),
    .a(a),
    .b(b),
    .c(c),
    .d(d),
    .result_a(result_a),
    .result_b(result_b)
);

(* keep *) adder adder0(
    .a(result_a[7:0]),
    .b(result_b[7:0]),
    .result(result)
);

endmodule
