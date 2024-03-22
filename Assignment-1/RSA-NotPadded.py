from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_OAEP
import rsa as RSA_INSECURE
import binascii
import sys

# parse args
if len(sys.argv) != 5:
    print("Usage: python3 RSA-Padded.py <d/e> <input file> <output file> <key file>")
    sys.exit(1)

mode = sys.argv[1]
inFile = sys.argv[2]
outFile = sys.argv[3]
keyFile = sys.argv[4]

# read PEM file
key = RSA.import_key(open(keyFile).read())

# read file to be encrypted/decrypted
with open(inFile, 'rb') as file:
    msg = file.read()

if mode == 'd':
    # decryption
    decrypted = RSA_INSECURE.decrypt(msg, key)
    # write encrypted message to file
    with open(outFile, 'wb') as file:
        file.write(decrypted)
elif mode == 'e':
    # encryption
    encrypted = RSA_INSECURE.encrypt(msg, key)
    # write encrypted message to file
    with open(outFile, 'wb') as file:
        file.write(encrypted)

# # print debug results
# print("Encrypted:", binascii.hexlify(encrypted))
# print("Decrypted:", decrypted.decode('utf-8'))