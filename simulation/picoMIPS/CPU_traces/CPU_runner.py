import os
import random
import math
import sys
import random
from typing import Any, Dict, List
from pathlib import Path

import cocotb
from cocotb.runner import get_runner
from cocotb.handle import SimHandleBase
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock

@cocotb.test()
async def CPU_test(dut : SimHandleBase):

    instr_count = 0
    proj_path = Path(__file__).resolve().parent
    with open(proj_path / "../../programs/prog.hex", "r") as prog:
        instr_count = sum([not line.startswith("//") for line in prog])  
    
    # clock
    dut._log.info("generatign clock")
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Reset DUT
    dut._log.info("resetting dut")
    dut.reset.value = 1
    for _ in range(3):
        await RisingEdge(dut.clk)
    dut.reset.value = 0

    # Do multiplication operations
    for i in range(instr_count):
        await RisingEdge(dut.clk)
        dut._log.info(f"executing instruction {i} / {instr_count}")
    

# build and run the simulation
def CPU_runner():   
    # sim info
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    
    # directories
    proj_path = Path(__file__).resolve().parent
    rtl_path = proj_path / ".." / ".." / "rtl" / "picoMIPS"

    # rtl sources
    verilog_sources = [
        rtl_path / "Program_Counter.sv",
        rtl_path / "Instruction_Decoder.sv",
        rtl_path / "Program_Memory.sv",
        rtl_path / "Register_File.sv",
        rtl_path / "ALU.sv",
        rtl_path / "CPU.sv"
    ]

    # parameters
    INSTR_WIDTH  = 24
    OPCODE_WIDTH = 6 
    ADDR_WIDTH   = 6
    BUS_WIDTH    = 8
    FUNC_WIDTH   = 3
    FLAG_WIDTH   = 3
    extra_args = [ 
        f"P CPU.INSTR_WIDTH={INSTR_WIDTH}", 
        f"P CPU.OPCODE_WIDTH={OPCODE_WIDTH}", 
        f"P CPU.ADDR_WIDTH={ADDR_WIDTH}", 
        f"P CPU.BUS_WIDTH={BUS_WIDTH}", 
        f"P CPU.FUNC_WIDTH={FUNC_WIDTH}", 
        f"P CPU.FLAG_WIDTH={FLAG_WIDTH}",
        f"-I ${proj_path}/../../include" 
        f"-I ${proj_path}/../../programs" 
    ]

    runner = get_runner(sim)
    # build the test
    runner.build(
        verilog_sources=verilog_sources,
        hdl_toplevel="CPU",
        build_args=extra_args,
        parameters=parameters,
        always=True,
    )
    # run the test
    runner.test(
        hdl_toplevel="CPU", 
        hdl_toplevel_lang=hdl_toplevel_lang,
        test_module="CPU_test"
    )

if __name__ == "__main__":
    # run the tests 
    CPU_runner()