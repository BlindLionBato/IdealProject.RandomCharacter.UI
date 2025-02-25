resource "aws_iam_policy" "secretsmanager_read_access" {
  name        = "Secrets_Manager_Read_Access_Policy"
  description = "Policy allowing read-only access to all AWS secrets"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "secretsmanager:GetSecretValue",
        "Resource": "*"
      }
    ]
  })
}

output "secretsmanager_read_access_policy" {
  value = {
    arn = aws_iam_policy.secretsmanager_read_access.arn
  }
}