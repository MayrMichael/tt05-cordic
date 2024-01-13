import cocotb
from bitstring import BitArray
from cocotb.triggers import Timer, FallingEdge, ClockCycles, RisingEdge
from cocotb.binary import BinaryValue, BinaryRepresentation 
from cocotb.clock import Clock

def unsigned2bin(x, n_bits):
    return BinaryValue(value=BitArray(uint=x, length=n_bits).bin, n_bits=n_bits)

async def reset_dut(reset_n, duration_ns):
    reset_n.value = 0
    await Timer(duration_ns, units="ns")
    reset_n.value = 1
    reset_n._log.info("Reset complete")

@cocotb.test()
async def test_spi_master(dut):
    n_samples = 16
    
    samples = list(range(n_samples))
    samples.extend([128, 255, 128, 255, 0])
    
    dut.data_in_valid_strobe_i.value = 0
    dut.data_i.value = unsigned2bin(0, 8)

    cocotb.start_soon(Clock(dut.clk_i, 10, units="ns").start())

    # reset dut
    await reset_dut(dut.rst_i, 20)

    await ClockCycles(dut.clk_i, 1)

    for i, n in enumerate(samples):
        dut.data_in_valid_strobe_i.value = 1
        dut.data_i.value = unsigned2bin(n, 8)
        await ClockCycles(dut.clk_i, 1)
        dut.data_in_valid_strobe_i.value = 0
        await ClockCycles(dut.clk_i, 40)
    
    dut._log.info('Test finished')