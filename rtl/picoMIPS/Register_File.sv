//-----------------------------------------------------
// File Name : regs.sv
// Function : picoMIPS 32 x n registers, %0 == 0
//-----------------------------------------------------

// BUS_WIDTH - data bus width 
// ADDR_WIDTH - data bus width 
module Register_File #(
	parameter int BUS_WIDTH = 8,
	parameter int ADDR_WIDTH = 5
) (
	input  logic                  clk, we, // clk and write control
 	input  logic [BUS_WIDTH-1:0]  wr_data,
 	input  logic [ADDR_WIDTH-1:0] rd_addr, rs_addr,
 	output logic [BUS_WIDTH-1:0]  rd_data, rs_data
);

// 5 bit address -> 1 << 5 = 2^5 = 32 registers
parameter N = (1 << ADDR_WIDTH);

// Declare 32 n-bit registers 
logic [BUS_WIDTH-1:0] gpr [N-1:0];

// specify initial conditions
integer i;
initial 
begin
	for (i = 0; i < N; i = i + 1)
		gpr[i] = '0;
end

// write process, dest reg is rd_addr_2
always_ff @ (posedge clk)
begin
	if (we)
		gpr[rd_addr] <= wr_data;
end

// read process, output 0 if %0 is selected
always_comb
begin
	if (rd_addr == '0)
		rd_data = {BUS_WIDTH{1'b0}};
	else  
		rd_data = gpr[rd_addr];
end

always_comb
begin
	if (rs_addr == '0)
		rs_data = {BUS_WIDTH{1'b0}};
	else  
		rs_data = gpr[rs_addr];
end	


endmodule // module regs
