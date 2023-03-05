//-----------------------------------------------------
// File Name : regs.sv
// Function : picoMIPS 32 x n registers, %0 == 0
//-----------------------------------------------------

// n - data bus width 
module regs #(parameter n = 8) (
	input logic clk, w, // clk and write control
 	input logic [n-1:0] Wdata,
 	input logic [4:0] Raddr1, Raddr2,
 	output logic [n-1:0] Rdata1, Rdata2
);

// Declare 32 n-bit registers 
logic [n-1:0] gpr [31:0];

// specify initial conditions
integer i;
initial 
begin
	for (i = 0; i < 32; i = i + 1)
		gpr[i] = '0;
end

// write process, dest reg is Raddr2
always_ff @ (posedge clk)
begin
	if (w)
		gpr[Raddr2] <= Wdata;
end

// read process, output 0 if %0 is selected
always_comb
begin
	if (Raddr1 == 5'd0)
		Rdata1 = {n{1'b0}};
	else  
		Rdata1 = gpr[Raddr1];
end

always_comb
begin
	if (Raddr2 == 5'd0)
		Rdata2 = {n{1'b0}};
	else  
		Rdata2 = gpr[Raddr2];
end	


endmodule // module regs
