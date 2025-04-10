resource "aws_iam_role" "codedeploy" {
  name = "codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codedeploy.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_ec2" {
  role       = aws_iam_role.codedeploy.name
  policy_arn = aws_iam_policy.ec2_describe_access.arn
}

resource "aws_iam_role_policy_attachment" "codedeploy_cloudwatch" {
  role       = aws_iam_role.codedeploy.name
  policy_arn = aws_iam_policy.cloudwatch_full_access.arn
}

resource "aws_iam_role_policy_attachment" "codedeploy_s3" {
  role       = aws_iam_role.codedeploy.name
  policy_arn = aws_iam_policy.s3_read_access.arn
}

resource "aws_iam_role_policy_attachment" "codedeploy" {
  role       = aws_iam_role.codedeploy.name
  policy_arn = aws_iam_policy.codedeploy_full_access.arn
}