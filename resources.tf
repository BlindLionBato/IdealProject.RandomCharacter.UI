variable "ssh_key_name" {
  description = "SSH ключ для подключения к Worker Nodes"
  type        = string
  default     = "IdealProject.EC2.KeyPair"
}

variable "domain_name" {
  description = "Имя домена для Route53"
  type        = string
  default = "random-character.org"
}

# --- Шаг 1. Создание VPC и подсетей ---

# VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "eks-vpc"
  }
}

# Интернет-шлюз (Internet Gateway)
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "eks-igw"
  }
}

# Основная таблица маршрутизации для публичных подсетей
resource "aws_route_table" "eks_public_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "eks-public-route-table"
  }
}

# Публичные подсети
resource "aws_subnet" "eks_public_subnet" {
  count                   = 3
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block = cidrsubnet("10.0.0.0/16", 8, count.index)
  availability_zone = element(["eu-west-1a", "eu-west-1b", "eu-west-1c"], count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "eks-public-subnet-${count.index}"
  }
}

# Ассоциация подсетей с таблицей маршрутизации
resource "aws_route_table_association" "eks_public_subnet_assoc" {
  count          = 3
  subnet_id      = aws_subnet.eks_public_subnet[count.index].id
  route_table_id = aws_route_table.eks_public_route_table.id
}

# --- Шаг 2. Создание EKS-кластера ---

# Роль IAM для кластера
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Разрешения для кластера
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_cni_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# Сам кластер
resource "aws_eks_cluster" "eks_cluster" {
  name     = "my-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = aws_subnet.eks_public_subnet[*].id
  }

  tags = {
    Name = "eks-cluster"
  }
}

# --- Шаг 3. Worker Nodes ---

# Роль IAM для Worker Nodes
resource "aws_iam_role" "eks_worker_node_role" {
  name = "eks-worker-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Разрешения для Worker Nodes
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_worker_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_worker_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Создание профиля экземпляра для EC2 Worker Nodes
resource "aws_iam_instance_profile" "eks_instance_profile" {
  name = "eks-instance-profile"
  role = aws_iam_role.eks_worker_node_role.name
}


data "aws_ami" "eks_worker_ami" {
  most_recent = true
  owners      = ["602401143452"] # AWS EKS AMI Owner ID for Amazon Linux 2

  # Фильтр по AMI для EKS (замените "1.26" на вашу версию Kubernetes, если она отличается)
  filter {
    name   = "name"
    values = ["amazon-eks-node-1.26-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}


# Группа запуска для EC2 инстансов
resource "aws_launch_template" "eks_worker_nodes" {
  name_prefix = "eks-worker"

  iam_instance_profile {
    name = aws_iam_instance_profile.eks_instance_profile.name
  }

  instance_type = "t3.medium"
  key_name      = var.ssh_key_name
  image_id = data.aws_ami.eks_worker_ami.id

  user_data = base64encode(<<-EOT
    #!/bin/bash
    /etc/eks/bootstrap.sh ${aws_eks_cluster.eks_cluster.name}
  EOT
  )
}

# Автоскейлинг-группа
resource "aws_autoscaling_group" "eks_workers_asg" {
  desired_capacity    = 2
  max_size            = 5
  min_size            = 1
  vpc_zone_identifier = aws_subnet.eks_public_subnet[*].id

  launch_template {
    id      = aws_launch_template.eks_worker_nodes.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "eks-worker"
    propagate_at_launch = true
  }
}

# --- Шаг 4. Route53 DNS ---

resource "aws_route53_record" "eks_dns" {
  zone_id = data.aws_route53_zone.main.id
  name = "eks.${var.domain_name}"
  type = "CNAME"
  ttl  = "300"
  records = [aws_eks_cluster.eks_cluster.endpoint]
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_node_role_arn" {
  description = "IAM роль для Worker Nodes"
  value       = aws_iam_role.eks_worker_node_role.arn
}

resource "aws_ecr_repository" "random_character_ui" {
  name                 = "random-character-ui"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true
}