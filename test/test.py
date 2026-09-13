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

    # ---------------------------------------------------------
    # Reset
    # ---------------------------------------------------------

    dut._log.info("Reset")

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    await ClockCycles(dut.clk, 2)

    dut.rst_n.value = 1

    await ClockCycles(dut.clk, 1)

    # ---------------------------------------------------------
    # Helper function
    # ---------------------------------------------------------

    async def execute_instruction(address):
        """
        ui_in[4:0] = instruction address
        ui_in[5]   = Execute
        ui_in[7:6] = output select
        """

        # Address + Execute = 1
        dut.ui_in.value = (1 << 5) | address

        # Execute instruction
        await ClockCycles(dut.clk, 1)

        # Disable Execute
        dut.ui_in.value = address

        await ClockCycles(dut.clk, 1)

    # ---------------------------------------------------------
    # Instruction 0
    #
    # ADDI x1, x0, 5
    #
    # Expected:
    # x1 = 5
    # ---------------------------------------------------------

    dut._log.info("Executing instruction 0: ADDI x1, x0, 5")

    await execute_instruction(0)

    # Read x1
    # uio_in[4:0] = 1
    dut.uio_in.value = 1

    # ui_in[7:6] = 01 -> Register Read
    dut.ui_in.value = (1 << 6)

    await ClockCycles(dut.clk, 1)

    result = int(dut.uo_out.value)

    dut._log.info(f"x1 = {result}")

    assert result == 5, f"Expected x1 = 5, got {result}"

    # ---------------------------------------------------------
    # Instruction 1
    #
    # ADDI x2, x0, 10
    #
    # Expected:
    # x2 = 10
    # ---------------------------------------------------------

    dut._log.info("Executing instruction 1: ADDI x2, x0, 10")

    await execute_instruction(1)

    # Read x2
    dut.uio_in.value = 2

    # Register read
    dut.ui_in.value = (1 << 6)

    await ClockCycles(dut.clk, 1)

    result = int(dut.uo_out.value)

    dut._log.info(f"x2 = {result}")

    assert result == 10, f"Expected x2 = 10, got {result}"

    # ---------------------------------------------------------
    # Instruction 2
    #
    # ADD x3, x1, x2
    #
    # Expected:
    # x3 = 5 + 10 = 15
    # ---------------------------------------------------------

    dut._log.info("Executing instruction 2: ADD x3, x1, x2")

    await execute_instruction(2)

    # Read x3
    dut.uio_in.value = 3

    # Register read
    dut.ui_in.value = (1 << 6)

    await ClockCycles(dut.clk, 1)

    result = int(dut.uo_out.value)

    dut._log.info(f"x3 = {result}")

    assert result == 15, f"Expected x3 = 15, got {result}"

    # ---------------------------------------------------------
    # Test ALU Result directly
    # ---------------------------------------------------------

    dut._log.info("Checking ALU/Result output")

    # Instruction address = 2
    # Output select = 00 -> Result
    dut.ui_in.value = 2
    dut.uio_in.value = 3

    await ClockCycles(dut.clk, 1)

    result = int(dut.uo_out.value)

    dut._log.info(f"ALU Result = {result}")

    assert result == 15, f"Expected ALU Result = 15, got {result}"

    # ---------------------------------------------------------
    # Test Instruction output
    # ---------------------------------------------------------

    dut._log.info("Checking instruction output")

    # Instruction address = 2
    # Output select = 10 -> Instruction
    dut.ui_in.value = (2 << 6) | 2

    await ClockCycles(dut.clk, 1)

    instruction_low_byte = int(dut.uo_out.value)

    # 0x002081B3 -> low byte = B3 = 179
    dut._log.info(
        f"Instruction[7:0] = 0x{instruction_low_byte:02X}"
    )

    assert instruction_low_byte == 0xB3, (
        f"Expected instruction low byte = 0xB3, "
        f"got 0x{instruction_low_byte:02X}"
    )

    dut._log.info("RISC-V instruction execution test PASSED")
