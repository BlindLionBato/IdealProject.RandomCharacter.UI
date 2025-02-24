resource "aws_iam_policy" "ecr_read_access" {
  name        = "ECR_Read_Access_Policy"
  description = "Policy allowing read access to ECR"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ],
        "Resource": "*"
      }
    ]
  })
}

output "ecr_read_access_policy_arn" {
  value = aws_iam_policy.ecr_read_access.arn
}