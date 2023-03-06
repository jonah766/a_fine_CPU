//---------------------------------------------------------
// File Name   : decoder.sv
// Function    : picoMIPS instruction decoder 
// Author: tjk
// ver 2:  // NOP, ADD, ADDI, and branches
// Last revised: 26 Oct 2012
//---------------------------------------------------------

`include "alucodes.sv"
`include "opcodes.sv"
//---------------------------------------------------------
module Instruction_Decoder #(
    parameter int OPCODE_WIDTH = 6,
    parameter int FUNC_WIDTH = 3,
    parameter int FLAG_WIDTH = 3
) ( 
    input logic [OPCODE_WIDTH-1:0] opcode,         // top 6 bits of instruction
    input logic [FLAG_WIDTH-1:0] flags,            // ALU flags
    output logic PC_incr, PC_abs_branch, PC_rel_branch, // PC control
    output logic [FUNC_WIDTH-1:0] ALU_func,         // ALU control
    output logic imm,                              // imm mux control
    output logic we                                // register file control
);
   
logic rel_branch; // temp variable to control conditional branching
always_comb 
begin
    // set default output signal values for NOP instruction
    PC_incr       = '1;
    PC_abs_branch = '0;
    PC_rel_branch = '0;
    ALU_func      = opcode[FUNC_WIDTH-1:0]; 
    imm           = '0;
    we            = '0; 
    rel_branch    = '0; 
    case(opcode)
        `NOP: ;
        // numeric
        `ADD,`SUB : begin 
            we  = '1; 
        end
        `ADDI,`SUBI: begin 
            we  = '1; 
            imm = '1; 
        end
        // relative branches
        `BEQ: rel_branch = flags[0];  // branch if Z==1
        `BNE: rel_branch = ~flags[0]; // branch if Z==0
        `BGE: rel_branch = ~flags[1]; // branch if N==0
    endcase 

    if(rel_branch)
    begin
        PC_incr = '0;
        PC_rel_branch = '1; 
    end

end 

endmodule 