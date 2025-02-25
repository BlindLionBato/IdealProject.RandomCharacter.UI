resource "aws_iam_role" "codepipeline_security_role" {
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

resource "aws_iam_role_policy_attachment" "codepipeline_cloudwatch_full_access_attachment" {
  role       = aws_iam_role.codepipeline_security_role.name
  policy_arn = module.policies.cloudwatch_full_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_codebuild_execute_access_attachment" {
  role       = aws_iam_role.codepipeline_security_role.name
  policy_arn = module.policies.codebuild_execute_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_codedeploy_execute_access_attachment" {
  role       = aws_iam_role.codepipeline_security_role.name
  policy_arn = module.policies.codedeploy_execute_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_codestar_connections_execute_access_attachment" {
  role       = aws_iam_role.codepipeline_security_role.name
  policy_arn = module.policies.codestar_connections_execute_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_s3_full_access_attachment" {
  role       = aws_iam_role.codepipeline_security_role.name
  policy_arn = module.policies.s3_full_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_ecr_write_access_attachment" {
  role       = aws_iam_role.codepipeline_security_role.name
  policy_arn = module.policies.ecr_full_access_policy.arn
}

output "codepipeline_role" {
  value = {
    arn  = aws_iam_role.codepipeline_security_role.arn
    name = aws_iam_role.codepipeline_security_role.name
  }
}