#!/bin/bash

# Install Utilities
sudo dnf install -y openssl unzip wget

# Install Docker
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to Docker access group
sudo usermod -aG docker ec2-user

# Install Nginx
sudo dnf install -y nginx

# Install AWS CLI v2
cd /home/ec2-user
mkdir awscliv2
cd awscliv2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install AWS SSM
sudo dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# Configure Nginx
sudo bash -c 'cat > /etc/nginx/conf.d/docker-proxy.conf <<EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF'

# Allow outbound connections
sudo ps -eZ | grep nginx
sudo setsebool -P httpd_can_network_connect 1

# Run SSM
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

# Run Docker
sudo systemctl enable --now docker
sudo systemctl start docker
sudo docker run -d -p 8080:80 docker/welcome-to-docker

# Run Nginx
sudo systemctl enable nginx
sudo systemctl start nginx