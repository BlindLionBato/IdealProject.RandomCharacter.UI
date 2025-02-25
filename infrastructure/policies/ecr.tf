resource "aws_iam_policy" "ecr_read_access" {
  name        = "ECR_Read_Access_Policy"
  description = "Policy allowing read access to ECR"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:ListImages"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy" "ecr_full_access" {
  name        = "ECR_Full_Access_Policy"
  description = "Policy allowing write access to ECR for managing Docker images"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:ListImages",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DeleteImage"
        ],
        "Resource" : "*"
      }
    ]
  })
}

output "ecr_read_access_policy" {
  value = {
    arn  = aws_iam_policy.ecr_read_access.arn
    name = aws_iam_policy.ecr_read_access.name
  }
}

output "ecr_full_access_policy" {
  value = {
    arn  = aws_iam_policy.ecr_full_access.arn
    name = aws_iam_policy.ecr_full_access.name
  }
}