# simulation info
TOPLEVEL_LANG ?= verilog
SIM ?= icarus

# directories
PWD=$(shell pwd)
RTL_DIR=$(PWD)/../../rtl/picoMIPS

# RTL
VERILOG_SOURCES := \
	$(RTL_DIR)/Program_Counter.sv \
	$(RTL_DIR)/Instruction_Decoder.sv \
	$(RTL_DIR)/Program_Memory.sv \
	$(RTL_DIR)/Register_File.sv \
	$(RTL_DIR)/ALU.sv \
	$(RTL_DIR)/CPU.sv  

# Parameters
INSTR_WIDTH  := 24 # = 6 [opcode] + 2*(5) [addr] + 8 [immediate or addr] 
OPCODE_WIDTH := 6 
ADDR_WIDTH   := 5
BUS_WIDTH    := 8
FUNC_WIDTH   := 3
FLAG_WIDTH   := 3

# Set module parameters
ifeq ($(SIM), icarus)
	COMPILE_ARGS += -P CPU.ADDR_WIDTH=$(ADDR_WIDTH) 
	COMPILE_ARGS += -P CPU.BUS_WIDTH=$(BUS_WIDTH)
	COMPILE_ARGS += -P CPU.FUNC_WIDTH=$(FUNC_WIDTH)
	COMPILE_ARGS += -P CPU.FLAG_WIDTH=$(FLAG_WIDTH)
	COMPILE_ARGS += -P CPU.INSTR_WIDTH=$(INSTR_WIDTH)  
	COMPILE_ARGS += -P CPU.OPCODE_WIDTH=$(OPCODE_WIDTH)     
	COMPILE_ARGS += -I $(PWD)/../../include
	COMPILE_ARGS += -I $(PWD)/../../programs
endif

export RANDOM_SEED := 2048023532

MODULE   := CPU_runner
TOPLEVEL := CPU

include $(shell cocotb-config --makefiles)/Makefile.sim	