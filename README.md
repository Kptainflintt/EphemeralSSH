# EphemeralSSH
Flask API for signin certificates to provide temporary SSH acces (without pain)

## Why ?
Sometimes, I want a VM or wathever to rsync some files from a server. To do that, I have to generate key pair, and send public key on server. After some time (and because I don't think to clear it), my authorized_keys file contain lot of entries, and access is still active since I delete them.
Instead of doing that, I think about having a simple way to have a SSH connexion without generating and sending keys manually but also having a simple way to revoke all access if I want.
IMPORTANT : I strongly advise you to put this API behind a reverse proxy to be able to use it in HTTPS!

## Features

Server side, this API : 
1. Wait for POST request with client's public key, all conexions must have a token in header
2. Sign it with local CA (may be another one if you want, just provide CA private Key)
3. Add certificate to a trusted folder
4. Add certificate to revokation list
5. Revoke certificates based on python script, which can be executed manually or by cron job (for example to provide a one hour access)

Client side a bash script which:
1. Create key pair
2. Send public key to API endpoint with some other infos (username, hostname)
3. Save certificate to user's path
4. Add ssh config to use it.

## Install
**WARNING** : This steps work on a AlmaLinux server, and was made for my needs; you have to adapt it for other OS or other config.
Actually, what it does : 
- Using port 5000 to work
- Use /etc/ssh/certs folder to wrote certificates files
- Use /etc/ssh/revoked_certs.txt to maintain list of certificate to revoke
- Use /etc/ssh/revoked_keys to store revoked one
- Execute every day at 3 AM the script to revoke
- Use ecdsa 512 keys

### Server side

1. Get this repo : 
```
git clone https://github.com/Kptainflintt/EphemeralSSH
cd Ephemeral SSH
```
2. Execute install :
```
chmod u+x install.sh
./install.sh
```


### Client side

First of all : **you must install jq**
On generate.sh file, add : 
- Server's IP
- Server's user (to make connexions with)
- Token

# To DO

Make it more user-friendly and for other OS
Ask for some config items (paths, users, etc.)
