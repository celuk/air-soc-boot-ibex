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

TIMEOUT = 250000
tests = {}
tests.update(coremark)


@cocotb.coroutine
async def read_instructions():
    for test in tests:
        with open(tests[test]["TEST_FILE"], "r") as f:
            instructions = [line.rstrip("\n") for line in f]
        tests[test]["instructions"] = instructions

#@cocotb.coroutine async
def load_verilog_hex_file():
    for test in tests:
        with open(tests[test]["TEST_FILE"], "r") as file:
            lines = file.readlines()

        memory = {}
        current_address = None

        for line in lines:
            if line.startswith("@"):
                current_address = int(line[1:], 16)
            else:
                values = line.strip().split()
                for value in values:
                    if current_address is not None:
                        memory[current_address] = int(value, 16)
                        current_address += 1

    return memory

@cocotb.coroutine
async def anabellek(dut):
    await RisingEdge(dut.clk_i)
    dut.rst_ni.value = 0
    await RisingEdge(dut.clk_i)
    
    """
    memory = load_verilog_hex_file()
    for address, value in memory.items():
        dut.u_ram.mem[address].value = value
    
    await RisingEdge(dut.clk_i)
    dut.rst_ni.value = 1
    #dut.fetch_enable_i.value = 1

    timeout = 0
    while True:
        await RisingEdge(dut.clk_i)
        if timeout > TIMEOUT:
            break
        timeout += 1
    """
        
    
    for test in tests:
        dut.rst_ni.value = 0
        await RisingEdge(dut.clk_i)
        for index, instruction in enumerate(tests[test]["instructions"]):
            # fmt: off
            #dut.ram_i.dp_ram_i.mem[(index << 2) + 0].value = (int(instruction, 16) >>  0) & 0xFF
            #dut.ram_i.dp_ram_i.mem[(index << 2) + 1].value = (int(instruction, 16) >>  8) & 0xFF
            #dut.ram_i.dp_ram_i.mem[(index << 2) + 2].value = (int(instruction, 16) >> 16) & 0xFF
            #dut.ram_i.dp_ram_i.mem[(index << 2) + 3].value = (int(instruction, 16) >> 24) & 0xFF
            # fmt: on
            dut.u_ram.mem[index].value = int(instruction, 16)

        await RisingEdge(dut.clk_i)
        dut.rst_ni.value = 1
        while True:
            await RisingEdge(dut.clk_i)
    

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
