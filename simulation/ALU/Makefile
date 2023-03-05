TOPLEVEL_LANG ?= verilog
SIM ?= icarus
PWD=$(shell pwd)

N := 8
VERILOG_SOURCES := $(PWD)/../../rtl/picoMIPS/alu.sv 

# Set module parameters
ifeq ($(SIM), icarus)
	COMPILE_ARGS += -P alu.n=$(N) -I $(PWD)/../../include
endif

export RANDOM_SEED := 123456789
export NUM_SAMPLES := 1000

MODULE   := ALU_test
TOPLEVEL := alu

include $(shell cocotb-config --makefiles)/Makefile.sim	