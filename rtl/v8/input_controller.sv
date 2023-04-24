module input_controller #(
    parameter BUS_WIDTH = 8
) (
    input  logic clk,
    input  logic ready_in,
    input  logic f_wait,
    input  logic wait_selector,
    input  logic wait_value,
    output logic pattern_match,
    output logic PC_en
);

// input switch handshaking
logic ready_in_p;
always_ff @(posedge clk)
    ready_in_p <= ready_in;

assign pattern_match = (~ready_in_p & ready_in);

logic PC_comparator;

mux_21 #(
    1
) PC_en_mux (
    .s  (wait_selector ), //instr[3]
    .a  (pattern_match ), 
    .b  (ready_in      ), 
    .out(PC_comparator )
);

assign PC_en = ~(f_wait & (PC_comparator ^ wait_value)); //instr[0]

endmodule