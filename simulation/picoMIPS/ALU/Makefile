TOPLEVEL_LANG ?= verilog
SIM ?= icarus
PWD=$(shell pwd)

BUS_WIDTH := 8
FUNC_WIDTH := 3
VERILOG_SOURCES := $(PWD)/../../rtl/picoMIPS/ALU.sv 

# Set module parameters
ifeq ($(SIM), icarus)
	COMPILE_ARGS += -P ALU.BUS_WIDTH=$(BUS_WIDTH) -P ALU.FUNC_WIDTH=$(FUNC_WIDTH) -I $(PWD)/../../include
endif

export RANDOM_SEED := 123456789
export NUM_SAMPLES := 1000

MODULE   := ALU_test
TOPLEVEL := ALU

include $(shell cocotb-config --makefiles)/Makefile.sim	