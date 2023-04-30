module dual_port_SRAM #(
    parameter BUS_WIDTH = 8,
    parameter DEPTH     = 3
) (
	input  logic                     clk, 
	input  logic                     we_a, we_b,
 	input  logic [$clog2(DEPTH)-1:0] wr_addr_a, wr_addr_b,
	input  logic [BUS_WIDTH-1:0]     wr_data_a, wr_data_b,
 	input  logic [$clog2(DEPTH)-1:0] rd_addr_a, rd_addr_b,
 	output logic [BUS_WIDTH-1:0]     rd_data_a, rd_data_b
);

logic [BUS_WIDTH-1:0] gpr [DEPTH-1:0];

initial begin
	for (int i = 0; i < DEPTH; i = i + 1)
		gpr[i] = '0;
end

// syncrhonous RAM a write/read
always_ff @ (posedge clk)
begin
	if (we_a) begin 
		gpr[wr_addr_a] <= wr_data_a;
	end
	rd_data_a <= gpr[rd_addr_a];
end	


// syncrhonous RAM b write/read
always_ff @ (posedge clk)
begin
	if (we_b) begin 
		gpr[wr_addr_b] <= wr_data_b;
	end
	rd_data_b <= gpr[rd_addr_b];
end	
	

endmodule
