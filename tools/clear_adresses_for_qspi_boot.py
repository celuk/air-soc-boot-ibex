import argparse

def remove_addresses_from_vmem_file(input_file):
    with open(input_file, 'r') as file:
        lines = file.readlines()

    # Filter out lines that start with '@'
    filtered_lines = [line for line in lines if not line.startswith('@')]

    # Add @00000000 at the top
    filtered_lines.insert(0, '@00000000\n')

    for line in filtered_lines:
        print(line, end='')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process a vmem file.')
    parser.add_argument('--file', '-f', type=str, help='The input vmem file')

    args = parser.parse_args()
    remove_addresses_from_vmem_file(args.file)
