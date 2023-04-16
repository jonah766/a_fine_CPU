TOPLEVEL_LANG ?= verilog
SIM           ?= icarus
PWD           ?= $(shell pwd)
RTL_DIR		  ?= $(PWD)/../../../rtl/v1
TOPLEVEL      ?= $(shell pwd | rev | cut -d'/' -f 1 | rev)
MODULE        ?= $(addsuffix _test, $(TOPLEVEL))
TEST_BENCH    ?= $(addsuffix .py, $(MODULE))

$(info PWD is        : $(PWD))
$(info RTL_DIR is    : $(RTL_DIR))
$(info TOPLEVEL is   : $(TOPLEVEL))
$(info MODULE is     : $(MODULE))
$(info TEST_BENCH is : $(TEST_BENCH))

# set source files
VERILOG_SOURCES ?= $(RTL_DIR)/datatypes.sv  
VERILOG_SOURCES += $(RTL_DIR)/sfixed_adder.sv 
VERILOG_SOURCES += $(RTL_DIR)/sfixed_mult.sv 
VERILOG_SOURCES += $(RTL_DIR)/register_file.sv 
VERILOG_SOURCES += $(RTL_DIR)/program_memory.sv 
VERILOG_SOURCES += $(RTL_DIR)/program_counter.sv 
VERILOG_SOURCES += $(RTL_DIR)/mux_21.sv 
VERILOG_SOURCES += $(RTL_DIR)/instruction_decoder.sv 
VERILOG_SOURCES += $(RTL_DIR)/input_regs.sv 
VERILOG_SOURCES += $(RTL_DIR)/ALU.sv
VERILOG_SOURCES += $(RTL_DIR)/CPU.sv 

# Set module parameters
ifeq ($(SIM),icarus)
	COMPILE_ARGS += -PCPU.INSTR_WIDTH=12 -PCPU.OPCODE_WIDTH=3 -PCPU.INSTR_ADDR_WIDTH=4 -PCPU.REG_ADDR_WIDTH=3 -PCPU.BUS_WIDTH=8
	COMPILE_ARGS += -I$(RTL_DIR)
else
	$(error A valid value simulator was not provided for SIM=$(SIM))
endif 

export RANDOM_SEED := 41934129
export NUM_SAMPLES := 100
export BUS_WIDTH   := 8

include $(shell cocotb-config --makefiles)/Makefile.sim	
