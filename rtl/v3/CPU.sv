module CPU #(
    parameter INSTR_WIDTH      = 12,
    parameter OPCODE_WIDTH     = 3,
    parameter INSTR_ADDR_WIDTH = 4, 
    parameter REG_ADDR_WIDTH   = 2, 
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

logic [BUS_WIDTH-1:0] sw_p, sw_pp;
always_ff @(posedge clk)
begin
    sw_p  <= sw;
    sw_pp <= sw_p;
end

assign pattern_match = ({ready_in_p, ready_in} == 2'b01);

// -- instr counter
logic [INSTR_ADDR_WIDTH-1:0] PC_count;
logic PC_en, PC_comparator;

mux_21 #(
    1
) PC_en_mux (
    .s  (instr[3]     ), // differentiate between instr[5:3] == 001 (pattern) / 000 (rdy)
    .a  (pattern_match), // 001 -> pattern
    .b  (ready_in     ), // 000 -> ready in 
    .out(PC_comparator)
);

assign PC_en = (PC_wait & ~(PC_comparator ^ instr[0])) | ~PC_wait;

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
logic wr_res, we, we_p;
logic [REG_ADDR_WIDTH-1:0] wr_addr, wr_addr_p;
logic [BUS_WIDTH-1:0] data_a, data_b;
logic [BUS_WIDTH-1:0] rd_data_a, rd_data_b;

always_ff @(posedge clk) 
begin
    we        <= wr_res;
    we_p      <= we;
    wr_addr   <= instr[8:6];
    wr_addr_p <= wr_addr;
end

register_file #(
    BUS_WIDTH,
    REG_ADDR_WIDTH
) rf (
	.clk          (clk       ),  
    .we           (we_p      ),
 	.wr_addr      (wr_addr_p ),
	.wr_data      (ALU_result),
 	.rd_addr_a    (instr[4:3]), 
    .rd_addr_b    (instr[1:0]),
 	.rd_data_a    (data_a    ), 
    .rd_data_b    (data_b    )
);

logic [REG_ADDR_WIDTH-1:0] addr_a_p, addr_b_p;
logic pattern_match_p;
always_ff @(posedge clk)
begin
    addr_a_p <= instr[4:3];
    addr_b_p <= instr[1:0];
end 

// multiplex the rd_data_a output based on the asked for addr
always_comb
begin
	if(addr_a_p == 0)
		rd_data_a = sw_pp;
	else 
        rd_data_a = data_a;
end

// multiplex the rd_data_b output based on the asked for addr
always_comb
begin
	if (addr_b_p == 0)
		rd_data_b = sw_pp;
	else
        rd_data_b = data_b;
end

// -- decoder
logic f_add, PC_wait;
logic [4:0] reg_en; 

instruction_decoder #(
    OPCODE_WIDTH
) id (
    .opcode    (instr[11:9]),                  
    .f_add     (f_add      ), 
    .f_wait    (PC_wait    ),            
    .wr_res    (wr_res     ),         
    .ALU_reg_en(reg_en     )
);

// -- ALU
logic [BUS_WIDTH-1:0] ALU_result;
logic [BUS_WIDTH-1:0] ALU_imm;
logic [4:0]           ALU_reg_en; 
logic                 ALU_add;

always_ff @(posedge clk) begin
    ALU_imm    <= instr[7:0];
    ALU_add    <= f_add;
    ALU_reg_en <= reg_en;
end

ALU #(
    BUS_WIDTH
) alu (
    .clk    (clk                                          ),
    .ops    ({ALU_imm,ALU_imm,rd_data_b,ALU_imm,rd_data_a}),   
    .reg_en (ALU_reg_en                                   ),
    .f_add  (ALU_add                                      ),
    .result (ALU_result                                   )
);    

assign out_port = ALU_result;

endmodule
