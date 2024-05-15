from socket import socket, AF_INET, SOCK_STREAM
client_socket = socket(AF_INET, SOCK_STREAM)

server_ip = input("Please, enter server IP address: ")
server_port = input("Please, enter server port number: ")
client_socket.connect((server_ip, int(server_port)))

message = input("Please, enter message to send: ")
client_socket.send(message.encode())

received_message = client_socket.recv(2048)
print("Received message from server: " + received_message.decode())

client_socket.close()