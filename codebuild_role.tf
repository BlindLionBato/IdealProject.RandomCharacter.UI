resource "aws_iam_role" "codebuild" {
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

resource "aws_iam_role_policy_attachment" "codebuild_cloudwatch_full_access" {
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.cloudwatch_full_access.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_s3_full_access" {
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.s3_full_access.arn
}