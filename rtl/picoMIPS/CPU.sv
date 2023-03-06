//------------------------------------
// File Name   : cpu.sv
// Function    : picoMIPS CPU top level encapsulating module
//------------------------------------

`include "alucodes.sv"
module CPU #(
    parameter int INSTR_WIDTH  = 24, // Width of an instruction
    parameter int OPCODE_WIDTH = 6,  // Width of each opcode in the instuction
    parameter int ADDR_WIDTH   = 5,  // Size of each memory address in the register file (# addresses = 2^ADDR_WIDTH)
    parameter int BUS_WIDTH    = 8,  // Data-path bus width (ALU operands size)
    parameter int FUNC_WIDTH   = 3,  // Width of the ALU function code
    parameter int FLAG_WIDTH   = 3   // Numer of ALU flags (V, N, Z)
) (
    input logic clk,  
    input logic reset,                    // master reset
    output logic [BUS_WIDTH-1:0] out_port // need an output port, tentatively this will be the ALU output
);       

//the "macro" to dump signals
`ifdef COCOTB_SIM
initial begin
    $dumpfile ("CPU.vcd");
    $dumpvars (0, CPU);
    #1;
end
`endif

// ALU
logic [FUNC_WIDTH-1:0] ALU_func; // ALU function
logic [FLAG_WIDTH-1:0] flags; // ALU flags, routed to decoder
logic imm; // immediate operand signal
logic [BUS_WIDTH-1:0] ALU_b; // output from imm MUX

// registers
logic [BUS_WIDTH-1:0] rd_data, rs_data, wr_data; 
logic we; 

// Program Counter 
logic PC_incr, PC_abs_branch, PC_rel_branch; 
logic [ADDR_WIDTH-1:0] prog_addr;

// Program Memory
logic [INSTR_WIDTH-1:0] instr;

Program_Counter #(
   .ADDR_WIDTH(ADDR_WIDTH)
) program_counter_0 (
   .clk(clk),
   .reset(reset),
   .PC_incr(PC_incr),
   .PC_abs_branch(PC_abs_branch),
   .PC_rel_branch(PC_rel_branch),
   .branch_addr(instr[ADDR_WIDTH-1:0]),
   .PC_out(prog_addr) 
);

Program_Memory #(
   .ADDR_WIDTH(ADDR_WIDTH),
   .INSTR_WIDTH(INSTR_WIDTH)
) program_memory_0 (
   .addr(prog_addr),
   .instr(instr)
);

parameter OPCODE_BEGIN = INSTR_WIDTH-1;
parameter OPCODE_END = OPCODE_BEGIN-(OPCODE_WIDTH-1);
Instruction_Decoder #(
   .OPCODE_WIDTH(OPCODE_WIDTH),
   .FUNC_WIDTH(FUNC_WIDTH),
   .FLAG_WIDTH(FLAG_WIDTH)
) instruction_decoder_0 (
   .opcode(instr[OPCODE_BEGIN:OPCODE_END]),
   .PC_incr(PC_incr),
   .PC_abs_branch(PC_abs_branch), 
   .PC_rel_branch(PC_rel_branch),
   .flags(flags), // ALU flags
   .ALU_func(ALU_func),
   .imm(imm),
   .we(we)
);

parameter RD_ADDR_BEGIN = OPCODE_END-1;
parameter RD_ADDR_END = RD_ADDR_BEGIN-(ADDR_WIDTH-1);
parameter RS_ADDR_BEGIN = RD_ADDR_END-1;
parameter RS_ADDR_END = RS_ADDR_BEGIN-(ADDR_WIDTH-1);
Register_File #(
   .BUS_WIDTH(BUS_WIDTH),
   .ADDR_WIDTH(ADDR_WIDTH)
) register_file_0 (
   .clk(clk),
   .we(we),
   .wr_data(wr_data),
   .rd_addr(instr[RD_ADDR_BEGIN:RD_ADDR_END]),  // reg %d number
   .rs_addr(instr[RS_ADDR_BEGIN:RS_ADDR_END]),  // reg %s number
   .rd_data(rd_data),
   .rs_data(rs_data)
);

// create MUX for immediate operand
assign ALU_b = (imm ? instr[BUS_WIDTH-1:0] : rs_data);

ALU #(
   .BUS_WIDTH(BUS_WIDTH),
   .FUNC_WIDTH(FUNC_WIDTH),
   .FLAG_WIDTH(FLAG_WIDTH)
) alu_0 (
   .a(rd_data),
   .b(ALU_b),
   .func(ALU_func),
   .flags(flags),
   .result(wr_data) // ALU result -> destination reg
); 

// connect ALU result to outport
assign out_port = wr_data;

endmodule
