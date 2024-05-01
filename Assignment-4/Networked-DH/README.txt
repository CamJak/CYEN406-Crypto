Usage for each of the programs in this directory is as follows:

# For DH-Server and DH-Client
Both of these programs work together to exchange a DH key. 
Once the key has been confirmed, the server will wait for an AES encrypted message from the client.
The server will receive this message and decrypt it, then send the decrypted message back to the client.

# For DH-Server(Send AES) and DH-Client(Receive AES)
Both of these programs work together to exchange a DH key.
Once the key has been confirmed, the server will wait for an AES encrypted message from the client.
The server will receive this message and decrypt it, it will then prompt the server user for a message to send back to the client.
The server will encrypt this message and send it back to the client.
The client will receive this message and decrypt it.
And the cycle will continue until the client sends a message that says "exit".