TOPLEVEL_LANG ?= verilog
SIM ?= icarus
PWD=$(shell pwd)

ADDR_WIDTH := 6
VERILOG_SOURCES := $(PWD)/../../rtl/picoMIPS/Program_Counter.sv 

# Set module parameters
ifeq ($(SIM), icarus)
	COMPILE_ARGS += -P Program_Counter.ADDR_WIDTH=$(ADDR_WIDTH) -I $(PWD)/../../include
endif

export RANDOM_SEED := 3128793

MODULE   := PC_test
TOPLEVEL := Program_Counter

include $(shell cocotb-config --makefiles)/Makefile.sim	