import argparse

def encrypt_byte_and_format(byte_val, key, current_key_round_index):
    # current_key_round_index is the 0-indexed byte count from the start of the file.
    # We use it to determine which key byte to use.
    key_byte_index = current_key_round_index % len(key)
    encrypted = byte_val ^ key[key_byte_index]
    return f'{encrypted:02X}'

def process_vmem_file(input_file, place_zero, bytes_per_output_line=16):
    with open(input_file, 'r') as file:
        lines = file.readlines()

    # This list will store all *encrypted* byte strings in order
    all_encrypted_bytes = []

    key = [0xDE, 0xAD, 0xBE, 0xEF]
    global_byte_index = 0 # This will keep track of the absolute byte index for XORing

    previous_address = 0 # Initialize to 0, assuming the file starts at 0x00000000 if no @00000000 is present
    previous_data_end_address = 0 # The address of the byte *after* the last processed data byte

    for line in lines:
        if line.startswith('@'):
            current_address = int(line[1:], 16)

            # Handle gap filling for non-zero addresses
            if place_zero:
                # Calculate the gap from the end of the previous data block to the current address
                gap = current_address - previous_data_end_address

                if gap > 0:
                    for _ in range(gap):
                        all_encrypted_bytes.append(encrypt_byte_and_format(0x00, key, global_byte_index))
                        global_byte_index += 1

            previous_address = current_address
            # For a new address line, previous_data_end_address just becomes current_address initially
            # It will be updated as data bytes for this address are processed
            previous_data_end_address = current_address

        else: # This is a data line
            data_bytes_str = line.strip().split()
            for byte_str in data_bytes_str:
                byte_val = int(byte_str, 16)
                all_encrypted_bytes.append(encrypt_byte_and_format(byte_val, key, global_byte_index))
                global_byte_index += 1
            
            # Update previous_data_end_address based on the data just processed
            previous_data_end_address = previous_address + len(data_bytes_str)
            # For the next iteration, previous_address should be the start of the current data block
            # This is already correctly handled by previous_address = current_address in the '@' block

    # --- Construct the final output ---
    output_lines = []

    # Add @00000000 at the top
    output_lines.append('@00000000\n')

    # Add key (assuming this is part of the output file format, e.g., for decryption)
    output_lines.append(' '.join([f'{k:02X}' for k in key]) + '\n')

    # Format the encrypted bytes into lines
    for i in range(0, len(all_encrypted_bytes), bytes_per_output_line):
        line_of_bytes = all_encrypted_bytes[i : i + bytes_per_output_line]
        output_lines.append(' '.join(line_of_bytes) + '\n')

    # Print all processed lines to stdout
    for line in output_lines:
        print(line, end='')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process a vmem file.')
    parser.add_argument('--file', '-f', type=str, help='The input vmem file')
    parser.add_argument('--place_zero', '-pz', action='store_true', help='Place zero bytes for gaps between addresses')

    args = parser.parse_args()
    process_vmem_file(args.file, args.place_zero)
