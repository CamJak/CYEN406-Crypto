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
private_key = int(hashlib.sha256(f"{username}:{password}:{salt}".encode()).hexdigest(), 16)

# output private key to file as hex (format: xx:xx:xx:xx:xx:xx:xx:xx)
with open('private_key', 'w') as f:
    private_key_str = ':'.join(f"{private_key}"[i:i+2] for i in range(0, len(f"{private_key}"), 2))
    f.write(private_key_str)


### PUBLIC KEY ###
# calculate the public key
public_key = int(pow(g, private_key, p)) # g^private_key mod p

# output public key to file as hex (format: xx:xx:xx:xx:xx:xx:xx:xx)
with open('public_key', 'w') as f:
    public_key_str = ':'.join(f"{public_key}"[i:i+2] for i in range(0, len(f"{public_key}"), 2))
    f.write(public_key_str)


### SYMMETRIC KEY ###
#TODO: get other person's public key later
# other_public_key = 0
other_public_key = int(input("Enter the other public key: ").replace(':', ''), 16)

# create the symmetric (shared) key
symmetric_key = pow(other_public_key, private_key, p) # other_public_key^private_key mod p

# hash the symmetric (shared) key and output
symmetric_key_bytes = symmetric_key.to_bytes((symmetric_key.bit_length() + 7) // 8, 'big')
symmetric_key_hash = hashlib.sha256(symmetric_key_bytes).hexdigest()

# output symmetric key to file as hex (format: xx:xx:xx:xx:xx:xx:xx:xx)
with open('symmetric_key', 'w') as f:
    symmetric_key_str = ':'.join(symmetric_key_hash[i:i+2] for i in range(0, len(symmetric_key_hash), 2))
    f.write(symmetric_key_str)