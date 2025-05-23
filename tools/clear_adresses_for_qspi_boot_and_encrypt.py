import argparse

def encrypt_byte_and_format(byte_val, key, current_key_round_index):
    key_byte_index = current_key_round_index % len(key)
    encrypted = byte_val ^ key[key_byte_index]
    return f'{encrypted:02X}'

def process_vmem_file(input_file, place_zero, bytes_per_output_line=16):
    with open(input_file, 'r') as file:
        lines = file.readlines()

    all_encrypted_bytes = []

    key = [0xDE, 0xAD, 0xBE, 0xEF]
    global_byte_index = 0

    previous_address = None
    accumulated_data_length_for_block = 0

    output_lines = []

    for line in lines:
        if line.startswith('@'):
            current_address = int(line[1:], 16)

            if previous_address is not None and place_zero:
                gap = current_address - (previous_address + accumulated_data_length_for_block)
                if gap > 0:
                    gap_encrypted_bytes = []
                    for _ in range(gap):
                        #gap_encrypted_bytes.append(encrypt_byte_and_format(0x00, key, global_byte_index))
                        output_lines.append(encrypt_byte_and_format(0x00, key, global_byte_index) + ' ')
                        global_byte_index += 1
                        
                    output_lines.append('\n')
            
            previous_address = current_address
            accumulated_data_length_for_block = 0 # Reset for the new address block

        else:
            data_bytes_str = line.split()
            data_encrypted_bytes = []
            for byte_str in data_bytes_str:
                byte_val = int(byte_str, 16)
                #data_encrypted_bytes.append(encrypt_byte_and_format(byte_val, key, global_byte_index))
                output_lines.append(encrypt_byte_and_format(byte_val, key, global_byte_index) + ' ')
                global_byte_index += 1
                
            output_lines.append('\n')
            
            accumulated_data_length_for_block += len(data_bytes_str) # Accumulate data length

    
    output_lines.insert(0, ' '.join([f'{k:02X}' for k in key]) + '\n')

    # Add @00000000 at the top
    output_lines.insert(0, '@00000000\n')


    #for i in range(0, len(all_encrypted_bytes), bytes_per_output_line):
    #    line_of_bytes = all_encrypted_bytes[i : i + bytes_per_output_line]
    #    output_lines.append(' '.join(line_of_bytes) + '\n')

    for line in output_lines:
        print(line, end='')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process a vmem file.')
    parser.add_argument('--file', '-f', type=str, help='The input vmem file')
    parser.add_argument('--place_zero', '-pz', action='store_true', help='Place zero bytes for gaps between addresses')

    args = parser.parse_args()
    process_vmem_file(args.file, args.place_zero)
