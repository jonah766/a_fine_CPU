`include "opcodes.sv"

module instruction_decoder #(
    parameter OPCODE_WIDTH = 3
) (
    input  logic [OPCODE_WIDTH-1:0] opcode,                  
    output logic                    f_add,            
    output logic                    f_imm,       
    output logic                    f_wait,      
    output logic                    f_load,      
    output logic                    f_wr_res
);

always_comb 
begin
    case(opcode)    
        `ADD: begin
            f_add      = '1;
            f_imm      = '0;
            f_wait     = '0;
            f_load     = '0;
            f_wr_res   = '1;
        end
        `ADDI: begin
            f_add      = '1;
            f_imm      = '1;
            f_wait     = '0;
            f_load     = '0;
            f_wr_res   = '1;
        end
        `MUL: begin
            f_add      = '0;
            f_imm      = '0;
            f_wait     = '0;
            f_load     = '0;
            f_wr_res   = '1;
        end
        `MULI: begin
            f_add      = '0;
            f_imm      = '1;
            f_wait     = '0;
            f_load     = '0;
            f_wr_res   = '1;
        end
        `WAIT: begin
            f_add      = '0;
            f_imm      = '0;
            f_wait     = '1;
            f_load     = '0;
            f_wr_res   = '0;
        end
        `LDSW: begin
            f_add      = '0;
            f_imm      = '0;
            f_wait     = '0;
            f_load     = '1;
            f_wr_res   = '1;
        end
        default : begin
            f_add      = '0;
            f_imm      = '0;
            f_wait     = '0;
            f_load     = '0;
            f_wr_res   = '0;
        end
    endcase 
end 

endmodule