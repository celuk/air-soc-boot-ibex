import argparse

def encrypt_byte_and_format(byte_val, key, key_index):
    key_index = (key_index + 1) % 4  # Cycle through 0, 1, 2, 3
    encrypted = byte_val ^ key[key_index]
    return f'{encrypted:02X}'

def process_vmem_file(input_file, place_zero):
    with open(input_file, 'r') as file:
        lines = file.readlines()

    filtered_lines = []
    previous_address = None
    previous_data_length = 0

    key = [0xDE, 0xAD, 0xBE, 0xEF]
    key_index = 0

    for line in lines:
        if line.startswith('@'):
            current_address = int(line[1:], 16)
            if previous_address is not None and place_zero:
                gap = current_address - (previous_address + previous_data_length)
                if gap > 0:
                    #zero_bytes = '00 ' * gap
                    #filtered_lines.append(zero_bytes.strip() + '\n')
                    encrypted_zeros = [encrypt_byte_and_format(0x00, key, key_index + i) for i in range(gap)]
                    filtered_lines.append(' '.join(encrypted_zeros) + '\n')
                    key_index = key_index + gap

            previous_address = current_address
            previous_data_length = 0
        else:
            data_bytes_str = line.split()
            for byte_str in data_bytes_str:
                byte_val = int(byte_str, 16)
                encrypted_byte = encrypt_byte_and_format(byte_val, key, key_index)
                filtered_lines.append(encrypted_byte + ' ')
                key_index = key_index + 1
            
            #filtered_lines.append(line)
            #previous_data_length += len(line.split())
            previous_data_length += len(data_bytes_str)

    # Add key
    filtered_lines.insert(0, ' '.join([f'{k:02X}' for k in key]) + '\n')

    # Add @00000000 at the top
    filtered_lines.insert(0, '@00000000\n')

    for line in filtered_lines:
        print(line, end='')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process a vmem file.')
    parser.add_argument('--file', '-f', type=str, help='The input vmem file')
    parser.add_argument('--place_zero', '-pz', action='store_true', help='Place zero bytes for gaps between addresses')

    args = parser.parse_args()
    process_vmem_file(args.file, args.place_zero)
