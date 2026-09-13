import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


async def reset_dut(dut):
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)

    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)


async def execute_instruction(dut, addr):
    # ui_in[4:0] = instruction address
    # ui_in[5]   = Execute = 1
    # ui_in[7:6] = output select = 00 (Result)

    dut.ui_in.value = (1 << 5) | addr

    await ClockCycles(dut.clk, 1)

    dut.ui_in.value = addr
    await ClockCycles(dut.clk, 1)


async def read_register(dut, reg):
    # uio_in[4:0] = register address

    dut.uio_in.value = reg

    # output_select = 01 -> selected register
    dut.ui_in.value = (1 << 6)

    await ClockCycles(dut.clk, 1)

    return int(dut.uo_out.value)


async def read_result(dut, addr):
    # output_select = 00 -> Result

    dut.ui_in.value = addr
    await ClockCycles(dut.clk, 1)

    return int(dut.uo_out.value)


async def read_instruction(dut, addr):
    # output_select = 10 -> Instruction

    dut.ui_in.value = (2 << 6) | addr
    await ClockCycles(dut.clk, 1)

    return int(dut.uo_out.value)


async def read_memory(dut, addr):
    # output_select = 11 -> MemoryData

    dut.ui_in.value = (3 << 6) | addr
    await ClockCycles(dut.clk, 1)

    return int(dut.uo_out.value)


@cocotb.test()
async def test_riscv_core(dut):

    cocotb.start_soon(
        Clock(dut.clk, 10, unit="us").start()
    )

    # Initial values
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.ena.value = 1

    # ==================================================
    # RESET
    # ==================================================

    await reset_dut(dut)

    # ==================================================
    # ADDI x1 = 5
    # ==================================================

    await execute_instruction(dut, 0)

    value = await read_register(dut, 1)

    assert value == 5, \
        f"x1 expected 5, got {value}"

    # ==================================================
    # ADDI x2 = 10
    # ==================================================

    await execute_instruction(dut, 1)

    value = await read_register(dut, 2)

    assert value == 10, \
        f"x2 expected 10, got {value}"

    # ==================================================
    # ADD x3 = x1 + x2
    # ==================================================

    await execute_instruction(dut, 2)

    value = await read_register(dut, 3)

    assert value == 15, \
        f"x3 expected 15, got {value}"

    # ==================================================
    # SUB x4 = x3 - x1
    # ==================================================

    await execute_instruction(dut, 3)

    value = await read_register(dut, 4)

    assert value == 10, \
        f"x4 expected 10, got {value}"

    # ==================================================
    # AND x5
    # ==================================================

    await execute_instruction(dut, 4)

    value = await read_register(dut, 5)

    assert value == 0, \
        f"x5 expected 0, got {value}"

    # ==================================================
    # OR x6
    # ==================================================

    await execute_instruction(dut, 5)

    value = await read_register(dut, 6)

    assert value == 15, \
        f"x6 expected 15, got {value}"

    # ==================================================
    # XOR x7
    # ==================================================

    await execute_instruction(dut, 6)

    value = await read_register(dut, 7)

    assert value == 15, \
        f"x7 expected 15, got {value}"

    # ==================================================
    # SLLI x8 = x1 << 1
    # ==================================================

    await execute_instruction(dut, 7)

    value = await read_register(dut, 8)

    assert value == 10, \
        f"x8 expected 10, got {value}"

    # ==================================================
    # SRLI x9 = x1 >> 1
    # ==================================================

    await execute_instruction(dut, 8)

    value = await read_register(dut, 9)

    assert value == 2, \
        f"x9 expected 2, got {value}"

    # ==================================================
    # ADDI x10 = 3
    # ==================================================

    await execute_instruction(dut, 9)

    value = await read_register(dut, 10)

    assert value == 3, \
        f"x10 expected 3, got {value}"

    # ==================================================
    # ADD x11 = x10 + x10
    # ==================================================

    await execute_instruction(dut, 10)

    value = await read_register(dut, 11)

    assert value == 6, \
        f"x11 expected 6, got {value}"

    # ==================================================
    # ADDI x12 = 100
    # ==================================================

    await execute_instruction(dut, 12)

    value = await read_register(dut, 12)

    assert value == 100, \
        f"x12 expected 100, got {value}"

    # ==================================================
    # STORE
    #
    # SW x12, 4(x0)
    # Memory[4] = 100
    # ==================================================

    await execute_instruction(dut, 13)

    memory_value = await read_memory(dut, 13)

    assert memory_value == 100, \
        f"MemoryData expected 100 after STORE, got {memory_value}"

    # ==================================================
    # LOAD
    #
    # LW x13, 4(x0)
    # ==================================================

    await execute_instruction(dut, 14)

    value = await read_register(dut, 13)

    assert value == 100, \
        f"x13 expected 100 after LOAD, got {value}"

    # ==================================================
    # Result after LOAD
    # ==================================================

    result = await read_result(dut, 14)

    assert result == 100, \
        f"Result expected 100 after LOAD, got {result}"

    # ==================================================
    # Negative immediate
    #
    # x14 = -1
    # ==================================================

    await execute_instruction(dut, 15)

    value = await read_register(dut, 14)

    assert value == 0xFF, \
        f"x14 expected low 8 bits FF, got {hex(value)}"

    # ==================================================
    # Execute disabled
    # ==================================================

    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 2)

    value = await read_register(dut, 1)

    assert value == 5, \
        f"Execute disabled: x1 changed to {value}"

    dut._log.info("ALL RISC-V TINY TAPEOUT TESTS PASSED")
