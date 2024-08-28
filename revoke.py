import os
import subprocess
from pathlib import Path

CERTS_DIR = "/etc/ssh/certs/"
REVOKED_KEYS_FILE = "/etc/ssh/revoked_keys"
REVOKE_LIST_FILE = "/etc/ssh/revoked_certs.txt"

def revoke_certificates():
    # Vérifie si le fichier de certificats à révoquer existe
    if not os.path.exists(REVOKE_LIST_FILE):
        return  # Rien à faire
    
    # Lit les certificats à révoquer
    with open(REVOKE_LIST_FILE, 'r') as file:
        revoked_certs = file.read().splitlines()
    
    for cert in revoked_certs:
        cert_path = os.path.join(CERTS_DIR, cert)
        if os.path.exists(cert_path):
            # Ajoute le certificat au fichier de clés révoquées
            # Utilise ssh-keygen pour s'assurer que le certificat est correctement formaté
            subprocess.run(["ssh-keygen", "-kf", REVOKED_KEYS_FILE, "-u", cert_path], check=True)
            # Supprime le fichier du certificat
            os.remove(cert_path)
    
    # Efface la liste des certificats à révoquer
    open(REVOKE_LIST_FILE, 'w').close()

if __name__ == "__main__":
    revoke_certificates()
