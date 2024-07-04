from random import getrandbits
from typing import Any, Dict, List

import cocotb
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.handle import SimHandleBase
from cocotb.queue import Queue
from cocotb.triggers import RisingEdge, FallingEdge, Edge


# ;(
from tests import coremark
from tests import hello_world


TIMEOUT = 200000
tests = {}
tests.update(hello_world)


@cocotb.coroutine
async def read_instructions():
    for test in tests:
        with open(tests[test]["TEST_FILE"], "r") as f:
            instructions = [line.rstrip("\n") for line in f]
        tests[test]["instructions"] = instructions


@cocotb.coroutine
async def anabellek(dut):
    await RisingEdge(dut.clk_i)
    for test in tests:
        timout = 0
        dut.rst_ni.value = 0
        await RisingEdge(dut.clk_i)
        for index, instruction in enumerate(tests[test]["instructions"]):
            # fmt: off
            dut.ram_i.dp_ram_i.mem[(index << 2) + 0].value = (int(instruction, 16) >>  0) & 0xFF
            dut.ram_i.dp_ram_i.mem[(index << 2) + 1].value = (int(instruction, 16) >>  8) & 0xFF
            dut.ram_i.dp_ram_i.mem[(index << 2) + 2].value = (int(instruction, 16) >> 16) & 0xFF
            dut.ram_i.dp_ram_i.mem[(index << 2) + 3].value = (int(instruction, 16) >> 24) & 0xFF
            # fmt: on

        await RisingEdge(dut.clk_i)
        dut.rst_ni.value = 1
        dut.fetch_enable_i.value = 1
        while 1:
            try:
                if (
                    tests[test]["pass_adr"]
                    == dut.soc.isl_blksiz.cek.getir_dut.debug_ps.value.integer
                ):
                    print("[TEST] ", test, " passed")
                    break
                if (
                    tests[test]["fail_adr"]
                    == dut.soc.isl_blksiz.cek.getir_dut.debug_ps.value.integer
                ):
                    print("[TEST] ", test, " FAILED")
                    assert 0
                    break
            except:
                print("[WARNING] ADR is XXXXXXXXX")
            await RisingEdge(dut.clk_i)
            timout = timout + 1
            if timout > TIMEOUT:
                print("[TEST] ", test, " FAILED TIMOUT")
                print(
                    "current PC: ",
                    dut.soc.isl_blksiz.cek.getir_dut.debug_ps.value.integer,
                )
                assert 0
                break


@cocotb.test()
async def tair(dut):
    await read_instructions()

    await cocotb.start(Clock(dut.clk_i, 10, "ns").start(start_high=False))
    dut.rst_ni.value = 0
    await RisingEdge(dut.clk_i)
    await RisingEdge(dut.clk_i)
    dut.rst_ni.value = 1
    blk = cocotb.start_soon(anabellek(dut))
    await blk
