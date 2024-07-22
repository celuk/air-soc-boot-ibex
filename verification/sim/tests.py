from pathlib import Path
import os

SCRIPT_DIR = Path(os.path.realpath(__file__)).parent.absolute()
print("SCRIPT_DIR ", SCRIPT_DIR)
hello_world = {
    "hello_world": {
        "TEST_FILE": f"{SCRIPT_DIR}/../../tests/simple/build/simple.hex",
        "fail_adr": 0x40F00060,
        "pass_adr": 0x40F00078,
        "instructions": [],
    }
}

coremark = {
    "coremark": {
        "TEST_FILE": f"{SCRIPT_DIR}/../../tests/coremark/coremark_baremetal_static.hex",
        "fail_adr": 0x40F00060,
        "pass_adr": 0x40F00078,
        "instructions": [],
    }
}

pikachu = {
    "pikachu": {
        "TEST_FILE": f"{SCRIPT_DIR}/../../tests/pikachu/pikachu.hex",
        "fail_adr": 0x40F00060,
        "pass_adr": 0x40F00078,
        "instructions": [],
    }
}

demo = {
    "demo": {
        "TEST_FILE": f"{SCRIPT_DIR}/../../tests/demo/demo.hex",
        "fail_adr": 0x40F00060,
        "pass_adr": 0x40F00078,
        "instructions": [],
    }
}
