// This file is public domain, it can be freely copied without restrictions.
// SPDX-License-Identifier: CC0-1.0

`timescale 1us/1us

module dff (
  input logic clk, d,
  output logic q
);

// the "macro" to dump signals
`ifdef COCOTB_SIM
initial begin
	$dumpfile ("dff.vcd");
	$dumpvars (0, dff);
	#1;
end
`endif

always_ff @(posedge clk) begin
	q <= d;	
end

endmodule
