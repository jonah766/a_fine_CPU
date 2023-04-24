`include "opcodes.sv"

module instruction_decoder #(
    parameter OPCODE_WIDTH = 3
) (
    input  logic [OPCODE_WIDTH-1:0] opcode,                  
    output logic                    ALU_add,        
    output logic                    PC_wait,   
    output logic                    ALU_load,  
    output logic                    wr_res,       
    output logic [4:0]              ALU_reg_en
);

always_comb 
begin
    case(opcode)    
        `MOV : begin
            ALU_load   = '0;
            ALU_add    = '1; 
            PC_wait    = '0;
            wr_res     = '1; 
            ALU_reg_en = 5'b11111; // C, A
        end
        `MAC : begin 
            ALU_load   = '0;
            ALU_add    = '0;
            PC_wait    = '0;
            wr_res     = '1; 
            ALU_reg_en = 5'b00101; // C, A
        end
        `WAIT: begin
            ALU_load   = '0;
            ALU_add    = '0;
            PC_wait    = '1;
            wr_res     = '0;
            ALU_reg_en = 5'b00000;
        end
        `SETB: begin
            ALU_load   = '0;
            ALU_add    = '0;
            PC_wait    = '0;
            wr_res     = '0;
            ALU_reg_en = 5'b00010; 
        end
        `SETD: begin
            ALU_load   = '0;
            ALU_add    = '0;
            PC_wait    = '0;
            wr_res     = '0;
            ALU_reg_en = 5'b01000;
        end
        `SETE: begin
            ALU_load   = '0;
            ALU_add    = '0;
            PC_wait    = '0;
            wr_res     = '0;
            ALU_reg_en = 5'b10000;
        end
        `LDSW: begin
            ALU_load   = '1;
            ALU_add    = '1;
            PC_wait    = '0;
            wr_res     = '1;
            ALU_reg_en = 5'b11111;
        end
        default : begin
            ALU_load   = '0;
            ALU_add    = '0;
            PC_wait    = '0;
            wr_res     = '0;
            ALU_reg_en = '0;
        end
    endcase 
end 

endmodule