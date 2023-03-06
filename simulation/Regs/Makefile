TOPLEVEL_LANG ?= verilog
SIM ?= icarus
PWD=$(shell pwd)

BUS_WIDTH  := 8
ADDR_WIDTH := 5
VERILOG_SOURCES := $(PWD)/../../rtl/picoMIPS/Register_File.sv 

# Set module parameters
ifeq ($(SIM), icarus)
	COMPILE_ARGS += \
		-P Register_File.BUS_WIDTH=$(BUS_WIDTH) \
		-P Register_File.ADDR_WIDTH=$(ADDR_WIDTH) \
		-I $(PWD)/../../include
endif

export RANDOM_SEED := 3128793

MODULE   := regs_test
TOPLEVEL := Register_File

include $(shell cocotb-config --makefiles)/Makefile.sim	