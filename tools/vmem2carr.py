import argparse
import os

def parse_demo_file(filename):
    with open(filename, "r") as f:
        lines = f.readlines()

    memory_blocks = {}
    current_address = None

    for line in lines:
        line = line.strip()
        if not line:
            continue
        if line.startswith('@'):
            current_address = line[1:]
            memory_blocks[current_address] = []
        else:
            bytes_list = line.split()
            memory_blocks[current_address].extend(bytes_list)

    return memory_blocks

def generate_c_arrays_print(memory_blocks):
    for addr, bytes_list in memory_blocks.items():
        array_name = f"mem_{addr}"
        print(f"unsigned char {array_name}[] = {{")
        for i in range(0, len(bytes_list), 8):
            chunk = bytes_list[i:i+8]
            formatted = ", ".join(f"0x{b}" for b in chunk)
            print(f"    {formatted},")
        print("};\n")

def generate_c_arrays(memory_blocks, output_file):
    with open(output_file, "w") as f:
        for addr, bytes_list in memory_blocks.items():
            array_name = f"mem_{addr}"
            f.write(f"unsigned char {array_name}[] = {{\n")
            for i in range(0, len(bytes_list), 8):
                chunk = bytes_list[i:i+8]
                formatted = ", ".join(f"0x{b}" for b in chunk)
                f.write(f"    {formatted},\n")
            f.write("};\n\n")

parser = argparse.ArgumentParser(description="Convert hex memory dump to c arrays")
parser.add_argument("--file", '-f', help="Path to the input file")
args = parser.parse_args()
memory_blocks = parse_demo_file(args.file)
base_name = os.path.splitext(args.file)[0]
output_file = base_name + ".carr"
generate_c_arrays(memory_blocks, output_file)
