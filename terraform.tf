terraform {
  backend "s3" {
    bucket         = "ideal-project-terraform-states"
    key            = "dev/random-character-ui.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

provider "aws" {

}

module "roles" {
  source = "./infrastructure/roles"
}

module "security_groups" {
  source = "./infrastructure/security-groups"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2_Instance_Profile"
  role = module.roles.ec2_access_role_name
}

resource "aws_instance" "random_character_server" {
  ami                  = "ami-0343a21cd4b9d8ee8"
  instance_type        = "t2.micro"
  key_name             = "IdealProject.EC2.KeyPair"
  vpc_security_group_ids = [
    module.security_groups.allow_default_connections_id
  ]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  user_data            = file("./infrastructure/scripts/ec2/bootstrap.sh")
}