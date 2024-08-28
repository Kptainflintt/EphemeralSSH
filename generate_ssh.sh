#!/bin/bash

# Configuration
SERVER_IP="your_server_IP"# Change to your server IP
USERNAME="kptain" # Change to user's you want on the server
API_URL="http://$SERVER_IP:5000/generate-cert"
HOSTNAME=$(hostname)
KEY_PATH="$HOME/.ssh/id_rsa"
CERT_PATH="$HOME/.ssh/id_rsa-cert.pub"
TOKEN="448dcd00d1aef552d44e7854f68aaa151b37ed46cdcf1880b704349cd14e687a"  # Remplacez par le token préconfiguré

# 1. Génération de la paire de clés SSH
ssh-keygen -t ecdsa -b 521 -f $KEY_PATH -N ""

# 2. Envoi de la clé publique pour signature avec le token d'authentification
PUB_KEY=$(cat "${KEY_PATH}.pub")
CERT=$(curl -X POST -H "Authorization: Bearer $TOKEN" -F "public_key=$PUB_KEY" -F "username=kptain" -F "hostname=$HOSTNAME" $API_URL | jq -r '.certificate')

# 3. Stocker le certificat obtenu
echo "$CERT" > $CERT_PATH

# 4. Configurer SSH pour utiliser le certificat
mkdir -p ~/.ssh/
chmod 700 ~/.ssh  # Assurez-vous que le répertoire .ssh a les bonnes permissions
cat <<EOL >> ~/.ssh/config
Host $SEREVR_IP
    IdentityFile $KEY_PATH
    CertificateFile $CERT_PATH
    PubkeyAcceptedAlgorithms +ssh-ed25519,ssh-rsa,ecdsa-sha2-nistp256
EOL

chmod 600 ~/.ssh/config  # Assurez-vous que le fichier config a les bonnes permissions
