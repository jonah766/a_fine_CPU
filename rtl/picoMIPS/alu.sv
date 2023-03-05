//-----------------------------------------------------
// File Name   : alu.sv
// Function    : ALU module for picoMIPS
// Version: 1,  only 8 funcs
// Author:  tjk
// Last rev. 23 Oct 12
//-----------------------------------------------------

`include "alucodes.sv"  
module alu #(parameter n = 8) (
   input logic [n-1:0] a, b, // ALU operands
   input logic [2:0] func, // ALU function code
   output logic [2:0] flags, // ALU flags V,N,Z
   output logic [n-1:0] result // ALU result
);       
//------------- code starts here ---------

// create an n-bit adder 
// and then build the ALU around the adder
logic[n-1:0] ar, b1; // temp signals
always_comb
begin
   if(func==`RSUB)
      b1 = ~b + 1'b1; // 2's complement subtrahend
   else 
      b1 = b;
   
   ar = a + b1; // n-bit adder
end // always_comb
   
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
    `ROR   : result= a | b;
    `RXOR  : result = a ^ b;
    `RNOR  : result = ~ (a | b);
    endcase

   // calculate flags Z and N
   flags[1] = result[n-1]; // N
   flags[0] = result == {n{1'b0}}; // Z
 
 end 

endmodule 


