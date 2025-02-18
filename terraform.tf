provider "aws" {

}

resource "aws_instance" "my_server" {
  ami           = "ami-0343a21cd4b9d8ee8"
  instance_type = "t2.micro"
  key_name      = "IdealProject.EC2.KeyPair"
  vpc_security_group_ids = [aws_security_group.sg_my_server.id]
  user_data = <<EOF
#!/bin/bash
sudo dnf -y update --refresh
sudo dnf install -y httpd mod_ssl openssl

openssl req -x509 -nodes -days 365 \
-newkey rsa:2048 \
-keyout /etc/httpd/conf/ssl.key \
-out /etc/httpd/conf/ssl.crt \
-subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

sed -i 's|SSLCertificateFile.*|SSLCertificateFile /etc/httpd/conf/ssl.crt|' /etc/httpd/conf.d/ssl.conf
sed -i 's|SSLCertificateKeyFile.*|SSLCertificateKeyFile /etc/httpd/conf/ssl.key|' /etc/httpd/conf.d/ssl.conf

echo "<h2>Hello World!</h2>" | sudo tee /var/www/html/index.html

sudo systemctl enable httpd
sudo systemctl start httpd
EOF
}

resource "aws_security_group" "sg_my_server" {
  name        = "HTTP Security Group"
  description = "MyServer Security Group"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}