from socket import socket, AF_INET, SOCK_STREAM

server_socket = socket(AF_INET, SOCK_STREAM)
server_socket.bind(('', 12345))
server_socket.listen(1)
print("Server is ready to receive...\n")

while(True):
    connection_socket, address = server_socket.accept()
    incoming_message = connection_socket.recv(2048)

    print("Data: ")
    print(incoming_message.decode())

    return_message = "Message Received..."


    connection_socket.send(return_message.encode())
    connection_socket.close()