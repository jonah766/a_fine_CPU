//-----------------------------------------------------
// File Name : program_memory.sv
// Function : Program memory Psize x Isize - reads from file prog.hex
//-----------------------------------------------------

// psize - address width, Isize - instruction width
module Program_Memory #(
    parameter int ADDR_WIDTH = 6,
    parameter int INSTR_WIDTH = 24
) (
    input logic [ADDR_WIDTH-1:0] addr,
    output logic [INSTR_WIDTH-1:0] instr //  - instruction code I
); 

// program memory declaration, note: 1<<n is same as 2^n
logic [INSTR_WIDTH-1:0] progMem[(1<<ADDR_WIDTH)-1:0];

// get memory contents from file
initial
    $readmemh("../../programs/prog.hex", progMem);
  
// program memory read 
always_comb
    instr = progMem[addr]; 
  
endmodule 
