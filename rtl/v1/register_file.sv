module register_file #(
    parameter BUS_WIDTH  = 8,
    parameter ADDR_WIDTH = 3
) (
	input  logic                  clock, we, 
	input  logic [BUS_WIDTH-1:0]  sw,
	input  logic 				  ready_in,
	input  logic 				  pattern_match,
 	input  logic [ADDR_WIDTH-1:0] wr_addr,
	input  logic [BUS_WIDTH-1:0]  wr_data,
 	input  logic [ADDR_WIDTH-1:0] rd_addr_a, rd_addr_b,
 	output logic [BUS_WIDTH-1:0]  rd_data_a, rd_data_b
);


localparam N = (1 << ADDR_WIDTH);

logic [BUS_WIDTH-1:0] gpr [N-1:0];

integer i;
initial 
begin
	for (i = 0; i < N; i = i + 1)
		gpr[i] = '0;
end

always_ff @ (posedge clock)
begin
	if (we) begin 
		gpr[wr_addr] <= wr_data;
	end
end

always_comb
begin
	if (rd_addr_a == 0)       // zero 
		rd_data_a = {BUS_WIDTH{1'b0}};
	else if (rd_addr_a == 1)	// sw 
		rd_data_a = sw;
	else if (rd_addr_a == 2)  // ready in
		rd_data_a = {{BUS_WIDTH-1{1'b0}}, ready_in};
	else if (rd_addr_a == 3)  // pattern match
		rd_data_a = {{BUS_WIDTH-1{1'b0}}, pattern_match};
	else  
		rd_data_a = gpr[rd_addr_a];
end

always_comb
begin
	if (rd_addr_b == 0)       // zero 
		rd_data_b = {BUS_WIDTH{1'b0}};
	else if (rd_addr_b == 1)	// sw 
		rd_data_b = sw;
	else if (rd_addr_b == 2)  // ready in
		rd_data_b = {{BUS_WIDTH-1{1'b0}}, ready_in};
	else if (rd_addr_b == 3)  // pattern match
		rd_data_b = {{BUS_WIDTH-1{1'b0}}, pattern_match};
	else  
		rd_data_b = gpr[rd_addr_b];
end

endmodule