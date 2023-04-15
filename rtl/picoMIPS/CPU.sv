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
    input logic                  clock,  
    input logic                  n_reset, // master reset
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

logic PC_increment;

program_counter #(
   ADDR_WIDTH
) pc (
   .clock(clock),
   .n_reset(n_reset),
   .increment(PC_increment.)
)




endmodule
