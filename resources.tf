resource "aws_route53_record" "main_record" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "random-character.org"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb" "main" {
  name               = "random-character-ui"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer.id]
  subnets            = data.aws_subnets.default.ids
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"

  certificate_arn   = data.aws_acm_certificate.random-character.arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_lb_target_group" "main" {
  name     = "random-character-ui"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 3
    matcher             = "200"
  }
}

resource "aws_lb_target_group_attachment" "ec2_attachment" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.random_character_ui.id
  port             = 80
}

resource "aws_instance" "random_character_ui" {
  ami = "ami-0343a21cd4b9d8ee8"
  instance_type = "t2.micro"
  key_name = "IdealProject.EC2.KeyPair"
  vpc_security_group_ids = [aws_security_group.ec2.id]
  subnet_id     = data.aws_subnets.default.ids[0]
  iam_instance_profile = aws_iam_instance_profile.default_profile.name
  user_data = file("./scripts/bootstrap.sh")

  tags = {
    Name = local.project_name
  }
}

resource "aws_iam_instance_profile" "default_profile" {
  name = "Default_EC2_Instance_Profile"
  role = module.ec2_role.name
}

resource "aws_ecr_repository" "random_character_ui" {
  name                 = "random-character-ui"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true
}