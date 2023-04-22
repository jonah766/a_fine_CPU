module register_file #(
    parameter BUS_WIDTH  = 8,
    parameter ADDR_WIDTH = 3
) (
	input  logic                  clk, 
	input  logic                  we,
	input  logic [BUS_WIDTH-1:0]  sw,
 	input  logic [ADDR_WIDTH-1:0] wr_addr,
	input  logic [BUS_WIDTH-1:0]  wr_data,
 	input  logic [ADDR_WIDTH-1:0] rd_addr_a, rd_addr_b,
 	output logic [BUS_WIDTH-1:0]  rd_data_a, rd_data_b
);

logic [BUS_WIDTH-1:0] data_a, data_b;

dual_port_SRAM #(
	BUS_WIDTH,
	ADDR_WIDTH
) sr0 (
	.clk      (clk      ), 
	.we       (we       ),
 	.wr_addr  (wr_addr  ),
	.wr_data  (wr_data  ),
 	.rd_addr_a(rd_addr_a), 
	.rd_addr_b(rd_addr_b),
 	.rd_data_a(data_a   ), 
	.rd_data_b(data_b   )
);

logic [ADDR_WIDTH-1:0] rd_addr_a_p, rd_addr_b_p;
always_ff @(posedge clk)
begin
    rd_addr_a_p <= rd_addr_a;
    rd_addr_b_p <= rd_addr_b;
end 

// multiplex the rd_data_a output based on the asked for addr
always_comb
begin
	if(~(|rd_addr_a_p))
		rd_data_a = sw;
	else 
        rd_data_a = data_a;
end

// multiplex the rd_data_b output based on the asked for addr
always_comb
begin
	if (~(|rd_addr_b_p))
		rd_data_b = sw;
	else
        rd_data_b = data_b;
end


endmodule