#Travis Knippers
# Assignment 2

DEBUG = False

from socket import *
from sys import argv

# if DEBUG:
#     print(argv[1:])
# # parse arguments
# host_ip = argv[1]
# host_port = argv[2]
# obj = argv[3]
# request = f"GET /{obj} HTTP/1.1"
host_ip = input("Enter the IP address of the server: ")
host_port = input("Enter the port number of the server: ")
request = input("Enter the message: ")

# Establish TCP Connection
client_socket = socket(AF_INET, SOCK_STREAM)
client_socket.connect((host_ip, int(host_port)))

if DEBUG: 
    print(f"Connection est. w {host_ip}")

# user types in request
print(f"HTTP request to server:\n{request}")

print(f"Host: {host_ip}\n")

client_socket.send(request.encode())

response = client_socket.recv(2048)
print(f"HTTP Response from server:\n{response.decode()}")

client_socket.close()
