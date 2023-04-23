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

# user
from utils import *  

# external 
from fxpmath import Fxp
import numpy as np

@cocotb.test()
async def CPU_test(dut : SimHandleBase):
    """Test CPU value functionality."""

    # initial values
    dut.in_port.value  = 0
    dut.ready_in.value = 0

    # create an instance of the tester
    A = np.array([[0.75, 0.5], [-0.5, 0.75]], dtype=float)
    B = np.array([20, -20], dtype=int)
    dut._log.info("Initialize and reset model")

    # clock
    Tperiod = 10    
    cocotb.start_soon(Clock(dut.clk, Tperiod, units="ns").start())
    
    # Reset DUT
    dut.n_reset.value = 0
    for _ in range(3):
        await RisingEdge(dut.clk)
    dut.n_reset.value = 1
        
    # start tester after reset so we know it's in a good state
    dut._log.info("Test Butterfly operations")

    # generate an array of random stimulus
    sw = np.random.randint(pow(-2,((BUS_WIDTH)-1)), pow(2,((BUS_WIDTH)-1)), 100, dtype=int)

    # Do Butterfly operations
    ready_in_cnt = 0
    inputs  = np.zeros(2, dtype=int)
    outputs = np.zeros(2, dtype=int)
    for j, op_sw in np.ndenumerate(sw):
        i = j[0]

        # setup the inputs with random amounts of delay in between
        for _ in range(random.randint(1, 10)):
            dut.ready_in.value = 0   
            await RisingEdge(dut.clk)

        # assert the input values, note the input values
        inputs[i%2] = op_sw.item()
        dut.in_port.value = op_sw.item()
        dut.ready_in.value = 1   
        ready_in_cnt += 1
        await RisingEdge(dut.clk)

        # if we have provided two inputs wait for computation
        if not (ready_in_cnt % 2):
            dut.ready_in.value = 0
            for _ in range(9): await RisingEdge(dut.clk)
        
            # note the first output
            for _ in range(3): await RisingEdge(dut.clk)
            outputs[0] = dut.out_port.value.signed_integer

            # wait for ready_in == 1
            while True:
                dut.ready_in.value = random.randint(0,1)   
                if (dut.ready_in.value == 1): break
                await RisingEdge(dut.clk)

            # note the second output
            for _ in range(3): await RisingEdge(dut.clk)
            outputs[1] = dut.out_port.value.signed_integer

            # assert the test
            ideal = model(inputs)
            dut._log.info(f"inputs = {inputs}, outputs = {outputs}, ideal = {ideal}\n")
            assert (outputs == ideal).all(), f"incorrect values! inputs = {inputs}, outputs = {outputs}, ideal = {ideal}"

        if not i % 10:
            dut._log.info(f"{i} / {NUM_SAMPLES}")

def model(inputs):
    # first row
    c1 = fixed_point_multiply(Fxp(int(inputs[0])).like(fint_t), Fxp(0.75).like(ftf_t))
    c2 = fixed_point_multiply(Fxp(int(inputs[1])).like(fint_t), Fxp(0.5).like(ftf_t))
    # second row
    c3 = fixed_point_multiply(Fxp(int(inputs[0])).like(fint_t), Fxp(-0.5).like(ftf_t))
    c4 = fixed_point_multiply(Fxp(int(inputs[1])).like(fint_t), Fxp(0.75).like(ftf_t))
    # sum resulting values
    c5 = fixed_point_add(c1, c2)
    c6 = fixed_point_add(c3, c4)
    # add offset
    x2 = fixed_point_add(c5, Fxp(20).like(fint_t))
    y2 = fixed_point_add(c6, Fxp(-20).like(fint_t))
    # results
    return np.array([x2, y2])