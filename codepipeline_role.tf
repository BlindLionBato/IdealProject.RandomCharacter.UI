resource "aws_iam_role" "codepipeline" {
  name = "CodePipeline_Access_Role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codepipeline.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_cloudwatch" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.cloudwatch_full_access.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_codebuild_execute" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.codebuild_execute_access.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_codedeploy_execute" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.codedeploy_execute_access.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_codestar_connections_execute" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.codestar_connections_execute_access.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_s3_full_access" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.s3_full_access.arn
}