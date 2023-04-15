//-----------------------------------------------------
// File Name   : alu.sv
// Function    : ALU module for picoMIPS
//-----------------------------------------------------

`include "alucodes.sv"  
module ALU #(
    parameter int BUS_WIDTH = 8,
    parameter int FUNC_WIDTH = 3,
    parameter int FLAG_WIDTH = 3
) (
    input logic [BUS_WIDTH-1:0] a, b, // ALU operands
    input logic [FUNC_WIDTH-1:0] func, // ALU function code
    output logic [FLAG_WIDTH-1:0] flags, // ALU flags V,N,Z
    output logic [BUS_WIDTH-1:0] result // ALU result
);       

// create an BUS_WIDTH-bit adder 
// and then build the ALU around the adder
logic[BUS_WIDTH-1:0] ar, b1; 
always_comb
begin
    if(func == `RSUB)
        b1 = ~b + 1'b1; // 2's complement subtrahend
    else 
        b1 = b;
    ar = a + b1; // BUS_WIDTH-bit adder
end 
   
// create the ALU, use signal ar in arithmetic operations
always_comb
begin
    flags = '0;
    result = a; // default
    case(func)
        `RA    : result = a;
        `RB    : result = b;
        `RADD  : begin
            result = ar; // arithmetic addition
            flags[2] = a[7] & b[7] & ~result[7] | ~a[7] & ~b[7] & result[7]; // V
        end
        `RSUB  : begin
            result = ar; // arithmetic subtraction
            flags[2] = ~a[7] & b[7] & result[7] | a[7] & ~b[7] & ~result[7]; // V       
        end   
        `RAND  : result = a & b;
        `ROR   : result = a | b;
        `RXOR  : result = a ^ b;
        `RNOR  : result = ~ (a | b);
        default : result = a;

    endcase
    // calculate flags Z and N
    flags[1] = result[BUS_WIDTH-1];         // N
    flags[0] = result == {BUS_WIDTH{1'b0}}; // Z
end 

endmodule 


