resource "aws_ecr_repository" "random_character_ui" {
  name                 = "random-character-ui"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true
}

resource "aws_iam_instance_profile" "default_profile" {
  name = "Default_EC2_Instance_Profile"
  role = module.ec2_role.name
}

resource "aws_instance" "random_character_ui" {
  ami = "ami-0343a21cd4b9d8ee8"
  instance_type = "t2.micro"
  key_name = "IdealProject.EC2.KeyPair"
  vpc_security_group_ids = [aws_security_group.default_security_group.id]
  iam_instance_profile = aws_iam_instance_profile.default_profile.name
  user_data = file("./scripts/bootstrap.sh")

  tags = {
    Name = local.project_name
  }
}