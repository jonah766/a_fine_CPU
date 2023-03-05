TOPLEVEL_LANG ?= verilog
SIM ?= icarus
PWD=$(shell pwd)

N := 8
VERILOG_SOURCES := $(PWD)/../../rtl/picoMIPS/regs.sv 

# Set module parameters
ifeq ($(SIM), icarus)
	COMPILE_ARGS += -P regs.n=$(N) -I $(PWD)/../../include
endif

export RANDOM_SEED := 3128793

MODULE   := regs_test
TOPLEVEL := regs

include $(shell cocotb-config --makefiles)/Makefile.sim	