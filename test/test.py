import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


async def reset_dut(dut):
    dut.areset.value = 0
    await ClockCycles(dut.clk, 2)

    dut.areset.value = 1
    await ClockCycles(dut.clk, 1)


async def execute_instruction(dut, addr):
    dut.InstrAddr.value = addr
    dut.Execute.value = 1

    await ClockCycles(dut.clk, 1)

    dut.Execute.value = 0
    await ClockCycles(dut.clk, 1)


async def read_register(dut, reg):
    dut.ReadRegAddr.value = reg
    await ClockCycles(dut.clk, 1)

    return int(dut.ReadRegData.value)


@cocotb.test()
async def test_riscv_core(dut):

    cocotb.start_soon(
        Clock(dut.clk, 10, units="us").start()
    )

    dut.InstrAddr.value = 0
    dut.Execute.value = 0
    dut.ReadRegAddr.value = 0

    # ==================================================
    # RESET
    # ==================================================

    await reset_dut(dut)

    # x0 must always be zero
    value = await read_register(dut, 0)

    assert value == 0, \
        f"x0 expected 0, got {value}"

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
    # SLLI x8
    # ==================================================

    await execute_instruction(dut, 7)

    value = await read_register(dut, 8)

    assert value == 10, \
        f"x8 expected 10, got {value}"

    # ==================================================
    # SRLI x9
    # ==================================================

    await execute_instruction(dut, 8)

    value = await read_register(dut, 9)

    assert value == 2, \
        f"x9 expected 2, got {value}"

    # ==================================================
    # ADDI x10
    # ==================================================

    await execute_instruction(dut, 9)

    value = await read_register(dut, 10)

    assert value == 3, \
        f"x10 expected 3, got {value}"

    # ==================================================
    # ADD x11
    # ==================================================

    await execute_instruction(dut, 10)

    value = await read_register(dut, 11)

    assert value == 6, \
        f"x11 expected 6, got {value}"

    # ==================================================
    # STORE
    #
    # x12 = 100
    # Memory[4] = 100
    # ==================================================

    await execute_instruction(dut, 12)

    value = await read_register(dut, 12)

    assert value == 100, \
        f"x12 expected 100, got {value}"

    await execute_instruction(dut, 13)

    # After STORE, MemoryData should be 100
    memory_value = int(dut.MemoryData.value)

    assert memory_value == 100, \
        f"MemoryData expected 100 after STORE, got {memory_value}"

    # ==================================================
    # LOAD
    #
    # x13 = Memory[4]
    # ==================================================

    await execute_instruction(dut, 14)

    value = await read_register(dut, 13)

    assert value == 100, \
        f"x13 expected 100 after LOAD, got {value}"

    # Result should also be loaded value
    result = int(dut.Result.value)

    assert result == 100, \
        f"Result expected 100 after LOAD, got {result}"

    # ==================================================
    # Negative immediate
    #
    # x14 = -1
    # ==================================================

    await execute_instruction(dut, 15)

    value = await read_register(dut, 14)

    assert value == 0xFFFFFFFF, \
        f"x14 expected 0xFFFFFFFF, got {hex(value)}"

    # ==================================================
    # Execute disabled
    # ==================================================

    dut.InstrAddr.value = 0
    dut.Execute.value = 0

    await ClockCycles(dut.clk, 2)

    value = await read_register(dut, 1)

    assert value == 5, \
        f"Execute disabled: x1 changed to {value}"

    dut._log.info("ALL RISC-V CORE TESTS PASSED")
