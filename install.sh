#!/bin/bash

# Install dependencies and flask
sudo yum update -y
sudo yum install -y openssh-server openssh-client python3 
sudo yum install -y python3-pip policycoreutils-python-utils
sudo pip3 install flask

# Generate CA key pair and certs folder and revokation file
sudo ssh-keygen -t ecdsa -b 521 -f /etc/ssh/ssh_ca -N ""
sudo chmod 600 /etc/ssh/ssh_ca
sudo chmod 644 /etc/ssh/ssh_ca.pub
sudo mkdir /etc/ssh/certs
echo "@cert-authority X.X.X.X $(cat /etc/ssh/ssh_ca.pub)" | sudo tee -a /etc/ssh/ssh_known_hosts # Put CA's IP here
sudo ssh-keygen -kf /etc/ssh/revoked_keys

# Modify sshd config 
sudo bash-c "cat <<EOL >> /etc/ssh/sshd_config
TrustedUserCAKeys /etc/ssh/ssh_ca.pub
RevokedKeys /etc/ssh/revoked_keys
EOL"
sudo systemctl restart sshd

# Open port and manage SELinux
sudo firewall-cmd --zone=public --add-port=5000/tcp --permanent
sudo semanage port -a -t http_cache_port_t -p tcp 5000

#Generate token and write it to files
TOKEN=$(openssl rand -hex 32) 
sed -i s/some_secure_token/$TOKEN/g app.py
sed -i s/some_secure_token/$TOKEN/g generate.sh
echo "Your token is $TOKEN"

# Copy flask app file and create service
sudo mv app.py /opt/
sudo mv ssh_cert_api.service /etc/systemd/system/
sudo /sbin/restorecon -v /etc/systemd/system/ssh_cert_api.service
sudo systemctl enable ssh_cert_api
sudo systemctl start ssh_cert_api

# Add cronjob
sudo mv revoke.py /root/
sudo crontab -l 2>/dev/null; echo "0 3 * * * /usr/bin/python3 /root/revoke.py" | sudo crontab -

echo "The API is in place, you can distribute generate.sh script to clients"
