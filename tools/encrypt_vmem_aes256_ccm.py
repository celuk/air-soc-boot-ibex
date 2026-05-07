import argparse

# AES constants
AES_Nk = 8  # Number of 32-bit words in the key (AES-256)
AES_Nb = 4  # Number of 32-bit words in a block (always 4 for AES)
AES_Nr = 14 # Number of rounds for AES-256

# S-Box
S_BOX = [
    0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
    0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
    0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
    0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
    0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
    0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
    0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
    0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
    0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
    0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
    0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
    0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
    0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
    0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
    0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
    0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
]

# Rcon (Round Constant)
RCON = [
    0x01000000, 0x02000000, 0x04000000, 0x08000000, 0x10000000,
    0x20000000, 0x40000000, 0x80000000, 0x1b000000, 0x36000000,
    0x6c000000, 0xd8000000, 0xab000000, 0x4d000000
]

# Helper: xtime for Galois Field multiplication GF(2^8)
def xtime(a):
    return (((a << 1) & 0xff) ^ 0x1b) if (a & 0x80) else ((a << 1) & 0xff)

# Optimized Galois Field multiplications for MixColumns
def mul_by_02(num): return xtime(num)
def mul_by_03(num): return xtime(num) ^ num

# Key Expansion helpers
def rot_word(word): # word is a 32-bit int
    return ((word << 8) & 0xFFFFFFFF) | (word >> 24)

def sub_word(word): # word is a 32-bit int
    return (
        (S_BOX[(word >> 24) & 0xFF] << 24) |
        (S_BOX[(word >> 16) & 0xFF] << 16) |
        (S_BOX[(word >>  8) & 0xFF] <<  8) |
        (S_BOX[(word >>  0) & 0xFF] <<  0)
    )

# Key Expansion function
def key_expansion(key_parts): # key_parts is a list of 8 32-bit ints
    round_keys = [0] * (AES_Nb * (AES_Nr + 1)) # 4 * (14 + 1) = 60 words

    for i in range(AES_Nk): # First Nk words are the original key
        round_keys[i] = key_parts[i]

    for i in range(AES_Nk, AES_Nb * (AES_Nr + 1)):
        temp = round_keys[i - 1]
        if i % AES_Nk == 0:
            temp = sub_word(rot_word(temp)) ^ RCON[i // AES_Nk - 1]
        # For AES-256, apply SubWord to every 4th word after the first 6 rounds
        if AES_Nk > 6 and i % AES_Nk == 4:
            temp = sub_word(temp)
            
        round_keys[i] = round_keys[i - AES_Nk] ^ temp
    return round_keys

# Convert input block parts to state matrix (state[row][col])
def block_to_state(b0, b1, b2, b3):
    state = [[0]*AES_Nb for _ in range(4)] # 4x4 matrix of bytes
    block_parts_list = [b0, b1, b2, b3]
    for c in range(AES_Nb): # column
        state[0][c] = (block_parts_list[c] >> 24) & 0xFF
        state[1][c] = (block_parts_list[c] >> 16) & 0xFF
        state[2][c] = (block_parts_list[c] >>  8) & 0xFF
        state[3][c] = (block_parts_list[c] >>  0) & 0xFF
    return state

# Convert state matrix to output block list
def state_to_block(state):
    block_array = [0]*AES_Nb # list of 4 32-bit integers
    for c in range(AES_Nb): # column
        block_array[c] = (
            (state[0][c] << 24) |
            (state[1][c] << 16) |
            (state[2][c] <<  8) |
            (state[3][c] <<  0)
        )
    return block_array

# AES round transformations (modify state in-place)
def sub_bytes(state):
    for r in range(4):
        for c in range(AES_Nb):
            state[r][c] = S_BOX[state[r][c]]

def shift_rows(state):
    # Row 0: no shift
    # Row 1: 1 byte left shift
    state[1][0], state[1][1], state[1][2], state[1][3] = state[1][1], state[1][2], state[1][3], state[1][0]
    # Row 2: 2 bytes left shift
    state[2][0], state[2][1], state[2][2], state[2][3] = state[2][2], state[2][3], state[2][0], state[2][1]
    # Row 3: 3 bytes left shift (1 byte right shift)
    state[3][0], state[3][1], state[3][2], state[3][3] = state[3][3], state[3][0], state[3][1], state[3][2]

def mix_columns(state):
    for c in range(AES_Nb):
        s0, s1, s2, s3 = state[0][c], state[1][c], state[2][c], state[3][c] # Current column
        state[0][c] = mul_by_02(s0) ^ mul_by_03(s1) ^ s2            ^ s3
        state[1][c] = s0            ^ mul_by_02(s1) ^ mul_by_03(s2) ^ s3
        state[2][c] = s0            ^ s1            ^ mul_by_02(s2) ^ mul_by_03(s3)
        state[3][c] = mul_by_03(s0) ^ s1            ^ s2            ^ mul_by_02(s3)

def add_round_key(state, round_key_words_for_round): # round_key_words is a list of AES_Nb 32-bit words
    for c in range(AES_Nb):
        key_col_word = round_key_words_for_round[c]
        state[0][c] ^= (key_col_word >> 24) & 0xFF
        state[1][c] ^= (key_col_word >> 16) & 0xFF
        state[2][c] ^= (key_col_word >>  8) & 0xFF
        state[3][c] ^= (key_col_word >>  0) & 0xFF

# AES-ECB encrypt a single block (used by CCM's CTR mode and CBC-MAC)
def aes_encrypt(block_part0, block_part1, block_part2, block_part3,
                key_part0, key_part1, key_part2, key_part3,
                key_part4, key_part5, key_part6, key_part7):
    state = block_to_state(block_part0, block_part1, block_part2, block_part3)
    initial_key = [key_part0, key_part1, key_part2, key_part3,
                   key_part4, key_part5, key_part6, key_part7]
    key_schedule = key_expansion(initial_key)

    add_round_key(state, key_schedule[0:AES_Nb]) # Round 0

    for round_num in range(1, AES_Nr): # Rounds 1 to Nr-1
        sub_bytes(state)
        shift_rows(state)
        mix_columns(state)
        add_round_key(state, key_schedule[round_num * AES_Nb : (round_num + 1) * AES_Nb])

    # Final round (Round Nr) - no MixColumns
    sub_bytes(state)
    shift_rows(state)
    add_round_key(state, key_schedule[AES_Nr * AES_Nb : (AES_Nr + 1) * AES_Nb])

    return state_to_block(state) # Returns a list of 4 32-bit integers

def hex_str_to_u8_list(line):
    return [int(b, 16) for b in line.strip().split()]

def u32_from_bytes(b0, b1, b2, b3):
    return (b0 << 24) | (b1 << 16) | (b2 << 8) | b3

def bytes_from_u32(word):
    return [(word >> shift) & 0xFF for shift in (24, 16, 8, 0)]

# XOR two 16-byte lists
def xor_block(a, b):
    return [a[i] ^ b[i] for i in range(16)]

# AES-ECB encrypt a 16-byte block, returns 16-byte list
def aes_encrypt_block(block_bytes, k0, k1, k2, k3, k4, k5, k6, k7):
    b0 = u32_from_bytes(*block_bytes[0:4])
    b1 = u32_from_bytes(*block_bytes[4:8])
    b2 = u32_from_bytes(*block_bytes[8:12])
    b3 = u32_from_bytes(*block_bytes[12:16])
    r0, r1, r2, r3 = aes_encrypt(b0, b1, b2, b3, k0, k1, k2, k3, k4, k5, k6, k7)
    result = []
    for w in [r0, r1, r2, r3]:
        result.extend(bytes_from_u32(w))
    return result

# CCM: Format B0 block
# Flags = 64*Adata + 8*((t-2)/2) + (L-1)
# B0 = Flags || Nonce || Q (message length encoded in L bytes)
# With nonce_len=12, L=3, tag_len=16:
#   Flags = 0 + 8*((16-2)/2) + (3-1) = 0 + 8*7 + 2 = 58 = 0x3A
# No AAD (Adata=0)
def ccm_format_b0(nonce, msg_len, tag_len=16):
    L = 15 - len(nonce)  # L = 3 for 12-byte nonce
    flags = 8 * ((tag_len - 2) // 2) + (L - 1)  # No AAD so Adata bit = 0
    b0 = [flags] + list(nonce)
    # Encode message length in L bytes (big-endian)
    for i in range(L - 1, -1, -1):
        b0.append((msg_len >> (8 * i)) & 0xFF)
    return b0

# CCM: Format counter blocks
# A_i = Flags || Nonce || Counter_i
# Flags for counter = L-1
def ccm_format_ctr(nonce, counter_val):
    L = 15 - len(nonce)  # L = 3 for 12-byte nonce
    flags = L - 1  # Counter flags
    ctr_block = [flags] + list(nonce)
    # Encode counter in L bytes (big-endian)
    for i in range(L - 1, -1, -1):
        ctr_block.append((counter_val >> (8 * i)) & 0xFF)
    return ctr_block

# CCM: CBC-MAC computation over B0 || plaintext blocks
def ccm_cbc_mac(nonce, plaintext_bytes, tag_len, k0, k1, k2, k3, k4, k5, k6, k7):
    msg_len = len(plaintext_bytes)
    b0 = ccm_format_b0(nonce, msg_len, tag_len)

    # Start CBC-MAC: X_1 = E(K, B_0)
    x = aes_encrypt_block(b0, k0, k1, k2, k3, k4, k5, k6, k7)

    # Process plaintext blocks: X_{i+1} = E(K, X_i XOR B_i)
    for i in range(0, len(plaintext_bytes), 16):
        block = plaintext_bytes[i:i+16]
        # Pad last block with zeros if needed
        if len(block) < 16:
            block = block + [0] * (16 - len(block))
        x = aes_encrypt_block(xor_block(x, block), k0, k1, k2, k3, k4, k5, k6, k7)

    # Return first tag_len bytes as CBC-MAC value (T)
    return x[:tag_len]

# CCM: CTR mode encryption
def ccm_ctr_encrypt(nonce, plaintext_bytes, k0, k1, k2, k3, k4, k5, k6, k7):
    encrypted = []
    counter = 1  # CTR starts at 1 for payload (A_0 is for tag encryption)

    for i in range(0, len(plaintext_bytes), 16):
        block = plaintext_bytes[i:i+16]
        ctr_block = ccm_format_ctr(nonce, counter)
        keystream = aes_encrypt_block(ctr_block, k0, k1, k2, k3, k4, k5, k6, k7)

        for j in range(len(block)):
            encrypted.append(block[j] ^ keystream[j])

        counter += 1

    return encrypted

def process_vmem_file_for_aes_ccm_encryption(input_file):
    data_bytes = []

    # Read data ignoring address lines
    with open(input_file, 'r') as file:
        for line in file:
            if line.startswith('@'):
                continue
            data_bytes.extend(hex_str_to_u8_list(line))

    # Pad data_bytes to a multiple of 16 bytes (128 bits)
    while len(data_bytes) % 16 != 0:
        data_bytes.append(0x00)

    # AES key parts (256-bit key, same as GCM version)
    k0 = 0x2b7e1516
    k1 = 0x28aed2a6
    k2 = 0xabf71588
    k3 = 0x09cf4f3c
    k4 = 0xc0a1d2e3
    k5 = 0x34f9851b
    k6 = 0x2a47c932
    k7 = 0x6fbd8a7e

    # 12-byte nonce for CCM (same as GCM IV)
    nonce = [0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xAA, 0xBB]
    tag_len = 16  # 128-bit tag

    # Step 1: Compute CBC-MAC tag (T) over plaintext
    T = ccm_cbc_mac(nonce, data_bytes, tag_len, k0, k1, k2, k3, k4, k5, k6, k7)

    # Step 2: Encrypt tag with counter A_0
    a0 = ccm_format_ctr(nonce, 0)
    s0 = aes_encrypt_block(a0, k0, k1, k2, k3, k4, k5, k6, k7)
    tag = xor_block(T, s0)  # Encrypted tag

    # Step 3: CTR-encrypt the plaintext (counters A_1, A_2, ...)
    encrypted_bytes = ccm_ctr_encrypt(nonce, data_bytes, k0, k1, k2, k3, k4, k5, k6, k7)

    # Output in VMEM format: key (32B) + nonce (12B padded to 16B) + tag (16B) + ciphertext
    print('@00000000')
    key_bytes = sum([bytes_from_u32(k)[::-1] for k in [k0, k1, k2, k3, k4, k5, k6, k7]], [])
    print(' '.join(f'{b:02X}' for b in key_bytes))

    # Nonce (12 bytes) + 4 padding bytes
    nonce_line = list(nonce) + [0x00, 0x00, 0x00, 0x00]
    nonce_line_le = []
    for w_idx in range(0, 16, 4):
        nonce_line_le.extend(nonce_line[w_idx:w_idx+4][::-1])
    print(' '.join(f'{b:02X}' for b in nonce_line_le))

    # Tag (16 bytes)
    tag_le = []
    for w_idx in range(0, 16, 4):
        tag_le.extend(tag[w_idx:w_idx+4][::-1])
    print(' '.join(f'{b:02X}' for b in tag_le))

    # Ciphertext
    for i in range(0, len(encrypted_bytes), 16):
        line_bytes = encrypted_bytes[i:i+16]
        line_le = []
        for w_idx in range(0, 16, 4):
            line_le.extend(line_bytes[w_idx:w_idx+4][::-1])
        print(' '.join(f'{b:02X}' for b in line_le))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='AES-256-CCM encrypt a vmem file.')
    parser.add_argument('--file', '-f', type=str, help='The input vmem file')

    args = parser.parse_args()
    process_vmem_file_for_aes_ccm_encryption(args.file)
