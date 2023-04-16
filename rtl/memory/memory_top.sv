module memory_top #(
    parameter INSTR_WIDTH      = 12,
    parameter OPCODE_WIDTH     = 3,
    parameter INSTR_ADDR_WIDTH = 4, 
    parameter REG_ADDR_WIDTH   = 3, 
    parameter BUS_WIDTH        = 8
) (
    input  logic                 clk,  
    input  logic                 n_reset,
    input  logic [BUS_WIDTH-1:0] sw,
    input  logic                 ready_in,
    output logic [BUS_WIDTH-1:0] out_port
);       

//the macro to dump signals   
`ifdef COCOTB_SIM
initial begin
    $dumpfile ("CPU.vcd");
    $dumpvars (0, CPU);
    #1;
end
`endif

// PC
logic[INSTR_ADDR_WIDTH-1:0] PC_count;
program_counter #(
   INSTR_ADDR_WIDTH
) pc (
   .clk    (clk     ),
   .n_reset(n_reset ),
   .en     ('1   ),
   .count  (PC_count)
);

// -- prog rom
logic [INSTR_WIDTH-1:0] instr;

program_memory #(
    INSTR_ADDR_WIDTH,
    INSTR_WIDTH
) pm (
    .addr (PC_count),
    .instr(instr   )
);

// -- reg file
logic [BUS_WIDTH-1:0] rd_data_a, rd_data_b;

register_file #(
    BUS_WIDTH,
    REG_ADDR_WIDTH
) rf (
	.clk          (clk       ),  
	.sw           (sw        ),
    .ready_in     (ready_in  ),
	.pattern_match('1        ),
    .we           ('1        ),
 	.wr_addr      (PC_count[REG_ADDR_WIDTH-1:0]),
	.wr_data      ({BUS_WIDTH{PC_count[0]}}),
 	.rd_addr_a    (instr[5:3]), 
    .rd_addr_b    (instr[2:0]),
 	.rd_data_a    (rd_data_a ), 
    .rd_data_b    (rd_data_b ),
    .out_port     (out_port  )
);

endmodule
