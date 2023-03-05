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


class PCTester:
    """
    Reusable checker of a pc instance
    Args
        entity: handle to an instance of dut
    """
    def __init__(self, entity : SimHandleBase):
        self.dut = entity
        self.input_mon = InputMonitor(
            clk=self.dut.clk,
            datas=dict(PCincr=self.dut.PCincr, PCabsbranch=self.dut.PCabsbranch, PCrelbranch=self.dut.PCrelbranch, Branchaddr=self.dut.Branchaddr),
        )
        self.output_mon = OutputMonitor(
            clk=self.dut.clk,
            datas=dict(PCout=self.dut.PCout)
        )
        self._prev_count = BinaryValue(0, n_bits=self.dut.PCout.value.n_bits, bigEndian=False, binaryRepresentation=0)
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

    def model(self, prev_count : BinaryValue, incr : Bit, absbranch : Bit, relbranch : Bit, addr : BinaryValue) -> BinaryValue:
        """
        Transaction-level model of the pc as instantiated
            > Treat the count as unsigned and the branch addr as signed, then adjust for wrap around
        """
        next_count = 0
        if (incr):
            next_count = prev_count.integer + 1
        elif (absbranch):
            next_count = addr.signed_integer
        elif (relbranch):
            next_count = prev_count.integer + addr.signed_integer
    
        # correct overflow and underflow (wrap around)
        n = self.dut.PCout.value.n_bits
        if (next_count < 0):
            next_count = next_count + pow(2,n)
        elif (next_count > pow(2,n)-1):
           next_count = next_count - pow(2,n)

        return BinaryValue(next_count, n_bits=self.dut.PCout.value.n_bits, bigEndian=False, binaryRepresentation=0)


    async def _check(self) -> None:
        """checks the actual results are equal to the modelled expected result"""
        while True:
            actual = await self.output_mon.values.get() # results from sim
            inputs = await self.input_mon.values.get()  # input data to sim
            
            # extract the supplied inputs
            PCincr      = Bit(inputs["PCincr"].binstr)
            PCabsbranch = Bit(inputs["PCabsbranch"].binstr)
            PCrelbranch = Bit(inputs["PCrelbranch"].binstr)
            Branchaddr  = inputs["Branchaddr"]

            # compute the ideal results
            exp_PCout = self.model(
               prev_count=self._prev_count, incr=PCincr, absbranch=PCabsbranch, relbranch=PCrelbranch, addr=Branchaddr
            )

            # extract the actual results
            PCout = actual["PCout"]
            
            # make debug strings
            inputs_str  = f" (inputs: count={self._prev_count}, {PCincr}, {PCabsbranch}, {PCrelbranch}, {Branchaddr}) "
            outputs_str = f" (outputs: exp={exp_PCout}, actual count={PCout})"

            # assert that count is updated properly
            assert exp_PCout.integer == PCout.integer, "COUNTER ERROR!"+inputs_str+outputs_str
            self._prev_count = PCout


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

    # initial values
    dut.PCincr.value      = 0
    dut.PCabsbranch.value = 0
    dut.PCrelbranch.value = 0
    dut.Branchaddr.value  = 0

    # get size info
    Psize = dut.PCout.value.n_bits

    # start tester after reset so we know it's in a good state
    tester.start()
    dut._log.info("Test alu operations")

    # Do multiplication operations
    for i, (ctrl, addr) in enumerate(zip(gen_control_signals(), gen_branch_addr(Psize))):
        incr, absbranch, relbranch = ctrl.binstr
        await RisingEdge(dut.clk)
        dut.PCincr.value      = BinaryValue(incr)
        dut.PCabsbranch.value = BinaryValue(absbranch)
        dut.PCrelbranch.value = BinaryValue(relbranch)
        dut.Branchaddr.value  = addr.signed_integer

        if i % 100 == 0:
            dut._log.info(f"{i} / {NUM_SAMPLES}")


# generates a signed integer in the valid range for input a
def gen_control_signals(num_samples=NUM_SAMPLES) -> BinaryValue:
    """Only one control signal should be activated at once"""
    for _ in range(num_samples):
        v = random.randint(0,2)
        match(v):
            case 0: yield BinaryValue("001")  
            case 1: yield BinaryValue("010")
            case 2: yield BinaryValue("100")
            case _: raise Exception("invalid random value")


# generates a signed integer in the valid range for input a
def gen_branch_addr(Psize : int, num_samples=NUM_SAMPLES) -> BinaryValue:
    """Generate random data for a"""
    for _ in range(num_samples):
        branchVal = random.randint(pow(-2,(Psize-1)), pow(2,(Psize-1))-1)
        if (branchVal == 0):
            yield BinaryValue(branchVal, n_bits=Psize, bigEndian=False, binaryRepresentation=0)
        else:
            yield BinaryValue(branchVal, n_bits=Psize, bigEndian=False, binaryRepresentation=2)


# build and run the simulation
def PC_runner():

    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent

    verilog_sources = [
        proj_path / ".." / ".." / "rtl" / "picoMIPS" / "pc.sv"
    ]

    Psize = 6
    extra_args = [ -f"P pc.Psize={Psize}" ]

    runner = get_runner(sim)
    # build the test
    runner.build(
        verilog_sources=verilog_sources,
        hdl_toplevel="pc",
        build_args=extra_args,
        parameters=parameters,
        always=True,
    )
    # run the test
    runner.test(
        hdl_toplevel="pc", 
        hdl_toplevel_lang=hdl_toplevel_lang,
        test_module="PC_test"
    )


if __name__ == "__main__":
    # run the tests 
    PC_runner()