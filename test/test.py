# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):

    dut._log.info("Start")

    # 10 us clock period = 100 KHz
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    await ClockCycles(dut.clk, 10)

    dut.rst_n.value = 1

    # Run RISC-V program
    dut._log.info("Running RISC-V program")

    # 2'b10 selects Result_out[7:0]
    dut.ui_in.value = 2
    dut.uio_in.value = 0

    # Give CPU enough time to execute the program
    await ClockCycles(dut.clk, 30)

    result = int(dut.uo_out.value)

    dut._log.info(f"CPU Result = {result}")

    # Expected result of the current RISC-V program
    assert result == 249, f"Expected 249, got {result}"

    dut._log.info("RISC-V CPU test PASSED")
