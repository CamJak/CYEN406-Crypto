from Crypto.Cipher import AES
from Crypto.Hash import SHA256
from base64 import b64encode, b64decode
import json
import sys

def encryptFile(keyFile, targetFile):
    
    # read key to use with hashing, key is 'rijndael'
    with open(keyFile, 'rb') as f:
        key = f.read()
    
    hashObj = SHA256.new(key)
    
    # read plaintext to encrypt
    with open(targetFile, 'rb') as f:
        plainText = f.read()
    
    # new AES object
    cipher = AES.new(hashObj.digest(), AES.MODE_EAX)
    ciphertext, tag = cipher.encrypt_and_digest(plainText)

    # keys and values for .json file to store encrypted data
    json_keys = ['nonce', 'ciphertext', 'tag']
    json_values = [b64encode(x).decode('utf-8') for x in (cipher.nonce, ciphertext, tag)]

    # package json dictionary
    encryption_json = json.dumps(dict(zip(json_keys, json_values)))
    
    # write output file 
    with open("encrypted_msg.json", "w") as outfile:
        outfile.write(encryption_json)

    print("Encryption complete: 'encrypted_msg.json' created.")

def decryptFile(keyFile, targetFile):
    
    # key for hashing must be same as encryption
    with open(keyFile, 'rb') as f:
        key = f.read()
    
    hashObj = SHA256.new(key)

    # try except for weird json formatting
    try:
        with open(targetFile) as f:
            js = json.load(f)
        
        #unpack and decode encrypted .json
        json_keys = ['nonce', 'ciphertext', 'tag']
        jvals = {k: b64decode(js[k]) for k in json_keys}

        # new AES object
        cipher = AES.new(hashObj.digest(), AES.MODE_EAX, nonce = jvals['nonce'])
        plainText = cipher.decrypt_and_verify(jvals['ciphertext'], jvals['tag'])

        # writes output file 
        with open("decrypted_msg.txt", 'w') as outfile:
            outfile.write(plainText.decode('utf-8'))

        print("Decryption complete: 'decrypted_msg.txt' created.")
    except (ValueError, KeyError):
            print("Decryption Error")
            
# MAIN
if __name__ == "__main__":
    
    if (len(sys.argv) < 4):
        print(f"Usage (encryption):\npython3 aes.py <e> <key file> <target file>\n")
        print(f"Usage (decryption):\n python3 aes.py <d> <key file> <encrypted json file>")
        sys.exit(1)

    mode = sys.argv[1]
    keyFile = sys.argv[2]
    targetFile = sys.argv[3]

    if mode == 'e':    
        encryptFile(keyFile, targetFile)
    elif mode == 'd':    
        decryptFile(keyFile, targetFile)
    else:
        print("Incorrect command, try:\n")
        print(f"Usage (encryption):\npython3 aes.py <e> <key file> <target file>\n")
        print(f"Usage (decryption):\n python3 aes.py <d> <key file> <encrypted json file>")
        sys.exit(1)
