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
from cocotb.triggers import Timer
from cocotb.types import Logic, Bit

NUM_SAMPLES = int(os.environ.get("NUM_SAMPLES", 1000))

class DataValidMonitor:
    """
    Reusable Monitor of one-way control flow (data/valid) streaming data interface
    Args
        datas: named handles to be sampled when transaction occurs
    """
    def __init__(
        self, datas: Dict[str, SimHandleBase]
    ):
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
            await Timer(10, units="ns")
            self.values.put_nowait(self._sample())

    def _sample(self) -> Dict[str, Any]:
        """
        Samples the data signals and builds a transaction object
        Return value is what is stored in queue. Meant to be overriden by the user.
        """
        return { 
            name: handle.value for name, handle in self._datas.items()
        }

class ALUTester:
    """
    Reusable checker of a alu instance
    Args
        alu_entity: handle to an instance of alu
        func_codes: dictionary of function code string to int
    """

    def __init__(self, alu_entity : SimHandleBase, func_codes : Dict[str, int]):
        self.dut = alu_entity
        self.input_mon = DataValidMonitor(
            datas=dict(op_a=self.dut.a, op_b=self.dut.b, func=self.dut.func),
        )
        self.output_mon = DataValidMonitor(
            datas=dict(result=self.dut.result, flags=self.dut.flags)
        )
        self._func_codes = func_codes
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

    def model(self, op_a: int, op_b: int, func: int) -> tuple[int, Bit, Bit, Bit]:
        """Transaction-level model of the alu as instantiated"""
        n = self.dut.result.value.n_bits
        res_max = pow(2, (n-1))-1
        res_min = pow(-2,(n-1))
        
        # process the result
        res = 0
        func_str = list(self._func_codes.keys())[list(self._func_codes.values()).index(func)]
        match(func_str):
            case "RA"  : res = op_a
            case "RB"  : res = op_b
            case "RADD": res = op_a + op_b
            case "RSUB": res = op_a - op_b
            case "RAND": res = op_a & op_b
            case "ROR" : res = op_a | op_b
            case "RXOR": res = op_a ^ op_b
            case "RNOR": res = ~(op_a | op_b)
            case _: raise Exception("Invalid function code provided!")
        
        # process the flags
        V = N = Z = Bit(0)
        if (res == 0): Z = Bit(1)
        # handle wrap-around 
        if (res > res_max):
            res = res - 2*(res_max+1)
        elif (res < res_min):
            res = res + 2*(res_max+1)
        # now compute negative    
        if (res < 0): N = Bit(1)
        # only care about V for add or sub
        match(func_str):
            case "RADD":
                if (op_a + op_b > res_max or op_a + op_b < res_min): V = Bit(1)               
            case "RSUB":
                if (op_a - op_b > res_max or op_a - op_b < res_min): V = Bit(1)
        
        # return the expected values as a tuple
        return res, V, N, Z

    async def _check(self) -> None:
        """checks the actual results are equal to the modelled expected result"""
        while True:
            actual = await self.output_mon.values.get() # results from sim
            inputs = await self.input_mon.values.get()  # input data to sim
            
            # extract the supplied inputs
            a    = inputs["op_a"].signed_integer
            b    = inputs["op_b"].signed_integer
            func = inputs["func"].integer

            # compute the ideal results
            exp_result, exp_V, exp_N, exp_Z = self.model(op_a=a, op_b=b, func=func)

            # extract the actual results
            result    = actual["result"].signed_integer
            [V, N, Z] = actual["flags"].binstr

            # make debug strings
            inputs_str  = f" (inputs: a = {a}, b = {b}, func = {func}) "
            outputs_str = f" (outputs: exp res = {exp_result}, actual res = {result}, exp flags = {[exp_V,exp_N,exp_Z]}, actual flags = {[V,N,Z]})"

            # assert that all the flags are correct
            assert Bit(V) == exp_V,  "OVERFLOW ERROR!"+inputs_str+outputs_str
            assert Bit(N) == exp_N,  "NEGATIVE ERROR!"+inputs_str+outputs_str
            assert Bit(Z) == exp_Z,  "ZERO ERROR!"+inputs_str+outputs_str
            # only care about the result if there is no overflow
            if (V == '0'):
                assert result == exp_result, "RESULT ERROR!"+inputs_str+outputs_str


@cocotb.test()
async def alu_test(dut : SimHandleBase):
    """Test alu functionality."""

    # generate the function codes dictionary
    func_codes = {}
    proj_path = Path(__file__).resolve().parent
    with open(proj_path / "../../include/alucodes.sv" , "r") as func_codes_f:
        for line in func_codes_f:
            toks = line.split(" ")  
            if ("`define" in line and len(toks) == 3):       
                [_, code, binstr] = toks
                func_code_int = int(binstr.split('b')[-1], 2)
                func_codes[code] = func_code_int

    # initial values
    dut.a.value    = 0
    dut.b.value    = 0
    dut.func.value = 0

    # create an instance of the tester
    tester = ALUTester(dut, func_codes)
    dut._log.info("Initialize and reset model")

    # bus width
    n = dut.a.value.n_bits

    # start tester after reset so we know it's in a good state
    tester.start()
    dut._log.info("Test alu operations")

    # Do multiplication operations
    for i, (op_a, op_b, func) in enumerate(zip(gen_a(n), gen_b(n), gen_func(func_codes))):
        await Timer(10, units="ns")
        dut.a.value    = op_a
        dut.b.value    = op_b
        dut.func.value = func
        
        if i % 100 == 0:
            dut._log.info(f"{i} / {NUM_SAMPLES}")

# generates a signed integer in the valid range for input a
def gen_a(n : int, num_samples=NUM_SAMPLES) -> int:
    """Generate random data for a"""
    for _ in range(num_samples):
        yield random.randint(pow(-2,(n-1)), pow(2,(n-1))-1)

# generates a signed integer in the valid range for input b
def gen_b(n : int, num_samples=NUM_SAMPLES) -> int:
    """Generate random data for b"""
    for _ in range(num_samples):
        yield random.randint(pow(-2,(n-1)), pow(2,(n-1))-1)

# generates a func code as an integer from the func_codes dictionary
def gen_func(func_codes : Dict[str, int], num_samples=NUM_SAMPLES) -> int:
    for _ in range(num_samples):
        yield random.choice(list(func_codes.values()))


# build and run the simulation
def ALU_runner():

    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent

    verilog_sources = [
        proj_path / ".." / ".." / "rtl" / "picoMIPS" / "alu.sv"
    ]

    N = 8
    extra_args = [ -f"P alu.n={N}", f"-I {proj_path}/../../include" ]

    runner = get_runner(sim)
    # build the test
    runner.build(
        verilog_sources=verilog_sources,
        hdl_toplevel="alu",
        build_args=extra_args,
        parameters=parameters,
        always=True,
    )
    # run the test
    runner.test(
        hdl_toplevel="alu", 
        hdl_toplevel_lang=hdl_toplevel_lang,
        test_module="ALU_test"
    )


if __name__ == "__main__":
    # run the tests 
    ALU_runner()