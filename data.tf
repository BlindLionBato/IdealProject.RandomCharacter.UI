# Move to Terraform.Infrastructure.IdealProject.Global

data "aws_route53_zone" "main" {
  name = "random-character.org"  # Укажите ваш домен
}