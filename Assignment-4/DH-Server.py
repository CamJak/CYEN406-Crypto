from socket import socket, AF_INET, SOCK_STREAM
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
username = str(input("Username: "))
password = str(input("Password: "))

### PRIVATE KEY ###
# hash the username, password, and salt to get the private key
private_key = hashlib.sha256(f"{username}:{password}:{salt}".encode()).hexdigest()

# output private key to file as hex (format: xx:xx:xx:xx:xx:xx:xx:xx)
with open('server_private_key', 'w') as f:
    f.write(private_key)

### PUBLIC KEY ###
# calculate the public key and convert to hex
public_key = hex(pow(g, int(private_key, 16), p))[2:] # g^private_key mod p

# output public key to file as hex (format: xx:xx:xx:xx:xx:xx:xx:xx)
with open('server_public_key', 'w') as f:
    f.write(public_key)

server_socket = socket(AF_INET, SOCK_STREAM)
server_socket.bind(('', 9001))
server_socket.listen(1)

while(True):
    try: 
        print("Server is ready to receive...\n")
        
        # Recieve connection from client
        connection_socket, address = server_socket.accept()

        # Receive the message from the client
        client_message = connection_socket.recv(2048)

        # Print the client's address and the message received
        print("Client Connected...")
        print("Client Address: ", address[0])
        print("Message Received: " + client_message.decode())
        print()

        # Check if the client is ready to receive the public key
        if client_message.decode() == "Start":
            print("Starting Key Exchange...")
            print()

            # Send the client a message to indicate that the server is ready
            return_message = "Ready"
            connection_socket.send(return_message.encode())

            # Receive the client's public key
            client_public_key = connection_socket.recv(2048).decode()

            # Print the client's public key
            print("Client Public Key: ", client_public_key)
            print()

            # Send the server's public key
            server_public_key = public_key
            connection_socket.send(server_public_key.encode())

            print("Public Key sent to client...")
            print()

            # create the symmetric (shared) key
            symmetric_key = str(pow(int(client_public_key, 16), int(private_key, 16), p)).encode() # other_public_key^private_key mod p

            # Print the symmetric key
            print("Symmetric Key: ", symmetric_key.decode())
            print()

            # hash the symmetric key using MD5 to create the IV
            iv_hash = hashlib.md5(symmetric_key).hexdigest()

            # hash the symmetric key using SHA256 to create the symmetric key hash
            symmetric_key_hash = hashlib.sha256(symmetric_key).hexdigest()

            # Output the IV and symmetric key hash to a file
            with open('session_key', 'w') as f:
                f.write(f"IV: {iv_hash}\n")
                f.write(f"Symmetric Key: {symmetric_key_hash}\n")
            
            # Receive the confirmation message from the client
            confirm_message = connection_socket.recv(2048)

            # Print the confirmation message
            print("Session Key: ", confirm_message.decode())
            print()

            test_confirm_message = hashlib.sha256(f"{symmetric_key_hash}{iv_hash}".encode()).hexdigest()
            # Check if the confirmation message is correct
            if confirm_message.decode() == test_confirm_message:

                # If the confirmation message is correct, send a return message to the client
                return_message = "Symmetric Key Confirmed..."
                connection_socket.send(return_message.encode())
                print("Symmetric Key Confirmed...")
                print()
                print("----------------------------------------")
                print()
            
            else:

                # If the confirmation message is incorrect, send a return message to the client
                return_message = "Symmetric Key Not Confirmed..."
                connection_socket.send(return_message.encode())
                print("Symmetric Key Not Confirmed...")
                print()
                print("----------------------------------------")
                print()

        else:

            # If the client is not ready to receive the public key, send a return message to the client
            return_message = "To begin key exchange, send 'Start' to the server.\n\nSteps: \n1. Send 'Start' to the server.\n2. Send your public key to the server.\n3. Receive the server's public key.\n4. Confirm the symmetric key by sending the hash of the symmetric key and the IV in the format: 'Symmetric Key Hash' + 'IV Hash' to the server."
            connection_socket.send(return_message.encode())

    except KeyboardInterrupt:
        print("\nServer is shutting down...")
        server_socket.close()
        break