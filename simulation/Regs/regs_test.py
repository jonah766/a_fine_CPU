import os
import random
import math
import sys
import random
from typing import Any, Dict, List, Tuple
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

class ReadMonitor(DataMonitor):
    """
    Read monitor clocks on first edge
    """

class RegsTester:
    """
    Reusable checker of a regs instance
    Args
        entity: handle to an instance of dut
    """
    def __init__(self, entity : SimHandleBase):
        self.dut = entity
        self.input_mon = InputMonitor(
            clk=self.dut.clk,
            datas=dict(w=self.dut.w, Wdata=self.dut.Wdata, Raddr1=self.dut.Raddr1, Raddr2=self.dut.Raddr2)
        )
        self.read_monitor = ReadMonitor(
            clk=self.dut.clk,
            datas=dict(Rdata1=self.dut.Rdata1, Rdata2=self.dut.Rdata2)
        )
        self._checker = None

    def start(self) -> None:
        """Starts monitors, model, and checker coroutine"""
        if self._checker is not None:
            raise RuntimeError("Monitor already started")
        self.input_mon.start()
        self.read_monitor.start()
        self._checker = cocotb.start_soon(self._check())

    def stop(self) -> None:
        """Stops everything"""
        if self._checker is None:
            raise RuntimeError("Monitor never started")
        self.input_mon.stop()
        self.read_monitor.stop()
        self._checker.kill()
        self._checker = None

    def model_read(self, Raddr1 : BinaryValue, Raddr2 : BinaryValue) -> Tuple[BinaryValue, BinaryValue]:
        """
        Transaction-level model of the w as instantiated
        """
        Rdata1 = Rdata2 = BinaryValue()
        
        if (Raddr1.integer == 0):
            Rdata1 = BinaryValue(0, n_bits=self.dut.Rdata1.value.n_bits, bigEndian=False, binaryRepresentation=0)
        else:
            Rdata1 = self.dut.gpr[Raddr1.integer].value

        if (Raddr2.integer == 0):
            Rdata2 = BinaryValue(0, n_bits=self.dut.Rdata2.value.n_bits, bigEndian=False, binaryRepresentation=0)
        else:
            Rdata2 = self.dut.gpr[Raddr2.integer].value
        
        return Rdata1, Rdata2

    async def _check(self) -> None:
        """asserts reads are correct (assumes if all reads are correct the writes are correct too)"""
        while True:
            inputs = await self.input_mon.values.get()  # input data to sim
            reads  = await self.read_monitor.values.get() # the read values (same cycle as input)
            
            # extract the supplied inputs
            w      = inputs["w"]
            Wdata  = inputs["Wdata"]
            Raddr1 = inputs["Raddr1"]
            Raddr2 = inputs["Raddr2"]

            # compute the ideal read results
            exp_Rdata1, exp_Rdata2 = self.model_read(Raddr1, Raddr2)

            # extract the actual results
            Rdata1 = reads["Rdata1"]
            Rdata2 = reads["Rdata2"]
            
            # make debug strings
            inputs_str = f" (inputs: {w}, {Wdata}, {Raddr1}, {Raddr2}) "
            rdata1_str = f" (outputs: exp rdata1={exp_Rdata1}, actual rdata1={Rdata1})"
            rdata2_str = f" (outputs: exp rdata1={exp_Rdata2}, actual rdata1={Rdata2})"

            # assert that count is updated properly
            assert exp_Rdata1 == Rdata1, "Read Data (1) ERROR!"+inputs_str+rdata1_str
            assert exp_Rdata2 == Rdata2, "Read Data (2) ERROR!"+inputs_str+rdata2_str
            


@cocotb.test()
async def regs_test(dut : SimHandleBase):
    """Test regs functionality."""
    
    # create an instance of the tester
    tester = RegsTester(dut)
    dut._log.info("Initialize and reset model")

    # clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # initial values
    dut.w.value      = 0
    dut.Wdata.value  = 0
    dut.Raddr1.value = 0
    dut.Raddr2.value = 0
    for _ in range(3):
        await RisingEdge(dut.clk)

    # get size info
    N = dut.Wdata.value.n_bits

    # start tester after reset so we know it's in a good state
    tester.start()
    dut._log.info("Test regs operations")

    # Do multiplication operations
    for i, (w, data, addrs) in enumerate(zip(gen_w(), gen_wdata(N), gen_read_addrs())):
        addr1, addr2 = addrs
        await RisingEdge(dut.clk)
        dut.w.value      = w
        dut.Wdata.value  = data
        dut.Raddr1.value = addr1
        dut.Raddr2.value = addr2

        if i % 100 == 0:
            dut._log.info(f"{i} / {NUM_SAMPLES}")

    dut._log.info(f"regs final val: {[addr.value.binstr for addr in dut.gpr]}")

def gen_w(num_samples=NUM_SAMPLES) -> BinaryValue:
    for _ in range(num_samples):
        yield BinaryValue(random.randint(0,1), n_bits=1, bigEndian=False, binaryRepresentation=0)


def gen_wdata(n : int, num_samples=NUM_SAMPLES) -> BinaryValue:
    """ wdata is an n-bit vector """
    for _ in range(num_samples):
        branchVal = random.randint(0, pow(2,n)-1)
        yield BinaryValue(branchVal, n_bits=n, bigEndian=False, binaryRepresentation=0)


def gen_read_addrs(num_samples=NUM_SAMPLES) -> Tuple[BinaryValue, BinaryValue]:
    """ read addrs are 5-bit vectors """
    for _ in range(num_samples):
        addr1 = BinaryValue(random.randint(0, pow(2,5)-1), n_bits=5, bigEndian=False, binaryRepresentation=0)
        addr2 = BinaryValue(random.randint(0, pow(2,5)-1), n_bits=5, bigEndian=False, binaryRepresentation=0)
        yield addr1, addr2


# build and run the simulation
def regs_runner():

    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent

    verilog_sources = [
        proj_path / ".." / ".." / "rtl" / "picoMIPS" / "regs.sv"
    ]

    N = 8
    extra_args = [ -f"P regs.n={N}" ]

    runner = get_runner(sim)
    # build the test
    runner.build(
        verilog_sources=verilog_sources,
        hdl_toplevel="regs",
        build_args=extra_args,
        parameters=parameters,
        always=True,
    )
    # run the test
    runner.test(
        hdl_toplevel="regs", 
        hdl_toplevel_lang=hdl_toplevel_lang,
        test_module="regs_test"
    )


if __name__ == "__main__":
    # run the tests 
    regs_runner()