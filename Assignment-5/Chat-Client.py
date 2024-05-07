from socket import socket, AF_INET, SOCK_STREAM
import random
import hashlib
from Crypto.Cipher import AES
from Crypto.Hash import SHA256
from Crypto.Util.Padding import pad, unpad
from base64 import b64encode, b64decode
import tkinter as tk
from tkinter import ttk
from tkinter import messagebox


####################
# Classes
####################
class Connection:
    def __init__(self, ip):
        self.ip = ip
        self.messages = []

class ChatWindow(tk.Toplevel):
    def __init__(self, parent, connection):
        super().__init__(parent)
        self.title(f"Chat with {connection.ip}")

        self.connection = connection

        self.chat_text = tk.Text(self)
        self.chat_text.pack(fill=tk.BOTH, expand=True)

        self.entry = tk.Entry(self)
        self.entry.pack(fill=tk.X, padx=5, pady=5)
        self.send_button = tk.Button(self, text="Send", command=self.send_message)
        self.send_button.pack(fill=tk.X, padx=5, pady=5)
        self.entry.bind("<Return>", self.send_message)

        self.update_messages()

    def encryptText(self, key, plaintext, iv):
    
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

    def decryptText(self, key, iv, ciphertext):
        
        # key for hashing must be same as encryption
        byte_key = int(key, 16).to_bytes(32, byteorder='big')
        
        byte_iv = int(iv, 16).to_bytes(16, byteorder='big')

        decoded_ciphertext = b64decode(ciphertext)

        # new AES object
        cipher = AES.new(byte_key, AES.MODE_CBC, byte_iv)
        plaintext = unpad(cipher.decrypt(decoded_ciphertext), AES.block_size)

        plaintext = plaintext.decode()

        return plaintext

    def send_message(self, event=None):
        message = self.entry.get()
        self.connection.messages.append(f"You: {message}\n\n")
        self.entry.delete(0, tk.END)
        self.chat_text.insert(tk.END, f"You: {message}\n\n")

        # Convert the message to a proper format before sending it to the server
        message = f"{self.connection.ip} | {message}"
        
        # Encrypt the message
        self.encryptText(symmetric_key_hash, message, iv_hash)

        # Send the encrypted message to the server
        client_socket.send(message.encode())

        # Receive the message from the server
        self.receive_message()

    def receive_message(self):
        ciphertext = client_socket.recv(2048).decode()

        # Decrypt the message
        message = self.decryptText(symmetric_key_hash, iv_hash, ciphertext)

        self.connection.messages.append(f"{self.connection.ip}: {message}\n\n")
        self.chat_text.insert(tk.END, f"{self.connection.ip}: {message}\n\n")

    def update_messages(self):
        self.chat_text.delete(1.0, tk.END)
        for message in self.connection.messages:
            self.chat_text.insert(tk.END, message)

class AddConnectionWindow(tk.Toplevel):
    def __init__(self, parent):
        super().__init__(parent)

        self.parrnt = parent

        self.title("Add Connection")
        self.geometry("300x100")

        self.ip_label = tk.Label(self, text="IP Address:")
        self.ip_label.pack(fill=tk.X, padx=5, pady=5)

        self.ip_entry = tk.Entry(self)
        self.ip_entry.pack(fill=tk.X, padx=5, pady=5)

        self.add_button = tk.Button(self, text="Add Connection", command=self.add_connection)
        self.add_button.pack(fill=tk.X, padx=5, pady=5)

    def add_connection(self):
        ip = self.ip_entry.get()
        if ip:
            self.parrnt.add_connection(Connection(ip))
            self.destroy()
        else:
            messagebox.showerror("Error", "IP Address cannot be empty")

class GUI(tk.Tk):
    def __init__(self, width, height):
        super().__init__()

        self.geometry(f"{width}x{height}")
        self.title("Connection Manager")

        self.connections = []
            
        # Allow the user to create a connection through the gui by entering an IP address and clicking a button to add it to the list
        self.add_connection_button = tk.Button(self, text="Add Connection", command=self.open_add_connection_window)
        self.add_connection_button.pack()

        self.connections_label = tk.Label(self, text="Connections:")
        self.connections_label.pack()

        self.connections_listbox = tk.Listbox(self)
        self.connections_listbox.pack(fill=tk.BOTH, expand=True)
        self.connections_listbox.bind("<Double-Button-1>", self.open_chat_window)

    def open_add_connection_window(self):
        add_connection_window = AddConnectionWindow(self)
        add_connection_window.grab_set()

    def add_connection(self, connection):
        self.connections.append(connection)
        self.update_connections_list()

    def update_connections_list(self):
        self.connections_listbox.delete(0, tk.END)
        for connection in self.connections:
            self.connections_listbox.insert(tk.END, f"{connection.ip}")

    def open_chat_window(self, event):
        selection = self.connections_listbox.curselection()
        if selection:
            index = selection[0]
            connection = self.connections[index]
            chat_window = ChatWindow(self, connection)
            chat_window.grab_set()


####################
# Functions
####################
def generate_key(username, password, prime_file="prime", g=2):
    
    # read in prime
    with open(prime_file, 'r') as f:
        prime_str = f.read().strip()
        p = int(prime_str.replace(':', ''), 16)

    # create a random 64 bit number for salt
    salt = random.getrandbits(64)

    # Hash the username, password, and salt to get the private key
    private_key = hashlib.sha256(f"{username}:{password}:{salt}".encode()).hexdigest()

    # Output private key to file as hex
    with open('client_private_key', 'w') as f:
        f.write(private_key)

    # Calculate the public key and convert to hex
    public_key = hex(pow(g, int(private_key, 16), p))[2:] # g^private_key mod p

    # Output public key to file as hex
    with open('client_public_key', 'w') as f:
        f.write(public_key)

    return private_key, public_key, p, g

def DHKeyExchange(client_socket, private_key, public_key, prime, g=2):

    global symmetric_key_hash, iv_hash
    
    try:
        print("-----------------------------------")
        print("Starting Key Exchange...")
        print("-----------------------------------")
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
        symmetric_key = str(pow(int(server_public_key, 16), int(private_key, 16), prime)).encode() # other_public_key^private_key mod p

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

    except:
        print("Client is shutting down...")

        # Close the client socket
        client_socket.close()
        exit()
    
def login(username, password, server_ip, window):
    global client_socket

    print(f"Username: {username}")
    print(f"Password: {password}")
    print(f"Server IP: {server_ip}")

    # Get the server IP address and port number
    server_port = int(9001)

    # Create a socket object
    client_socket = socket(AF_INET, SOCK_STREAM)
    client_socket.connect((server_ip, server_port))

    # Generate the private and public keys
    private_key, public_key, p, g = generate_key(username, password)

    # Start the DH Key Exchange
    DHKeyExchange(client_socket, private_key, public_key, p, g)

    # Destroy the main window
    window.destroy()

def login_window():
    
    WIDTH = 300
    HEIGHT = 300

    # Create the main window
    window = tk.Tk()
    window.title("Login")
    window.geometry(f"{WIDTH}x{HEIGHT}")

    # Create server ip, username, and password labels and entrys and place them in the the middle of the window
    fields = {}

    fields['server_ip_label'] = ttk.Label(text='Server IP Address:')
    fields['server_ip'] = ttk.Entry()

    fields['username_label'] = ttk.Label(text='Username:')
    fields['username'] = ttk.Entry()

    fields['password_label'] = ttk.Label(text='Password:')
    fields['password'] = ttk.Entry(show="*")


    for field in fields.values():
        field.pack(anchor=tk.W, padx=10, pady=5, fill=tk.X)

    ttk.Button(text='Login', command=lambda: login(fields['username'].get(), fields['password'].get(), fields['server_ip'].get(), window)).pack(anchor=tk.W, padx=10, pady=5)

    window.mainloop()


if __name__ == "__main__":
    login_window()
    app = GUI(400, 400)
    app.mainloop()
