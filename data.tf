# Move to Terraform.Infrastructure.IdealProject.Global

data "aws_route53_zone" "main" {
  name = "random-character.org"  # Укажите ваш домен
}

data "aws_acm_certificate" "random-character" {
  domain             = "random-character.org"
  tags = {
    ProjectName = "IdealProject.RandomCharacter"
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]  # Получаем все подсети для default VPC
  }
}

