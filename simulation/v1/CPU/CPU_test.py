# stdlib
import os
import sys
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.dirname(SCRIPT_DIR))
import random
from typing import Any, Dict, List
from pathlib import Path

# cocotb
import cocotb
from cocotb.binary import BinaryValue
from cocotb.handle import SimHandleBase
from cocotb.queue import Queue
from cocotb.runner import get_runner
from cocotb.triggers import Timer, RisingEdge
from cocotb.types import Logic, Bit
from cocotb.clock import Clock

NUM_SAMPLES = int(os.environ.get("NUM_SAMPLES", 1000))
BUS_WIDTH   = int(os.environ.get("BUS_WIDTH", 8))

@cocotb.test()
async def CPU_test(dut : SimHandleBase):
    """Test Butterfly functionality."""

    Tperiod = 10

    # initial values
    dut.sw.value       = 0
    dut.ready_in.value = 0

    # create an instance of the tester
    dut._log.info("Initialize and reset model")

    # clock
    cocotb.start_soon(Clock(dut.clock, Tperiod, units="ns").start())
    # Reset DUT
    dut.n_reset.value = 0
    for _ in range(3):
        await RisingEdge(dut.clock)
    dut.n_reset.value = 1
        
    # start tester after reset so we know it's in a good state
    dut._log.info("Test Butterfly operations")

    # Do Butterfly operations
    for i, (op_sw, op_ready_in) in enumerate(zip(gen_s8(), gen_ready_in())):
        dut.sw.value       = op_sw
        dut.ready_in.value = op_ready_in   
        await RisingEdge(dut.clock)
        if not i % 10:
            dut._log.info(f"{i} / {NUM_SAMPLES}")


# generates a signed integer in the valid range for input a
def gen_s8():
    """Generate random data for the sw"""
    inputs = [
        BinaryValue('01000000', n_bits=BUS_WIDTH, binaryRepresentation=0, bigEndian=False), # re w
        BinaryValue('01000000', n_bits=BUS_WIDTH, binaryRepresentation=0, bigEndian=False), # im w, W = 0.5+0.5j
        BinaryValue('00000100', n_bits=BUS_WIDTH, binaryRepresentation=0, bigEndian=False), # re b
        BinaryValue('00000110', n_bits=BUS_WIDTH, binaryRepresentation=0, bigEndian=False), # im b, B = 4+6j
        BinaryValue('00000101', n_bits=BUS_WIDTH, binaryRepresentation=0, bigEndian=False), # re a 
        BinaryValue('00000001', n_bits=BUS_WIDTH, binaryRepresentation=0, bigEndian=False), # im a, A = 5+1j
    ]
    for i in range(NUM_SAMPLES):
        yield inputs[i % len(inputs)]

# generates a signed integer in the valid range for input a
def gen_ready_in():
    """Generate random data for the sw"""
    for i in range(NUM_SAMPLES):
        yield BinaryValue(random.randint(0,1), n_bits=1, binaryRepresentation=0, bigEndian=False)