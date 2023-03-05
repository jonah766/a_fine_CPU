TOPLEVEL_LANG ?= verilog
SIM ?= icarus
PWD=$(shell pwd)

PSize := 6
VERILOG_SOURCES := $(PWD)/../../rtl/picoMIPS/pc.sv 

# Set module parameters
ifeq ($(SIM), icarus)
	COMPILE_ARGS += -P alu.Psize=$(PSize) -I $(PWD)/../../include
endif

export RANDOM_SEED := 3128793

MODULE   := PC_test
TOPLEVEL := pc

include $(shell cocotb-config --makefiles)/Makefile.sim	