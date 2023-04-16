module CPU #(
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

// input switch handshaking
logic ready_in_p, pattern_match;
always_ff @(posedge clk)
    ready_in_p <= ready_in;

logic [BUS_WIDTH-1:0] sw_p;
always_ff @(posedge clk)
    sw_p <= sw;

assign pattern_match = ({ready_in_p, ready_in} == 2'b01);

// -- instr counter
logic [INSTR_ADDR_WIDTH-1:0] PC_count;
logic PC_en;
assign PC_en = (PC_wait & ~(rd_data_a[0] ^ instr[0])) | ~PC_wait;

program_counter #(
   INSTR_ADDR_WIDTH
) pc (
   .clk    (clk     ),
   .n_reset(n_reset ),
   .en     (PC_en   ),
   .count  (PC_count)
);

// -- program ROM
logic [INSTR_WIDTH-1:0] instr;

program_memory #(
    INSTR_ADDR_WIDTH,
    INSTR_WIDTH
) pm (
    .addr (PC_count),
    .instr(instr   )
);

// -- reg file
logic wr_res, we;
logic [REG_ADDR_WIDTH-1:0] wr_addr;
logic [BUS_WIDTH-1:0] rd_data_a, rd_data_b;

always_ff @(posedge clk) 
begin
    we      <= wr_res;
    wr_addr <= instr[8:6];
end

register_file #(
    BUS_WIDTH,
    REG_ADDR_WIDTH
) rf (
	.clk          (clk          ),  
	.sw           (sw_p         ),
    .ready_in     (ready_in     ),
	.pattern_match(pattern_match),
    .we           (we           ),
 	.wr_addr      (wr_addr      ),
	.wr_data      (ALU_result   ),
 	.rd_addr_a    (instr[5:3]   ), 
    .rd_addr_b    (instr[2:0]   ),
 	.rd_data_a    (rd_data_a    ), 
    .rd_data_b    (rd_data_b    ),
    .out_port     (out_port     )
);

// -- decoder
logic ALU_add, PC_wait;

instruction_decoder #(
    OPCODE_WIDTH
) id (
    .opcode    (instr[11:9]),                  
    .f_add     (ALU_add    ), 
    .f_wait    (PC_wait    ),            
    .wr_res    (wr_res     ),         
    .ALU_reg_en(ALU_reg_en )
);

// -- ALU
logic [BUS_WIDTH-1:0] ALU_result;
logic [4:0] ALU_reg_en; 

ALU #(
    BUS_WIDTH
) alu (
    .clk    (clk                                                   ),
    .ops    ({instr[7:0],instr[7:0],rd_data_b,instr[7:0],rd_data_a}),   
    .reg_en (ALU_reg_en                                            ),
    .f_add  (ALU_add                                               ),
    .result (ALU_result                                            )
);    

endmodule
