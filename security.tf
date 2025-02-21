resource "aws_security_group" "ec2_instance_security_group" {
  name        = "EC2 Security Group"

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

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2_Instance_Profile"
  role = aws_iam_role.ec2_access_role.name
}

resource "aws_iam_role" "ec2_access_role" {
  name = "EC2_Access_Role"
  assume_role_policy = file("./terraform-data/ec2/ec2_access_role.json")
}

resource "aws_iam_policy" "ecr_access_policy" {
  name        = "EC2_ECR_Access_Policy"
  description = "Policy allowing access to ECR for EC2 instances"
  policy = file("./terraform-data/ec2/ecr_access_policy.json")
}

resource "aws_iam_role_policy_attachment" "ecr_access_attachment" {
  role       = aws_iam_role.ec2_access_role.name
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}
