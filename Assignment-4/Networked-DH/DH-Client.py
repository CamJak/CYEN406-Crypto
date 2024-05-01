from socket import socket, AF_INET, SOCK_STREAM
import random
import hashlib
from Crypto.Cipher import AES
from Crypto.Hash import SHA256
from Crypto.Util.Padding import pad, unpad
from base64 import b64encode, b64decode

def encryptText(key, plaintext, iv):
    
    # read key to use with hashing, key is 'rijndael'
    byte_key = int(key, 16).to_bytes(32, byteorder='big')

    byte_iv = int(iv, 16).to_bytes(16, byteorder='big')
    
    # read f to encrypt
    byte_plaintext = plaintext.encode()
    
    # new AES object
    cipher = AES.new(byte_key, AES.MODE_CBC, byte_iv)

    ciphertext_bytes = cipher.encrypt(pad(byte_plaintext, AES.block_size))

    # iv and ciphertext
    ciphertext = b64encode(ciphertext_bytes).decode('utf-8')

    return ciphertext

def decryptText(key, iv, ciphertext):
    
    # key for hashing must be same as encryption
    byte_key = int(key, 16).to_bytes(32, byteorder='big')
    
    byte_iv = int(iv, 16).to_bytes(16, byteorder='big')

    decoded_ciphertext = b64decode(ciphertext)

    # new AES object
    cipher = AES.new(byte_key, AES.MODE_CBC, byte_iv)
    plaintext = unpad(cipher.decrypt(decoded_ciphertext), AES.block_size)

    plaintext = plaintext.decode()

    return plaintext

########################
# DH Key Exchange
########################

# read in prime
with open('prime', 'r') as f:
    prime_str = f.read().strip()
    p = int(prime_str.replace(':', ''), 16)

# set generator
g = 2

# create a random 64 bit number for salt
salt = random.getrandbits(64)

# username and password
username = str(input("Username: "))
password = str(input("Password: "))

### PRIVATE KEY ###
# hash the username, password, and salt to get the private key
private_key = hashlib.sha256(f"{username}:{password}:{salt}".encode()).hexdigest()

# output private key to file as hex
with open('client_private_key', 'w') as f:
    f.write(private_key)

### PUBLIC KEY ###
# calculate the public key and convert to hex
public_key = hex(pow(g, int(private_key, 16), p))[2:] # g^private_key mod p

# output public key to file as hex
with open('client_public_key', 'w') as f:
    f.write(public_key)

# Get the server IP address and port number
server_ip = input("Please, enter server IP address: ")
server_port = input("Please, enter server port number: ")


while(True):
    try:

        # Create a socket object
        client_socket = socket(AF_INET, SOCK_STREAM)
        client_socket.connect((server_ip, int(server_port)))

        # Send a message to the server
        message = input("Please, enter message to send: ")
        print()
        client_socket.send(message.encode())

        # Receive a message from the server
        received_message = client_socket.recv(2048)
        
        # Check if the server is ready to start the key exchange
        if received_message.decode() == "Ready":
            print("Starting Key Exchange...")
            print()

            # Send the public key to the server
            client_socket.send(public_key.encode())
            print("Public Key sent to server...")
            print()

            # Receive the server's public key
            server_public_key = client_socket.recv(2048)
            print("Server Public Key: " + server_public_key.decode())
            print()

            # Create the symmetric (shared) key
            symmetric_key = str(pow(int(server_public_key, 16), int(private_key, 16), p)).encode() # other_public_key^private_key mod p

            # Print the symmetric (shared) key
            print("Symmetric Key: ", symmetric_key.decode())
            print()

            # Hash the symmetric key using MD5 to create the IV
            iv_hash = hashlib.md5(symmetric_key).hexdigest()

            # Hash the symmetric key using SHA256 to create the symmetric key hash
            symmetric_key_hash = hashlib.sha256(symmetric_key).hexdigest()

            # Send the confirmation message to the server
            confirm_message = hashlib.sha256(f"{symmetric_key_hash}{iv_hash}".encode()).hexdigest()
            client_socket.send(confirm_message.encode())
            print("Confirmation message sent to server...")
            print()

            # Receive the confirmation message from the server
            confirmation = client_socket.recv(2048)
            print("Server: " + confirmation.decode())
            print()

            while(True):
                
                try:
                    # Send an encrypted message to the server
                    message = input("Please, enter message to send: ")
                    print()

                    # Encrypt the message
                    ciphertext = encryptText(symmetric_key_hash, message, iv_hash)

                    # Send the encrypted message to the server
                    client_socket.send(ciphertext.encode())

                    # Receive a message from the server
                    received_message = client_socket.recv(2048)

                    # Print the received message
                    print("Server: " + received_message.decode())
                    print()
                
                except Exception as e:
                    print("Client is shutting down...")
                    
                    # Close the client socket
                    client_socket.close()
                    exit()

        else:
            # Print the received message
            print("Server: " + received_message.decode())
            print()

        client_socket.close()

    except KeyboardInterrupt:
        print("\nClient is shutting down...")
        break