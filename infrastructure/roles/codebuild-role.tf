resource "aws_iam_role" "codebuild_security_role" {
  name = "CodeBuild_Access_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_cloudwatch_full_access_attachment" {
  role       = aws_iam_role.codebuild_security_role.name
  policy_arn = module.policies.cloudwatch_full_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_ecr_full_access_policy_attachment" {
  role       = aws_iam_role.codebuild_security_role.name
  policy_arn = module.policies.ecr_full_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_s3_full_access_policy_attachment" {
  role       = aws_iam_role.codebuild_security_role.name
  policy_arn = module.policies.s3_full_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_secretsmanager_read_access_policy_attachment" {
  role       = aws_iam_role.codebuild_security_role.name
  policy_arn = module.policies.secretsmanager_read_access_policy.arn
}

output "codebuild_security_role" {
  value = {
    arn  = aws_iam_role.codebuild_security_role.arn
    name = aws_iam_role.codebuild_security_role.name
  }
}