resource "aws_iam_policy" "ec2_describe_access" {
  name        = "EC2-Describe-Access-Policy"
  description = "IAM policy granting permissions to describe EC2 instances and related resources."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:Get*",
          "ec2:List*"
        ]
        Resource = "*"
      }
    ]
  })
}