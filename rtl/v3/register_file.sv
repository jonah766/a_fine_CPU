module register_file #(
    parameter BUS_WIDTH  = 8,
    parameter ADDR_WIDTH = 3
) (
	input  logic                  clk, 
	input  logic                  we,
 	input  logic [ADDR_WIDTH-1:0] wr_addr,
	input  logic [BUS_WIDTH-1:0]  wr_data,
 	input  logic [ADDR_WIDTH-1:0] rd_addr_a, rd_addr_b,
 	output logic [BUS_WIDTH-1:0]  rd_data_a, rd_data_b
);

localparam N = (1 << ADDR_WIDTH);

logic [BUS_WIDTH-1:0] gpr [N-1:0];

initial begin
	for (int i = 0; i < N; i = i + 1)
		gpr[i] = '0;
end

// syncrhonous RAM write
always_ff @ (posedge clk)
begin
	if (we) begin 
		gpr[wr_addr] <= wr_data;
	end
	rd_data_b <= gpr[rd_addr_b];
	rd_data_a <= gpr[rd_addr_a];
end	
	

endmodule