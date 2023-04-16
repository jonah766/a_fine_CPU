module sfixed_mult_reg_input #(
    parameter A_LEFT    = 3, 
    parameter A_RIGHT   = 4,
    parameter B_LEFT    = 3, 
    parameter B_RIGHT   = 4,
    parameter OUT_LEFT  = 7, 
    parameter OUT_RIGHT = 8
) (
    input  logic                                     clk, 
    input  logic signed [(A_LEFT+A_RIGHT+1)-1:0]     a,
    input  logic                                     en_a, clr_a,
    input  logic signed [(B_LEFT+B_RIGHT+1)-1:0]     b,
    input  logic                                     en_b, clr_b,
    output logic signed [(OUT_LEFT+OUT_RIGHT+1)-1:0] out
);
`ifdef COCOTB_SIM
initial begin
    $dumpfile ("sfixed_mult_reg_input.vcd");
    $dumpvars (0, sfixed_mult_reg_input);
    #1;
end
`endif

localparam A_SIZE      = A_LEFT+A_RIGHT+1;
localparam B_SIZE      = B_LEFT+B_RIGHT+1;
localparam OUTPUT_SIZE = (A_LEFT+B_LEFT+1)+(A_RIGHT+B_RIGHT)+1; 
                                                                
logic signed [A_SIZE-1:0]      a_reg;                           
logic signed [B_SIZE-1:0]      b_reg;
logic signed [OUTPUT_SIZE-1:0] mult_out;

always_ff @( posedge clk ) begin 
    if (en_a) begin
        if (clr_a)
            a_reg <= '0;
        else 
            a_reg <= a;
    end
end

always_ff @( posedge clk ) begin 
    if (en_b) begin
        if (clr_b)
            b_reg <= '0;
        else 
            b_reg <= b;
    end
end

always_comb
    mult_out = a_reg * b_reg;

assign out = mult_out[(A_RIGHT+B_RIGHT)+OUT_LEFT:(A_RIGHT+B_RIGHT)-OUT_RIGHT];

endmodule