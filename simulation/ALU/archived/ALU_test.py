import os
import random
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.runner import get_runner
from cocotb.triggers import FallingEdge
from cocotb.triggers import Timer

# extract the func codes and generate a dictionary
func_codes = {}
proj_path = Path(__file__).resolve().parent
with open(proj_path / "../../include/alucodes.sv" , "r") as func_codes_f:
    for line in func_codes_f:
        toks = line.split(" ")  
        if ("`define" in line and len(toks) == 3):       
            [_, code, binstr] = toks
            func_code_int = int(binstr.split('b')[-1], 2)
            func_codes[code] = func_code_int
            
@cocotb.test()
async def test_arithmetic_op(dut):
    """
    Test cases:
    (1) RA -> result is register in A
    (2) RB -> result is reguister in B
    (3) RADD -> result is A+B
    (4) RSUB -> result is A-B
    (5) RAND -> result is A AND B
    (5) ROR -> result is A OR B
    (5) RXOR -> result is A XOR B
    (5) RNOR -> result is A NOR B
    """
    n = dut.result.value.n_bits
    for i in range(1000):
        # generate some random data
        a = random.randint(pow(-2,(n-1)), pow(2,(n-1)-1))
        b = random.randint(pow(-2,(n-1)), pow(2,(n-1)-1))
        func = random.choice(list(func_codes.values()))
        
        # write data to the ALU
        dut.a.value = a
        dut.b.value = b
        dut.func.value = func

        await Timer(10, units="ns")

        # get aliases to the outputs
        error_str = f"output 'result' was not correct for opcode {func}"
        res = dut.result.value
        [V,N,Z] = dut.flags.value.binstr

        # only test when there is no overflow and no carry
        if (V == '0'):
            # process the result
            if (func == func_codes["RA"]):
                assert res.signed_integer == a, error_str
            elif (func == func_codes["RB"]):
                assert res.signed_integer == b, error_str
            elif (func == func_codes["RADD"]):
                assert res.signed_integer == a + b, error_str
            elif (func == func_codes["RSUB"]):
                assert res.signed_integer == a - b, error_str
            elif (func == func_codes["RAND"]):
                assert res.signed_integer == a & b, error_str
            elif (func == func_codes["ROR"]):
                assert res.signed_integer == a | b, error_str
            elif (func == func_codes["RXOR"]):
                assert res.signed_integer == a ^ b, error_str
            elif (func == func_codes["RNOR"]):
                assert res.signed_integer == ~(a | b), error_str
            else:
                raise Exception("Invalid function code provided!")
    
@cocotb.test()
async def test_flags(dut):
    """
    There are four flags, with the following conditions
    (1) (Z)ero - dut.result = '0
    (2) O(V)erflow - dut.result overflows
    (3) (C)arry - carry on the MSB of dut.result (not being tested as irrelevant for signed arithmetic)
    (4) (N)egative - dut.result is negative
    """ 
    n = dut.result.value.n_bits
    for i in range(1000):

        # generate some random data
        a = random.randint(pow(-2,(n-1)), pow(2,(n-1)-1))
        b = random.randint(pow(-2,(n-1)), pow(2,(n-1)-1))
        func = random.choice(list(func_codes.values()))

        # write data to the ALU
        dut.a.value = a
        dut.b.value = b
        dut.func.value = func

        await Timer(10, units="ns")

        # get aliases to the outputs
        res = dut.result.value
        [V,N,Z] = dut.flags.value.binstr

        # test zero flag
        if (res.signed_integer == 0):
            assert Z == '1', f"zero flag not asserted for res: {res.binstr}"
        else:
            assert Z == '0', f"zero flag not deasserted for res: {res.binstr}"

        # test negative flag
        if (res.signed_integer < 0):
            assert N == '1', f"negative flag not asserted for res: {res.binstr}"
        else:
            assert N == '0', f"negative flag not deasserted for res: {res.binstr}"

        # test overflow flag - like carry but inputs must be the same sign
        """
        Overflow occurs when:
        (1) sum of two positive numbers yields a negative result
        (2) sum of two netative numbers yields a positive result
        (3) subtraction of a positive from a negative yields a positive result
        (4) subtraction of a negative from a positive yields a negative result
        """
        if (func == func_codes["RADD"]):
            if (a >= 0 and b >= 0 and res.signed_integer < 0):
                assert V == '1', f"Overflow flag not asserted when adding two positive nums ({a},{b}) and got negative result ({res.signed_integer})"
            elif(a < 0 and b < 0 and res.signed_integer >= 0):
                assert V == '1', f"Overflow flag not asserted when adding two negative nums ({a},{b}) and got positive result ({res.signed_integer})"
            else:
                assert V == '0', f"Overflow flag not deasserted when adding two numbers of differing signs ({a},{b})"            
        elif(func == func_codes["RSUB"]):
            if (a < 0 and b >= 0 and res.signed_integer >= 0):
                assert V == '1', f"Overflow flag not asserted when subtracting a positive num ({b}) from {a} and got a positive result ({res.signed_integer})"
            elif (a >= 0 and b < 0 and res.signed_integer < 0):
                assert V == '1', f"Overflow flag not asserted when subtracting a negative num ({b}) from {a} and got a negative result ({res.signed_integer})"
            else:
                assert V == '0', f"Overflow flag not deasserted when subtracting numbers ({a},{b})"   
        else:
            assert V == '0', f"Overflow flag not deasserted when func is {func}"


# build and run the simulation
def ALU_runner():

    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent
    print(f"Project path: {proj_path}")

    verilog_sources = [
        proj_path / "../../rtl/picoMIPS/alu.sv"
    ]

    runner = get_runner(sim)
    runner.build(
        verilog_sources=verilog_sources,
        hdl_toplevel="alu",
        always=True,
    )

    runner.test(hdl_toplevel="alu", test_module="ALU_test,")


if __name__ == "__main__":
    # run the tests 
    ALU_runner()