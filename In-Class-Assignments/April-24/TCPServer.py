from socket import *

server_socket = socket(AF_INET, SOCK_STREAM) # SOCK_STREAM refers to TCP-type connection
server_socket.bind(('138.47.155.35', 12001)) # (IP, Port No.)
server_socket.listen(1) # infinitely listen
print("The server is ready to receive...\n")

host = gethostname()

while(True):
    socket_cxn, address = server_socket.accept()
    request_cxn = socket_cxn.recv(2048)
    
    req_decoded = request_cxn.decode()

    print(f"Message:\n{req_decoded}")
    #print(f"Host: {gethostbyname(host)}\n")

    # #parse request
    # parsed = req_decoded.split()
    # mssg = parsed[0]
    # path = parsed[1]
    # version = parsed[2]

    # path_parsed = path.split("/")
    # obj = path_parsed[-1]    
    # print(f"Object to be fetched: {obj}")
    # # attempt to open and read the contents of obj if it exists
    # try:
    #     obj_cont = open(obj)
    #     content = obj_cont.read()
    #     print(f"Object content:\n{content}\n")
    #     code = 200
    #     resp_mssg = "OK"

    # except:
    #     code = 404
    #     resp_mssg = "Not Found"    

    # response = f"{version} {code} {resp_mssg}"
    # if code != 404:
    #     response += "\n\n" + str(content)
    # print(f"HTTP response message:\n{response}\n")

    response = "received request!"
    socket_cxn.send(response.encode())
