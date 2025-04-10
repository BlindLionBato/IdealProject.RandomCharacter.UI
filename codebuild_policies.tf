resource "aws_iam_policy" "codebuild_read_access" {
  name        = "CloudBuild_Read_Access_Policy"
  description = "Policy allowing read-only access to CodeBuild processes"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "codebuild:BatchGetBuilds"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy" "codebuild_execute_access" {
  name        = "CloudBuild_Execute_Access_Policy"
  description = "Policy allowing execute CodeBuild processes"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ],
        "Resource" : "*"
      }
    ]
  })
}