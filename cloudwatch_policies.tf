resource "aws_iam_policy" "cloudwatch_full_access" {
  name        = "CloudWatch_Full_Access_Policy"
  description = "Policy allowing read access to CloudWatch"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:*"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}