module mux_21 #(
    parameter BIT_WIDTH = 8
) (   
    input  logic s, 
    input  logic [BIT_WIDTH-1:0] a, b,
    output logic [BIT_WIDTH-1:0] out
);
    `ifdef COCOTB_SIM
    initial begin
        $dumpfile ("mux_21.vcd");
        $dumpvars (0, mux_21);
        #1;
    end
    `endif 
    assign out = s ? a : b;
endmodule