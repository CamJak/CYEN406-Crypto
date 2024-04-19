import random
import hashlib

# read in prime
with open('prime', 'r') as f:
    prime_str = f.read().strip()
    p = int(prime_str.replace(':', ''), 16)

# set generator
g = 2

# create a random 64 bit number for salt
salt = random.getrandbits(64)

# username and password
# username = "alice"
# password = "password123"
username = str(input("Username: "))
password = str(input("Password: "))

### PRIVATE KEY ###
# hash the username, password, and salt to get the private key
private_key = hashlib.sha256(f"{username}:{password}:{salt}".encode()).hexdigest()

# output private key to file as hex (format: xx:xx:xx:xx:xx:xx:xx:xx)
with open('private_key', 'w') as f:
    f.write(private_key)


### PUBLIC KEY ###
# calculate the public key and convert to hex
public_key = hex(pow(g, int(private_key, 16), p))[2:] # g^private_key mod p

# output public key to file as hex (format: xx:xx:xx:xx:xx:xx:xx:xx)
with open('public_key', 'w') as f:
    f.write(public_key)


### SYMMETRIC KEY ###
#TODO: get other person's public key later
# other_public_key = 0
other_public_key = int(input("Enter the other public key: ").replace(':', ''), 16)

# create the symmetric (shared) key
symmetric_key = str(pow(other_public_key, int(private_key, 16), p)).encode() # other_public_key^private_key mod p

iv_hash = hashlib.md5(symmetric_key).hexdigest()

# hash the symmetric (shared) key and output
#symmetric_key_bytes = symmetric_key.to_bytes((symmetric_key.bit_length() + 7) // 8, 'big')
symmetric_key_hash = hashlib.sha256(symmetric_key).hexdigest()

with open('aes_key', 'w') as f:
    f.write(f"IV: {iv_hash}\n")
    f.write(f"Symmetric Key: {symmetric_key_hash}\n")