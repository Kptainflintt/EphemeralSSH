from flask import Flask, request, jsonify, abort
import subprocess
import os
import tempfile
import shutil
import time

app = Flask(__name__)

CA_PRIVATE_KEY = "/etc/ssh/ssh_ca"
CERTS_DIR = "/etc/ssh/certs/"
API_TOKEN = "some_secure_token"  # Replace with your secure token
REVOKED_LIST_FILE = "/etc/ssh/revoked_certs.txt"

@app.route('/generate-cert', methods=['POST'])
def generate_cert():
    token = request.headers.get('Authorization')
    if token != f"Bearer {API_TOKEN}":
        abort(403, "Invalid token")

    public_key = request.form.get('public_key')
    username = request.form.get('username')
    hostname = request.form.get('hostname')

    if not public_key or not username:
        return jsonify({"error": "Missing public_key or username"}), 400

    with tempfile.NamedTemporaryFile(delete=False) as pubkey_file:
        pubkey_file.write(public_key.encode())
        pubkey_file_path = pubkey_file.name

    cert_id = f"{hostname}-{int(time.time())}"
    serial_number = str(int(time.time()))
    cert_file_path = os.path.join(CERTS_DIR, f'{hostname}-{serial_number}-cert.pub')

    subprocess.run([
        "ssh-keygen", "-s", CA_PRIVATE_KEY, "-I", cert_id, "-n", username,
        "-V", "+1w", "-z", serial_number, pubkey_file_path
    ], check=True)

    # Move the signed certificate to the correct location
    shutil.move(pubkey_file_path + "-cert.pub", cert_file_path)

    with open(cert_file_path, 'r') as cert_file:
        cert_data = cert_file.read()

    os.remove(pubkey_file_path)

    # Add certificate to revoked list
    with open(REVOKED_LIST_FILE, 'a') as file:
        file.write(f'{hostname}-{serial_number}-cert.pub\n')

    return jsonify({"certificate": cert_data})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
