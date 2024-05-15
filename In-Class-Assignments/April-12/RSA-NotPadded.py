from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_OAEP
import sys

# parse args
if len(sys.argv) != 5:
    print("Usage: python3 RSA-Padded.py <d/e> <input file> <output file> <key file>")
    sys.exit(1)

mode = sys.argv[1]
inFile = sys.argv[2]
outFile = sys.argv[3]
keyFile = sys.argv[4]

key = RSA.import_key(open(keyFile).read())

# read file to be encrypted/decrypted
i = 0
if mode == 'd':
    byte_size = 512
elif mode == 'e':
    byte_size = 470

with open(inFile, "rb") as in_file:
    with open(outFile, 'wb') as output:
        bytes = in_file.read(byte_size) # read 500 bytes
        while bytes:
            if mode == 'd':
                # decryption
                decryptor = PKCS1_OAEP.new(key)
                processedBytes = decryptor.decrypt(bytes)
            elif mode == 'e':
                encryptor = PKCS1_OAEP.new(key)
                processedBytes = encryptor.encrypt(bytes)
            output.write(processedBytes)
            i += 1
            bytes = in_file.read(byte_size) # read another 500 bytes

# # print debug results
# print("Encrypted:", binascii.hexlify(encrypted))
# print("Decrypted:", decrypted.decode('utf-8'))