import argparse

def encrypt_byte_and_format(byte_val, key, current_key_round_index):
    # current_key_round_index is the 0-indexed byte count from the start of the file.
    # We use it to determine which key byte to use.
    key_byte_index = current_key_round_index % len(key)
    encrypted = byte_val ^ key[key_byte_index]
    return f'{encrypted:02X}'

def process_vmem_file(input_file, place_zero):
    with open(input_file, 'r') as file:
        lines = file.readlines()

    output_lines = [] # Renamed to avoid confusion with internal filtering

    key = [0xDE, 0xAD, 0xBE, 0xEF]
    global_byte_index = 0 # This will keep track of the absolute byte index for XORing

    # Add @00000000 at the top
    output_lines.append('@00000000\n')

    # Add key (assuming this is part of the output file format, e.g., for decryption)
    output_lines.append(' '.join([f'{k:02X}' for k in key]) + '\n')

    previous_address = None
    previous_data_block_length = 0 # Total length of the data block on the previous line

    for line in lines:
        if line.startswith('@'):
            current_address = int(line[1:], 16)

            # Handle gap filling
            if previous_address is not None and place_zero:
                # Calculate the expected next byte address if there were no gap
                expected_next_address = previous_address + previous_data_block_length

                gap = current_address - expected_next_address

                if gap > 0:
                    encrypted_zeros_list = []
                    for _ in range(gap):
                        encrypted_zeros_list.append(encrypt_byte_and_format(0x00, key, global_byte_index))
                        global_byte_index += 1 # Increment for each zero byte
                    output_lines.append(' '.join(encrypted_zeros_list) + '\n')
            
            # Append the address line
            output_lines.append(line)
            previous_address = current_address
            previous_data_block_length = 0 # Reset for the new data block
        else:
            # Process data bytes on the line
            data_bytes_str = line.strip().split() # Use strip() to remove trailing newline
            encrypted_data_bytes = []
            
            for byte_str in data_bytes_str:
                byte_val = int(byte_str, 16)
                encrypted_byte = encrypt_byte_and_format(byte_val, key, global_byte_index)
                encrypted_data_bytes.append(encrypted_byte)
                global_byte_index += 1 # Increment for each data byte

            # Append the encrypted data line
            output_lines.append(' '.join(encrypted_data_bytes) + '\n')
            previous_data_block_length += len(data_bytes_str)

    # Add key
    #output_lines.insert(0, ' '.join([f'{k:02X}' for k in key]) + '\n')

    # Add @00000000 at the top
    #output_lines.insert(0, '@00000000\n')

    for line in output_lines:
        print(line, end='')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process a vmem file.')
    parser.add_argument('--file', '-f', type=str, help='The input vmem file')
    parser.add_argument('--place_zero', '-pz', action='store_true', help='Place zero bytes for gaps between addresses')

    args = parser.parse_args()
    process_vmem_file(args.file, args.place_zero)
