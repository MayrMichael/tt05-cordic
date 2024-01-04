import cocotb
import numpy as np
import cordic
from  bitstring import BitArray
from cocotb.triggers import Timer, FallingEdge, ClockCycles, RisingEdge
from cocotb.binary import BinaryValue, BinaryRepresentation 
from cocotb.clock import Clock

def frac2bin(x, sfixed_fract, frac_bits):
    return BinaryValue(value=BitArray(int=int(x * 2**sfixed_fract), length=frac_bits).bin, n_bits=frac_bits, binaryRepresentation=BinaryRepresentation.TWOS_COMPLEMENT )

def unsigned2bin(x, n_bits):
    return BinaryValue(value=BitArray(uint=x, length=n_bits).bin, n_bits=n_bits)

async def reset_dut(reset_n, duration_ns):
    reset_n.value = 0
    await Timer(duration_ns, units="ns")
    reset_n.value = 1
    reset_n._log.info("Reset complete")

@cocotb.test()
async def cosim_cordic_iterative(dut):
    iterations = 6
    sfixed_fract = 7
    phase = 0.308807373046875
    FRAC_BITS = sfixed_fract + 1

    lsb = 2**(-sfixed_fract)
    shift_vector = cordic.gen_shift_vector(iterations)
    k = cordic.gen_k(shift_vector, lsb)
    angles_vector = cordic.gen_angles_vector(shift_vector, lsb)

    xi = cordic.quantize_value(1.0 - lsb, lsb)
    yi = cordic.quantize_value(0, lsb)
    zi = cordic.quantize_value(0, lsb)

    xi = cordic.quantize_value(xi * k, lsb)
    xi = cordic.quantize_value(xi - lsb, lsb)
    
    zi = cordic.quantize_value(zi + phase, lsb)

    xo, yo, zo = cordic.cordic(xi,yi,zi, angles_vector, shift_vector, iterations, sfixed_fract)


    dut.x_i.value = frac2bin(xi, sfixed_fract, FRAC_BITS)
    dut.y_i.value = frac2bin(yi, sfixed_fract, FRAC_BITS)
    dut.z_i.value = frac2bin(zi, sfixed_fract, FRAC_BITS)
    dut.data_in_valid_strobe_i = 0


    cocotb.start_soon(Clock(dut.clk_i, 10, units="ns").start())

    # reset dut
    await reset_dut(dut.rst_i, 20)

    await FallingEdge(dut.clk_i)
    dut.data_in_valid_strobe_i = 1
    await FallingEdge(dut.clk_i)
    dut.data_in_valid_strobe_i = 0

    await RisingEdge(dut.data_out_valid_strobe_o)

    # dut._log.info(dut.x_o.value.binstr)
    dut._log.info(frac2bin(xo[0], sfixed_fract, FRAC_BITS).binstr)
    # dut._log.info(dut.y_o.value.binstr)
    dut._log.info(frac2bin(yo[0], sfixed_fract, FRAC_BITS).binstr)
    # dut._log.info(dut.z_o.value.binstr)
    # dut._log.info(frac2bin(zo[iterations], sfixed_fract, FRAC_BITS).binstr)
    assert dut.z_o.value.binstr == frac2bin(zo[iterations], sfixed_fract, FRAC_BITS).binstr
    assert dut.y_o.value.binstr == frac2bin(yo[iterations], sfixed_fract, FRAC_BITS).binstr
    assert dut.x_o.value.binstr == frac2bin(xo[iterations], sfixed_fract, FRAC_BITS).binstr
    
    dut._log.info('Test finished')
    

