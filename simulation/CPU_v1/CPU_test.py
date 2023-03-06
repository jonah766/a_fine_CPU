import os
import random
import math
import sys
import random
from typing import Any, Dict, List
from pathlib import Path

import cocotb
from cocotb.binary import BinaryValue
from cocotb.handle import SimHandleBase
from cocotb.queue import Queue
from cocotb.runner import get_runner
from cocotb.triggers import RisingEdge
from cocotb.types import Bit
from cocotb.clock import Clock

NUM_SAMPLES = int(os.environ.get("NUM_SAMPLES", 1000))

class DataMonitor:
    """
    Reusable Monitor of one-way control flow (data/valid) streaming data interface
    Args
        datas: named handles to be sampled when transaction occurs
    """
    def __init__(
        self, clk: SimHandleBase, datas: Dict[str, SimHandleBase]
    ):
        self._clk = clk
        self.values = Queue[Dict[str, BinaryValue]]()
        self._datas = datas
        self._coro = None

    def start(self) -> None:
        """Start monitor"""
        if self._coro is not None:
            raise RuntimeError("Monitor already started")
        self._coro = cocotb.start_soon(self._run())

    def stop(self) -> None:
        """Stop monitor"""
        if self._coro is None:
            raise RuntimeError("Monitor never started")
        self._coro.kill()
        self._coro = None

    async def _run(self) -> None:
        while True:
            await RisingEdge(self._clk)
            self.values.put_nowait(self._sample())

    def _sample(self) -> Dict[str, BinaryValue]:
        """
        Samples the data signals and builds a transaction object
        Return value is what is stored in queue. Meant to be overriden by the user.
        """
        return { 
            name: handle.value for name, handle in self._datas.items()
        }


class InputMonitor(DataMonitor):
    """
    Input monitor clocks on first edge
    """
    async def _run(self) -> None:
        while True:
            await RisingEdge(self._clk)
            self.values.put_nowait(self._sample())


class OutputMonitor(DataMonitor):
    """
    Output monitor clocks on first+1 edge
    """
    async def _run(self) -> None:
        await RisingEdge(self._clk) # one cycle behind
        while True: 
            await RisingEdge(self._clk)
            self.values.put_nowait(self._sample())


class CPUTester:
    """
    Reusable checker of a pc instance
    Args
        entity: handle to an instance of dut
    """
    def __init__(self, entity : SimHandleBase):
        self.dut = entity
        self.Program_Count
        self.regs = []

        self.input_mon = InputMonitor(
            clk=self.dut.clk,
            datas=dict(PC_out=self.dut.PC_out),
        )
        self.output_mon = OutputMonitor(
            clk=self.dut.clk,
            datas=dict(out_port=self.dut.out_port)
        )
        self._checker = None

    def start(self) -> None:
        """Starts monitors, model, and checker coroutine"""
        if self._checker is not None:
            raise RuntimeError("Monitor already started")
        self.input_mon.start()
        self.output_mon.start()
        self._checker = cocotb.start_soon(self._check())

    def stop(self) -> None:
        """Stops everything"""
        if self._checker is None:
            raise RuntimeError("Monitor never started")
        self.input_mon.stop()
        self.output_mon.stop()
        self._checker.kill()
        self._checker = None

    def model(self) -> BinaryValue:
        """
        Transaction-level model of the CPU as instantiated
            > Treat the count as unsigned and the branch addr as signed, then adjust for wrap around
        """

    async def _check(self) -> None:
        """checks the actual results are equal to the modelled expected result"""
        while True:
            outputs = await self.output_mon.values.get() # results from sim
            inputs  = await self.input_mon.values.get()  # input data to sim

            # extract the supplied inputs
            PC_incr       = Bit(inputs["PC_incr"].binstr)
            PC_abs_branch = Bit(inputs["PC_abs_branch"].binstr)
            PC_rel_branch = Bit(inputs["PC_rel_branch"].binstr)
            branch_addr   = inputs["branch_addr"]

@cocotb.test()
async def pc_test(dut : SimHandleBase):
    """Test pc functionality."""
    
    # create an instance of the tester
    tester = PCTester(dut)
    dut._log.info("Initialize and reset model")

    # clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Reset DUT
    dut.reset.value = 1
    for _ in range(3):
        await RisingEdge(dut.clk)
    dut.reset.value = 0

    # get size info
    ADDR_WIDTH = dut.PC_out.value.n_bits

    # start tester after reset so we know it's in a good state
    tester.start()
    dut._log.info("Test alu operations")

    # Do multiplication operations
    for i, (ctrl, addr) in enumerate(zip(gen_control_signals(), gen_branch_addr(ADDR_WIDTH))):
        incr, absbranch, relbranch = ctrl.binstr
        await RisingEdge(dut.clk)
        dut.PC_incr.value       = BinaryValue(incr)
        dut.PC_abs_branch.value = BinaryValue(absbranch)
        dut.PC_rel_branch.value = BinaryValue(relbranch)
        dut.branch_addr.value   = addr.signed_integer

        if i % 100 == 0:
            dut._log.info(f"{i} / {NUM_SAMPLES}")



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