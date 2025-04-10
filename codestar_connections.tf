resource "aws_iam_policy" "codestar_connections_read_access" {
  name        = "CodeStar_Connections_Read_Access_Policy"
  description = "Policy allowing read-only access to CodeStar Connections"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "codestar-connections:GetConnection",
          "codestar-connections:ListConnections",
          "codestar-connections:ListTagsForResource"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy" "codestar_connections_execute_access" {
  name        = "CodeStar_Connections_Execute_Access_Policy"
  description = "Policy allowing execution access to CodeStar Connections"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "codestar-connections:GetConnection",
          "codestar-connections:ListConnections",
          "codestar-connections:ListTagsForResource",
          "codestar-connections:UseConnection"
        ],
        "Resource" : "*"
      }
    ]
  })
}