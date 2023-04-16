module register_file #(
    parameter BUS_WIDTH  = 8,
    parameter ADDR_WIDTH = 3
) (
	input  logic                  clk, 
	input  logic [BUS_WIDTH-1:0]  sw,
	input  logic 				  ready_in,
	input  logic 				  pattern_match,
	input  logic                  we,
 	input  logic [ADDR_WIDTH-1:0] wr_addr,
	input  logic [BUS_WIDTH-1:0]  wr_data,
 	input  logic [ADDR_WIDTH-1:0] rd_addr_a, rd_addr_b,
 	output logic [BUS_WIDTH-1:0]  rd_data_a, rd_data_b,
	output logic [BUS_WIDTH-1:0]  out_port
);

localparam N = (1 << ADDR_WIDTH);

(* ramstyle = "MLAB" *) logic [BUS_WIDTH-1:0] gpr [N-1:0];

// syncrhonous RAM write
always_ff @ (posedge clk)
begin
	if (we) begin 
		gpr[wr_addr] <= wr_data;
	end
end	

// asynchronous RAM read
logic [BUS_WIDTH-1:0] data_a, data_b;
always_comb
	data_a = gpr[rd_addr_a];

always_comb
	data_b = gpr[rd_addr_b];

// multiplex the rd_data_a output based on the asked for addr
always_comb
begin
	case(rd_addr_a)
		0       : rd_data_a = {BUS_WIDTH{1'b0}};
		1       : rd_data_a = sw;
		2       : rd_data_a = {{BUS_WIDTH-1{1'b0}}, ready_in};
		3       : rd_data_a = {{BUS_WIDTH-1{1'b0}}, pattern_match};
		default : rd_data_a = data_a;
	endcase
end

// multiplex the rd_data_b output based on the asked for addr
always_comb
begin
	case(rd_addr_b)
		0       : rd_data_b = {BUS_WIDTH{1'b0}};
		1       : rd_data_b = sw;
		2       : rd_data_b = {{BUS_WIDTH-1{1'b0}}, ready_in};
		3       : rd_data_b = {{BUS_WIDTH-1{1'b0}}, pattern_match};
		default : rd_data_b = data_b;
	endcase
end

// register $7 is the output register
assign out_port = gpr[7];

endmodule