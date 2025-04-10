#!/bin/bash
# Устанавливаем необходимые пакеты
sudo dnf install -y httpd mod_ssl openssl unzip ruby wget

# Переходим в папку пользователя
cd /home/ec2-user

# Устанавливаем AWS CLI v2
mkdir awscliv2
cd awscliv2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Настройка SSL (самоподписанный сертификат)
sudo openssl req -x509 -nodes -days 365 \
-newkey rsa:2048 \
-keyout /etc/httpd/conf/ssl.key \
-out /etc/httpd/conf/ssl.crt \
-subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

sudo sed -i 's|SSLCertificateFile.*|SSLCertificateFile /etc/httpd/conf/ssl.crt|' /etc/httpd/conf.d/ssl.conf
sudo sed -i 's|SSLCertificateKeyFile.*|SSLCertificateKeyFile /etc/httpd/conf/ssl.key|' /etc/httpd/conf.d/ssl.conf

# Предварительно создаём пустую директорию для приложения и настраиваем права
sudo mkdir -p /var/www/html
sudo chown -R apache:apache /var/www/html

# Включаем и запускаем веб-сервер Apache
sudo systemctl enable httpd
sudo systemctl start httpd

# === Установка и запуск агента AWS CodeDeploy (совместимо с RHEL) ===
cd /home/ec2-user
mkdir codedeploy
cd codedeploy
wget https://aws-codedeploy-eu-west-1.s3.eu-west-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo systemctl enable codedeploy-agent
sudo systemctl start codedeploy-agent