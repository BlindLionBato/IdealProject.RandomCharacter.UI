#!/bin/bash
sudo dnf install -y httpd mod_ssl openssl unzip

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

sudo openssl req -x509 -nodes -days 365 \
-newkey rsa:2048 \
-keyout /etc/httpd/conf/ssl.key \
-out /etc/httpd/conf/ssl.crt \
-subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

sudo sed -i 's|SSLCertificateFile.*|SSLCertificateFile /etc/httpd/conf/ssl.crt|' /etc/httpd/conf.d/ssl.conf
sudo sed -i 's|SSLCertificateKeyFile.*|SSLCertificateKeyFile /etc/httpd/conf/ssl.key|' /etc/httpd/conf.d/ssl.conf

aws s3 cp s3://ideal-project-random-character-ui-artefacts/dist.zip /tmp/dist.zip
sudo unzip /tmp/dist.zip -d /var/www/html/

sudo systemctl enable httpd
sudo systemctl start httpd