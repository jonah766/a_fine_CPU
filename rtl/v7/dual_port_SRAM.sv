module dual_port_SRAM #(
    parameter BUS_WIDTH = 8,
    parameter DEPTH     = 3
) (
	input  logic                     clk, 
	input  logic                     we,
 	input  logic [$clog2(DEPTH)-1:0] wr_addr,
	input  logic [BUS_WIDTH-1:0]     wr_data,
 	input  logic [$clog2(DEPTH)-1:0] rd_addr_a, rd_addr_b,
 	output logic [BUS_WIDTH-1:0]     rd_data_a, rd_data_b
);

logic [BUS_WIDTH-1:0] gpr [DEPTH-1:0];

initial begin
	for (int i = 0; i < DEPTH; i = i + 1)
		gpr[i] = '0;
end

// syncrhonous RAM write
always_ff @ (posedge clk)
begin
	if (we) begin 
		gpr[wr_addr] <= wr_data;
	end
	`ifdef COCOTB_SIM
		rd_data_b <= (wr_addr == rd_addr_b & we) ? wr_data : gpr[rd_addr_b];
		rd_data_a <= (wr_addr == rd_addr_a & we) ? wr_data : gpr[rd_addr_a];
	`else
		rd_data_b <= gpr[rd_addr_b];
		rd_data_a <= gpr[rd_addr_a];
	`endif
end	
	

endmodule