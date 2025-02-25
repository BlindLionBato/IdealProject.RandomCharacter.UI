resource "aws_iam_policy" "codedeploy_read_access" {
  name        = "CodeDeploy_Read_Access_Policy"
  description = "Policy allowing read access to CodeDeploy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "codedeploy:CreateDeployment",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:GetApplicationRevision",
          "codedeploy:RegisterApplicationRevision"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "codedeploy_execute_access" {
  name        = "CodeDeploy_Execute_Access_Policy"
  description = "Policy allowing to start deploy processes with CodeDeploy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "codedeploy:CreateDeployment",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:GetApplicationRevision",
          "codedeploy:RegisterApplicationRevision",
          "codedeploy:CreateDeployment",
          "codedeploy:RegisterApplicationRevision"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}

output "codedeploy_read_access_policy" {
  value = {
    arn = aws_iam_policy.codedeploy_read_access.arn
  }
}

output "codedeploy_execute_access_policy" {
  value = {
    arn = aws_iam_policy.codedeploy_execute_access.arn
  }
}