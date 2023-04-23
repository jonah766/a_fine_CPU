module CPU #(
    parameter INSTR_WIDTH      = 16,
    parameter OPCODE_WIDTH     = 3,
    parameter INSTR_ADDR_WIDTH = 4, 
    parameter REG_ADDR_WIDTH   = 2, 
    parameter BUS_WIDTH        = 8
) (
    input  logic                 clk,  
    input  logic                 n_reset,
    input  logic [BUS_WIDTH-1:0] in_port,
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

logic [BUS_WIDTH-1:0] sw;
always_ff @(posedge clk)
    sw <= in_port;

assign pattern_match = (~ready_in_p & ready_in);

// -- instr counter
logic [INSTR_ADDR_WIDTH-1:0] PC_count;
logic PC_en, PC_comparator;

mux_21 #(
    1
) PC_en_mux (
    .s  (instr[1]     ), // differentiate between instr[1] == 1 (pattern) / 0 (rdy)
    .a  (pattern_match), // 1 -> pattern
    .b  (ready_in     ), // 0 -> ready in 
    .out(PC_comparator)
);

assign PC_en = ~(f_wait & (PC_comparator ^ instr[0]));

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
logic  we, wr_sw;
logic [REG_ADDR_WIDTH-1:0] wr_addr;
logic [BUS_WIDTH-1:0] rd_data_a, rd_data_b;
logic [BUS_WIDTH-1:0] wr_data;

always_ff @(posedge clk) 
begin
    wr_sw   <= f_load;
    we      <= f_wr_res;
    wr_addr <= instr[11:10];
end

mux_21 #(
    BUS_WIDTH
) wr_data_mux (
    .s  (wr_sw     ),
    .a  (sw        ),
    .b  (ALU_result),
    .out(wr_data   )
);

register_file #(
    BUS_WIDTH,
    4
) rf (
	.clk      (clk       ),  
    .we       (we        ),
 	.wr_addr  (wr_addr   ),
	.wr_data  (wr_data   ),
 	.rd_addr_a(instr[9:8]), 
    .rd_addr_b(instr[7:6]),
 	.rd_data_a(rd_data_a ), 
    .rd_data_b(rd_data_b )
);

// -- decoder
logic f_add, f_imm, f_load, f_wait, f_wr_res;
logic [4:0] reg_en; 

instruction_decoder #(
    OPCODE_WIDTH
) id (
    .opcode    (instr[14:12]),                  
    .f_add     (f_add       ), 
    .f_imm     (f_imm       ),
    .f_wait    (f_wait      ),            
    .f_load    (f_load      ),            
    .f_wr_res  (f_wr_res    )
);

// -- ALU
logic [BUS_WIDTH-1:0] ALU_result;
logic [BUS_WIDTH-1:0] ALU_immd;
logic                 ALU_add, ALU_imm;

always_ff @(posedge clk) begin
    ALU_immd   <= instr[7:0];
    ALU_imm    <= f_imm;
    ALU_add    <= f_add;
end

ALU #(
    BUS_WIDTH
) alu0 (
    .imm   (ALU_immd  ),
    .data_a(rd_data_a ),    
    .data_b(rd_data_b ),    
    .f_imm (ALU_imm   ),
    .f_add (ALU_add   ),
    .result(ALU_result) 
);  

assign out_port = ALU_result;

endmodule
