module program_memory #(
    parameter ADDR_WIDTH  = 4,
    parameter INSTR_WIDTH = 12
) (
    input  logic [ADDR_WIDTH-1:0]  addr,
    output logic [INSTR_WIDTH-1:0] instr
); 

logic [INSTR_WIDTH-1:0] prog_mem [(1<<ADDR_WIDTH)-1:0];

initial
    $readmemh("/home/jonahfoley/ELEC6234/a_fine_CPU/programs/prog_2.hex", prog_mem);
   
always_comb
    instr = prog_mem[addr]; 
  
endmodule 
    