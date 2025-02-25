resource "aws_iam_role" "ec2_security_role" {
  name = "EC2_Access_Role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ecr_access_attachment" {
  role       = aws_iam_role.ec2_security_role.name
  policy_arn = module.policies.ecr_read_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "ec2_s3_access_attachment" {
  role       = aws_iam_role.ec2_security_role.name
  policy_arn = module.policies.s3_read_access_policy.arn
}

output "ec2_access_role" {
  value = {
    name = aws_iam_role.ec2_security_role.name
  }
}
