#!/bin/bash

# Configuration
SERVER_IP="your_server_IP"# Change to your server IP
USERNAME="kptain" # Change to user's you want on the server
API_URL="http://$SERVER_IP:5000/generate-cert"
HOSTNAME=$(hostname)
KEY_PATH="$HOME/.ssh/id_rsa"
CERT_PATH="$HOME/.ssh/id_rsa-cert.pub"
TOKEN="some_secure_token"  # Change to your token

# 1. SSH key pair generation
ssh-keygen -t ecdsa -b 521 -f $KEY_PATH -N ""

# 2. Send public key for signature with authentication token
PUB_KEY=$(cat "${KEY_PATH}.pub")
CERT=$(curl -X POST -H "Authorization: Bearer $TOKEN" -F "public_key=$PUB_KEY" -F "username=kptain" -F "hostname=$HOSTNAME" $API_URL | jq -r '.certificate')

# 3. Store the certificate obtained
echo "$CERT" > $CERT_PATH

# 4. Configuring SSH to use the certificate
mkdir -p ~/.ssh/
chmod 700 ~/.ssh 
cat <<EOL >> ~/.ssh/config
Host $SEREVR_IP
    IdentityFile $KEY_PATH
    CertificateFile $CERT_PATH
    PubkeyAcceptedAlgorithms +ssh-ed25519,ssh-rsa,ecdsa-sha2-nistp256
EOL

chmod 600 ~/.ssh/config  # Assurez-vous que le fichier config a les bonnes permissions
