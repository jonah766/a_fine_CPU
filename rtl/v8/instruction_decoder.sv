`include "opcodes.sv"

module instruction_decoder #(
    parameter OPCODE_WIDTH = 3
) (
    input  logic [OPCODE_WIDTH-1:0] opcode,                  
    output logic                    f_add,            
    output logic                    f_wait,       
    output logic                    f_load,      
    output logic                    wr_res,         
    output logic [2:0]              ALU_reg_en
);

always_comb 
begin
    case(opcode)    
        `MOV : begin
            f_load     = '0;
            f_add      = '1; 
            f_wait     = '0;
            wr_res     = '1; 
            ALU_reg_en = 5'b111; // C, A
        end
        `MAC : begin 
            f_load     = '0;
            f_add      = '0;
            f_wait     = '0;
            wr_res     = '1; 
            ALU_reg_en = 5'b000; // C, A
        end
        `WAIT: begin
            f_load     = '0;
            f_add      = '0;
            f_wait     = '1;
            wr_res     = '0;
            ALU_reg_en = 5'b000;
        end
        `SETB: begin
            f_load     = '0;
            f_add      = '0;
            f_wait     = '0;
            wr_res     = '0;
            ALU_reg_en = 5'b001; 
        end
        `SETD: begin
            f_load     = '0;
            f_add      = '0;
            f_wait     = '0;
            wr_res     = '0;
            ALU_reg_en = 5'b010;
        end
        `SETE: begin
            f_load     = '0;
            f_add      = '0;
            f_wait     = '0;
            wr_res     = '0;
            ALU_reg_en = 5'b100;
        end
        `LDSW: begin
            f_load     = '1;
            f_add      = '1;
            f_wait     = '0;
            wr_res     = '1;
            ALU_reg_en = 5'b000;
        end
        default : begin
            f_load     = '0;
            f_add      = '0;
            f_wait     = '0;
            wr_res     = '0;
            ALU_reg_en = '0;
        end
    endcase 
end 

endmodule