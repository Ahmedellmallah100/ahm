# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):

    dut._log.info("Start")

    # Clock: 10 us period = 100 KHz
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # -------------------------------------------------
    # Reset
    # -------------------------------------------------
    dut._log.info("Reset")

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    # Active-low reset
    dut.rst_n.value = 0

    await ClockCycles(dut.clk, 10)

    dut.rst_n.value = 1

    # -------------------------------------------------
    # Run RISC-V CPU
    # -------------------------------------------------

    dut._log.info("Running RISC-V program")

    # Select Result_out[7:0]
    #
    # project.v:
    # 00 -> PC[7:0]
    # 01 -> PC[15:8]
    # 10 -> Result[7:0]
    # 11 -> Result[15:8]
    #
    dut.ui_in.value = 2
    dut.uio_in.value = 0

    # Give the CPU enough cycles to execute the program
    await ClockCycles(dut.clk, 30)

    # -------------------------------------------------
    # Check output
    # -------------------------------------------------

    result = int(dut.uo_out.value)

    dut._log.info(f"CPU Result = {result}")

    # Expected result from the RISC-V program
    assert result == 50, f"Expected 50, got {result}"

    dut._log.info("RISC-V CPU test PASSED")
