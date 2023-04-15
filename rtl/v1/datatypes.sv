package datatypes;

    parameter BUS_WIDTH    = 8;
    parameter INSTR_WIDTH  = 12;
    parameter OPCODE_WIDTH = 3;
    parameter ADDR_WIDTH   = 3;

    typedef union packed {
        struct packed {
            logic [BUS_WIDTH-1:0] a;
            logic [BUS_WIDTH-1:0] b;
            logic [BUS_WIDTH-1:0] c;
            logic [BUS_WIDTH-1:0] d;
            logic [BUS_WIDTH-1:0] e;
        } as_struct;
        logic [4:0][BUS_WIDTH-1:0] as_array;
    } operand_pack_t;

    typedef struct packed {
        logic [OPCODE_WIDTH-1:0] opcode;
        logic [ADDR_WIDTH-1:0]   rd;
        logic [ADDR_WIDTH-1:0]   rs;
        logic [ADDR_WIDTH-1:0]   rt;
    } rtype_t;

    typedef struct packed {
        logic [OPCODE_WIDTH-1:0] opcode;
        logic [2:0]              padding1;
        logic [ADDR_WIDTH-1:0]   rt;
        logic [1:0]              padding2;
        logic                    imm;
    } wait_t;

    typedef struct packed {
        logic [OPCODE_WIDTH-1:0] opcode;
        logic                    padding;
        logic [BUS_WIDTH-1:0]    imm;
    } set_t;

    typedef union packed {
        rtype_t as_rtype;
        wait_t  as_wait;
        set_t   as_set;
    } instruction_t;

    function automatic int max(int a, int b);
        return (a > b) ? a : b;
    endfunction

    function automatic int min(int a, int b);
        return (a < b) ? a : b;
    endfunction

endpackage