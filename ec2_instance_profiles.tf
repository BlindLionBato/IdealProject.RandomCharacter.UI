resource "aws_iam_instance_profile" "default_ec2_instance_profile" {
  name = "Default_EC2_Instance_Profile"
  role = aws_iam_role.ec2.name
}