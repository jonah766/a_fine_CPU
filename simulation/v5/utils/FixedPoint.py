from fxpmath import Fxp

import os
BUS_WIDTH = int(os.environ.get("BUS_WIDTH", 8))

import cocotb
from cocotb.binary import BinaryValue

# types
fadd_t        = Fxp(None, signed=True, dtype=f'fxp-s{BUS_WIDTH+1}/0',                     overflow='wrap')
fcplx_add_t   = Fxp(None, signed=True, dtype=f'fxp-s{BUS_WIDTH+1}/0-complex',             overflow='wrap')
fmult_t       = Fxp(None, signed=True, dtype=f'fxp-s{2*BUS_WIDTH}/{BUS_WIDTH-1}',         overflow='wrap')
fcmplx_mult_t = Fxp(None, signed=True, dtype=f'fxp-s{2*BUS_WIDTH}/{BUS_WIDTH-1}-complex', overflow='wrap')
fint_t        = Fxp(None, signed=True, dtype=f'fxp-s{BUS_WIDTH}/0',                       overflow='wrap')
fcmplx_int_t  = Fxp(None, signed=True, dtype=f'fxp-s{BUS_WIDTH}/0-complex',               overflow='wrap')
ftf_t         = Fxp(None, signed=True, dtype=f'fxp-s{BUS_WIDTH}/{BUS_WIDTH-1}',           overflow='wrap')
fcmplx_tf_t   = Fxp(None, signed=True, dtype=f'fxp-s{BUS_WIDTH}/{BUS_WIDTH-1}-complex',   overflow='wrap')

def unpack_scomplex8_t(v : BinaryValue):
    v_as_str = v.binstr
    return v_as_str[BUS_WIDTH:],f"{v_as_str[0:BUS_WIDTH]}j"

def make_complex_int(re : str, im : str): 
    re_fp  = Fxp(f"0b{re}").like(fint_t)
    im_fp  = Fxp(f"0b{im[:-1]}").like(fint_t)
    return Fxp(complex(re_fp, im_fp)).like(fcmplx_int_t)

def make_complex_tf(re : str, im : str): 
    re_fp, im_fp = Fxp().like(ftf_t), Fxp().like(ftf_t)
    re_fp.equal(f"0b{re}")
    im_fp.equal(f"0b{im[:-1]}")
    return Fxp(complex(re_fp, im_fp)).like(fcmplx_tf_t)

def fixed_point_multiply(a, b):
    out = Fxp().like(fmult_t)
    out.equal(a * b)
    return Fxp(f"0b{out.bin()[1:BUS_WIDTH+1]}").like(fint_t)

def fixed_point_add(a, b): 
    out = Fxp().like(fadd_t)
    out.equal(a + b)
    return Fxp(f"0b{out.bin()[1:]}").like(fint_t)

def fixed_point_sub(a, b): 
    out = Fxp().like(fadd_t)
    out.equal(a - b)
    return Fxp(f"0b{out.bin()[1:]}").like(fint_t)

def fixed_point_complex_add(a, b):
    out = Fxp().like(fcplx_add_t)
    out.equal(a + b)
    re, im = str(out.bin()).split('+')
    return make_complex_int(re[1:], im[1:])

def fixed_point_complex_sub(a, b):
    out = Fxp().like(fcplx_add_t)
    out.equal(a - b)
    re, im = str(out.bin()).split('+')
    return make_complex_int(re[1:], im[1:])

def fixed_point_complex_multiply(a, b):
    # (a+jb)(c+jd) = (ac - bd)+j(ad + bc) - use this step by step approach since thats how the multiplier does it
    ac = fixed_point_multiply(a.real, b.real)
    bd = fixed_point_multiply(a.imag, b.imag)
    ad = fixed_point_multiply(a.real, b.imag)
    bc = fixed_point_multiply(a.imag, b.real)
    re = fixed_point_sub(ac, bd)
    im = fixed_point_add(ad, bc)
    return Fxp(complex(re, im)).like(fcmplx_mult_t)