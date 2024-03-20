from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_OAEP
import binascii

msg = 'MEMBERS: Cameron Thomas, Blake Perrin, Charles McDonald, Ethan Clapp, Travis Knippers'

# Read PEM file
pubKey = RSA.import_key(open('public.pem').read())
privKey = RSA.import_key(open('private.pem').read())

# encryption
encryptor = PKCS1_OAEP.new(pubKey)
encrypted = encryptor.encrypt(str.encode(msg))

# decryption
decryptor = PKCS1_OAEP.new(privKey)
decrypted = decryptor.decrypt(encrypted)

print("Encrypted:", binascii.hexlify(encrypted))
print("Decrypted:", decrypted.decode('utf-8'))