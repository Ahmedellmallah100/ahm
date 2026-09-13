import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_riscv_cpu(dut):

    dut._log.info("========================================")
    dut._log.info("       RISC-V CPU TEST START")
    dut._log.info("========================================")

    # =========================================================
    # Start clock
    # =========================================================

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # =========================================================
    # Initial values
    # =========================================================

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    # =========================================================
    # Reset
    # =========================================================

    dut._log.info("Resetting CPU...")

    dut.rst_n.value = 0

    await ClockCycles(dut.clk, 2)

    dut.rst_n.value = 1

    await ClockCycles(dut.clk, 1)

    dut._log.info("Reset complete")

    # =========================================================
    # Helper: Execute instruction
    # =========================================================

    async def execute_instruction(address):

        dut._log.info(
            f"Executing instruction at address {address}"
        )

        # ui_in[5] = Execute
        # ui_in[4:0] = Instruction Address

        dut.ui_in.value = (1 << 5) | address

        await ClockCycles(dut.clk, 1)

        # Disable Execute

        dut.ui_in.value = address

        await ClockCycles(dut.clk, 1)

    # =========================================================
    # Helper: Read register
    # =========================================================

    async def read_register(reg):

        # uio_in[4:0] = Register address
        dut.uio_in.value = reg

        # ui_in[7:6] = 01
        # Select Register Value

        dut.ui_in.value = (1 << 6)

        await ClockCycles(dut.clk, 1)

        value = int(dut.uo_out.value)

        dut._log.info(
            f"x{reg} = {value}"
        )

        return value

    # =========================================================
    # TEST 1
    #
    # Instruction 0:
    # ADDI x1, x0, 5
    #
    # Expected:
    # x1 = 5
    # =========================================================

    dut._log.info("----------------------------------------")
    dut._log.info("TEST 1: ADDI x1, x0, 5")
    dut._log.info("----------------------------------------")

    await execute_instruction(0)

    value = await read_register(1)

    assert value == 5, (
        f"TEST 1 FAILED: Expected x1 = 5, got {value}"
    )

    dut._log.info("TEST 1 PASSED")

    # =========================================================
    # TEST 2
    #
    # Instruction 1:
    # ADDI x2, x0, 10
    #
    # Expected:
    # x2 = 10
    # =========================================================

    dut._log.info("----------------------------------------")
    dut._log.info("TEST 2: ADDI x2, x0, 10")
    dut._log.info("----------------------------------------")

    await execute_instruction(1)

    value = await read_register(2)

    assert value == 10, (
        f"TEST 2 FAILED: Expected x2 = 10, got {value}"
    )

    dut._log.info("TEST 2 PASSED")

    # =========================================================
    # TEST 3
    #
    # Instruction 2:
    # ADD x3, x1, x2
    #
    # Expected:
    # x3 = 5 + 10 = 15
    # =========================================================

    dut._log.info("----------------------------------------")
    dut._log.info("TEST 3: ADD x3, x1, x2")
    dut._log.info("----------------------------------------")

    await execute_instruction(2)

    value = await read_register(3)

    assert value == 15, (
        f"TEST 3 FAILED: Expected x3 = 15, got {value}"
    )

    dut._log.info("TEST 3 PASSED")

    # =========================================================
    # TEST 4
    #
    # Instruction 3:
    # SUB x4, x3, x1
    #
    # Expected:
    # x4 = 15 - 5 = 10
    # =========================================================

    dut._log.info("----------------------------------------")
    dut._log.info("TEST 4: SUB x4, x3, x1")
    dut._log.info("----------------------------------------")

    await execute_instruction(3)

    value = await read_register(4)

    assert value == 10, (
        f"TEST 4 FAILED: Expected x4 = 10, got {value}"
    )

    dut._log.info("TEST 4 PASSED")

    # =========================================================
    # TEST 5
    #
    # Instruction 4:
    # AND x5, x1, x2
    #
    # 5 & 10 = 0
    #
    # Expected:
    # x5 = 0
    # =========================================================

    dut._log.info("----------------------------------------")
    dut._log.info("TEST 5: AND x5, x1, x2")
    dut._log.info("----------------------------------------")

    await execute_instruction(4)

    value = await read_register(5)

    assert value == 0, (
        f"TEST 5 FAILED: Expected x5 = 0, got {value}"
    )

    dut._log.info("TEST 5 PASSED")

    # =========================================================
    # TEST 6
    #
    # Instruction 5:
    # OR x6, x1, x2
    #
    # 5 | 10 = 15
    #
    # Expected:
    # x6 = 15
    # =========================================================

    dut._log.info("----------------------------------------")
    dut._log.info("TEST 6: OR x6, x1, x2")
    dut._log.info("----------------------------------------")

    await execute_instruction(5)

    value = await read_register(6)

    assert value == 15, (
        f"TEST 6 FAILED: Expected x6 = 15, got {value}"
    )

    dut._log.info("TEST 6 PASSED")

    # =========================================================
    # TEST 7
    #
    # Instruction 6:
    # XOR x7, x1, x2
    #
    # 5 ^ 10 = 15
    #
    # Expected:
    # x7 = 15
    # =========================================================

    dut._log.info("----------------------------------------")
    dut._log.info("TEST 7: XOR x7, x1, x2")
    dut._log.info("----------------------------------------")

    await execute_instruction(6)

    value = await read_register(7)

    assert value == 15, (
        f"TEST 7 FAILED: Expected x7 = 15, got {value}"
    )

    dut._log.info("TEST 7 PASSED")

    # =========================================================
    # TEST 8
    #
    # Instruction 7:
    # SLLI x8, x1, 1
    #
    # 5 << 1 = 10
    #
    # Expected:
    # x8 = 10
    # =========================================================

    dut._log.info("----------------------------------------")
    dut._log.info("TEST 8: SLLI x8, x1, 1")
    dut._log.info("----------------------------------------")

    await execute_instruction(7)

    value = await read_register(8)

    assert value == 10, (
        f"TEST 8 FAILED: Expected x8 = 10, got {value}"
    )

    dut._log.info("TEST 8 PASSED")

    # =========================================================
    # TEST 9
    #
    # Instruction 8:
    # SRLI x9, x1, 1
    #
    # 5 >> 1 = 2
    #
    # Expected:
    # x9 = 2
    # =========================================================

    dut._log.info("----------------------------------------")
    dut._log.info("TEST 9: SRLI x9, x1, 1")
    dut._log.info("----------------------------------------")

    await execute_instruction(8)

    value = await read_register(9)

    assert value == 2, (
        f"TEST 9 FAILED: Expected x9 = 2, got {value}"
    )

    dut._log.info("TEST 9 PASSED")

    # =========================================================
    # TEST 10
    #
    # Instruction 9:
    # ADDI x10, x0, 3
    #
    # Expected:
    # x10 = 3
    # =========================================================

    dut._log.info("----------------------------------------")
    dut._log.info("TEST 10: ADDI x10, x0, 3")
    dut._log.info("----------------------------------------")

    await execute_instruction(9)

    value = await read_register(10)

    assert value == 3, (
        f"TEST 10 FAILED: Expected x10 = 3, got {value}"
    )

    dut._log.info("TEST 10 PASSED")

    # =========================================================
    # TEST 11
    #
    # Instruction 10:
    # ADD x11, x10, x10
    #
    # 3 + 3 = 6
    #
    # Expected:
    # x11 = 6
    # =========================================================

    dut._log.info("----------------------------------------")
    dut._log.info("TEST 11: ADD x11, x10, x10")
    dut._log.info("----------------------------------------")

    await execute_instruction(10)

    value = await read_register(11)

    assert value == 6, (
        f"TEST 11 FAILED: Expected x11 = 6, got {value}"
    )

    dut._log.info("TEST 11 PASSED")

    # =========================================================
    # TEST 12
    #
    # Test register x0
    #
    # x0 must ALWAYS be zero
    # =========================================================

    dut._log.info("----------------------------------------")
    dut._log.info("TEST 12: Check x0")
    dut._log.info("----------------------------------------")

    value = await read_register(0)

    assert value == 0, (
        f"TEST 12 FAILED: Expected x0 = 0, got {value}"
    )

    dut._log.info("TEST 12 PASSED")

    # =========================================================
    # TEST 13
    #
    # Test Execute control
    #
    # Try to execute instruction 0 with Execute = 0.
    #
    # x1 should remain unchanged.
    # =========================================================

    dut._log.info("----------------------------------------")
    dut._log.info("TEST 13: Execute disabled")
    dut._log.info("----------------------------------------")

    # Address = 0
    # Execute = 0

    dut.ui_in.value = 0

    await ClockCycles(dut.clk, 1)

    value = await read_register(1)

    assert value == 5, (
        f"TEST 13 FAILED: x1 changed unexpectedly. "
        f"Expected 5, got {value}"
    )

    dut._log.info("TEST 13 PASSED")

    # =========================================================
    # TEST 14
    #
    # Check ALU Result output
    #
    # Instruction 2:
    # ADD x3, x1, x2
    #
    # ALU result = 15
    #
    # Output select = 00
    # =========================================================

    dut._log.info("----------------------------------------")
    dut._log.info("TEST 14: ALU Result output")
    dut._log.info("----------------------------------------")

    dut.ui_in.value = 2

    # ui_in[7:6] = 00
    # ui_in[4:0] = 2

    await ClockCycles(dut.clk, 1)

    value = int(dut.uo_out.value)

    dut._log.info(
        f"ALU Result low 8 bits = {value}"
    )

    assert value == 15, (
        f"TEST 14 FAILED: Expected ALU result = 15, got {value}"
    )

    dut._log.info("TEST 14 PASSED")

    # =========================================================
    # TEST 15
    #
    # Check Instruction output
    #
    # Instruction 2:
    #
    # 32'h002081B3
    #
    # Low 8 bits:
    # 8'hB3
    #
    # Output select = 10
    # =========================================================

    dut._log.info("----------------------------------------")
    dut._log.info("TEST 15: Instruction output")
    dut._log.info("----------------------------------------")

    # Output select = 10
    # 10 << 6 = 128

    dut.ui_in.value = (2 << 6) | 2

    await ClockCycles(dut.clk, 1)

    value = int(dut.uo_out.value)

    dut._log.info(
        f"Instruction low 8 bits = 0x{value:02X}"
    )

    assert value == 0xB3, (
        f"TEST 15 FAILED: Expected 0xB3, got 0x{value:02X}"
    )

    dut._log.info("TEST 15 PASSED")

    # =========================================================
    # Final result
    # =========================================================

    dut._log.info("")
    dut._log.info("========================================")
    dut._log.info("       ALL RISC-V TESTS PASSED")
    dut._log.info("========================================")
