//-----------------------------------------------------
// File Name : pc.sv
// Function : picoMIPS Program Counter
// functions: increment, absolute and relative branches
//-----------------------------------------------------

module Program_Counter #(
    parameter int ADDR_WIDTH = 6
) (
    input logic clk, reset, PC_incr, PC_abs_branch, PC_rel_branch,
    input logic [ADDR_WIDTH-1:0] branch_addr,
    output logic [ADDR_WIDTH-1:0] PC_out
);

logic[ADDR_WIDTH-1:0] r_branch; // temp variable for addition operand
always_comb
begin
    if (PC_incr)
        r_branch = { {(ADDR_WIDTH-1){1'b0}}, 1'b1};
    else 
        r_branch = branch_addr;
end

always_ff @ ( posedge clk or posedge reset) // async reset
begin
    if (reset)
        PC_out <= '0;
    else 
    begin 
        if (PC_incr | PC_rel_branch) // increment or relative branch
            PC_out <= PC_out + r_branch; 
        else if (PC_abs_branch) // absolute branch
            PC_out <= branch_addr;
    end
end
	 
endmodule // module pc