# Cyberstorm project

## Components

- encpart : a LUKS encrypted partition, the goal of the challenge is the decrypt this.

- mnt_part : a bash script that decrypts and mounts *encpart*; runs on boot.

## Process

- Problem : mnt_part is run on boot, but fails to run as part of the passphrase is missing.

- Solution : Use the content of mnt_part to create a password dictionary file, then use a script to test the dictionary against *encpart* (using hashcat is best).