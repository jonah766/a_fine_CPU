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
            datas=dict(we=self.dut.we, wr_data=self.dut.wr_data, rd_addr=self.dut.rd_addr, rs_addr=self.dut.rs_addr)
        )
        self.read_monitor = ReadMonitor(
            clk=self.dut.clk,
            datas=dict(rd_data=self.dut.rd_data, rs_data=self.dut.rs_data)
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

    def model_read(self, rd_addr : BinaryValue, rs_addr : BinaryValue) -> Tuple[BinaryValue, BinaryValue]:
        """
        Transaction-level model of the w as instantiated
        """
        rd_data = rs_data = BinaryValue()
        
        if (rd_addr.integer == 0):
            rd_data = BinaryValue(0, n_bits=self.dut.rd_data.value.n_bits, bigEndian=False, binaryRepresentation=0)
        else:
            rd_data = self.dut.gpr[rd_addr.integer].value

        if (rs_addr.integer == 0):
            rs_data = BinaryValue(0, n_bits=self.dut.rs_data.value.n_bits, bigEndian=False, binaryRepresentation=0)
        else:
            rs_data = self.dut.gpr[rs_addr.integer].value
        
        return rd_data, rs_data

    async def _check(self) -> None:
        """asserts reads are correct (assumes if all reads are correct the writes are correct too)"""
        while True:
            inputs = await self.input_mon.values.get()  # input data to sim
            reads  = await self.read_monitor.values.get() # the read values (same cycle as input)
            
            # extract the supplied inputs
            we      = inputs["we"]
            wr_data = inputs["wr_data"]
            rd_addr = inputs["rd_addr"]
            rs_addr = inputs["rs_addr"]

            # compute the ideal read results
            exp_rd_data, exp_rs_data = self.model_read(rd_addr, rs_addr)

            # extract the actual results
            rd_data = reads["rd_data"]
            rs_data = reads["rs_data"]
            
            # make debug strings
            inputs_str = f" (inputs: {we}, {wr_data}, {rd_addr}, {rs_addr})"
            rd_data_str = f" (outputs: exp rd_data={exp_rd_data}, actual rd_data={rd_data})"
            rs_data_str = f" (outputs: exp rd_data={exp_rs_data}, actual rd_data={rs_data})"

            # assert that count is updated properly
            assert exp_rd_data == rd_data, "Read Data (1) ERROR!"+inputs_str+rd_data_str
            assert exp_rs_data == rs_data, "Read Data (2) ERROR!"+inputs_str+rs_data_str
            


@cocotb.test()
async def regs_test(dut : SimHandleBase):
    """Test regs functionality."""
    
    # create an instance of the tester
    tester = RegsTester(dut)
    dut._log.info("Initialize and reset model")

    # clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # initial values
    dut.we.value     = 0
    dut.wr_data.value  = 0
    dut.rd_addr.value = 0
    dut.rs_addr.value = 0
    for _ in range(3):
        await RisingEdge(dut.clk)

    # get size info
    N = dut.wr_data.value.n_bits

    # start tester after reset so we know it's in a good state
    tester.start()
    dut._log.info("Test regs operations")

    # Do multiplication operations
    for i, (we, data, addrs) in enumerate(zip(gen_we(), gen_wr_data(N), gen_read_addrs())):
        addr1, addr2 = addrs
        await RisingEdge(dut.clk)
        dut.we.value      = we
        dut.wr_data.value = data
        dut.rd_addr.value = addr1
        dut.rs_addr.value = addr2

        if i % 100 == 0:
            dut._log.info(f"{i} / {NUM_SAMPLES}")

    dut._log.info(f"regs final val: {[addr.value.binstr for addr in dut.gpr]}")

def gen_we(num_samples=NUM_SAMPLES) -> BinaryValue:
    for _ in range(num_samples):
        yield BinaryValue(random.randint(0,1), n_bits=1, bigEndian=False, binaryRepresentation=0)


def gen_wr_data(n : int, num_samples=NUM_SAMPLES) -> BinaryValue:
    """ wr_data is an n-bit vector """
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
        proj_path / ".." / ".." / "rtl" / "picoMIPS" / "Register_File.sv"
    ]

    BUS_WIDTH  = 8
    ADDR_WIDTH = 5
    extra_args = [ 
        f"-P Register_File.BUS_WIDTH={BUS_WIDTH} -P Register_File.ADDR_WIDTH={ADDR_WIDTH}",
        f"-I $(PWD)/../../include"
    ]

    runner = get_runner(sim)
    # build the test
    runner.build(
        verilog_sources=verilog_sources,
        hdl_toplevel="Register_File",
        build_args=extra_args,
        parameters=parameters,
        always=True,
    )
    # run the test
    runner.test(
        hdl_toplevel="Register_File", 
        hdl_toplevel_lang=hdl_toplevel_lang,
        test_module="regs_test"
    )


if __name__ == "__main__":
    # run the tests 
    regs_runner()