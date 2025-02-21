#!/bin/bash

# Exit on error
set -e

# Install required applications from repository
sudo dnf install -y httpd mod_ssl openssl unzip nano

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install and run Docker
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -a -G docker ec2-user

# Authenticate in the AWS ECR repository
aws ecr get-login-password --region eu-west-1 | \
sudo docker login --username AWS --password-stdin 756244214202.dkr.ecr.eu-west-1.amazonaws.com

# Run the Random Character image
sudo docker pull 756244214202.dkr.ecr.eu-west-1.amazonaws.com/random-character-ui:latest
sudo docker run -d -p 8080:80 756244214202.dkr.ecr.eu-west-1.amazonaws.com/random-character-ui:latest

# Create self-signed certificate for HTTPS connection
SSL_CERT="/etc/httpd/conf/ssl.crt"
SSL_KEY="/etc/httpd/conf/ssl.key"

sudo openssl req -x509 -nodes -days 365 \
-newkey rsa:2048 \
-keyout /etc/httpd/conf/ssl.key \
-out /etc/httpd/conf/ssl.crt \
-subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Add self-signed certificate to Apache
sudo sed -i "s|SSLCertificateFile.*|SSLCertificateFile $SSL_CERT|" /etc/httpd/conf.d/ssl.conf
sudo sed -i "s|SSLCertificateKeyFile.*|SSLCertificateKeyFile $SSL_KEY|" /etc/httpd/conf.d/ssl.conf

# Create configuration file for Apache
APACHE_CONFIG="/etc/httpd/conf.d/ssl-proxy.conf"

echo "Creating Apache SSL proxy configuration..."

sudo bash -c "cat > $APACHE_CONFIG" <<EOL
<VirtualHost *:443>
    ServerName localhost

    SSLEngine on
    SSLCertificateFile $SSL_CERT
    SSLCertificateKeyFile $SSL_KEY

    # Reverse Proxy Settings
    ProxyPreserveHost On
    ProxyPass / http://127.0.0.1:8080/
    ProxyPassReverse / http://127.0.0.1:8080/

    # Logs
    ErrorLog /var/log/httpd/ssl-proxy-error.log
    CustomLog /var/log/httpd/ssl-proxy-access.log combined
</VirtualHost>
EOL

# Add reverse proxy module to Apache
HTTPD_CONF="/etc/httpd/conf/httpd.conf"

if ! sudo grep -q "LoadModule proxy_module modules/mod_proxy.so" "$HTTPD_CONF"; then
  echo "Добавление LoadModule proxy_module..."
  echo "LoadModule proxy_module modules/mod_proxy.so" | sudo tee -a "$HTTPD_CONF" > /dev/null
else
  echo "LoadModule proxy_module уже присутствует в $HTTPD_CONF"
fi

if ! sudo grep -q "LoadModule proxy_http_module modules/mod_proxy_http.so" "$HTTPD_CONF"; then
  echo "Добавление LoadModule proxy_http_module..."
  echo "LoadModule proxy_http_module modules/mod_proxy_http.so" | sudo tee -a "$HTTPD_CONF" > /dev/null
else
  echo "LoadModule proxy_http_module уже присутствует в $HTTPD_CONF"
fi

# Validate Apache configuration
echo "Checking Apache configuration..."
sudo apachectl configtest

# Allow external connections
sudo setsebool -P httpd_can_network_connect on

# Run Apache
sudo systemctl enable httpd
sudo systemctl start httpd