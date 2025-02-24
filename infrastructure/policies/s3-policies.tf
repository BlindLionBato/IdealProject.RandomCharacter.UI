resource "aws_iam_policy" "s3_read_access" {
  name        = "S3_Read_Access_Policy"
  description = "Policy allowing read-only access to all S3 buckets"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetObjectAcl",
          "s3:GetBucketLocation"
        ],
        "Resource": [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*"
        ]
      }
    ]
  })
}

output "s3_read_access_policy_arn" {
  value = aws_iam_policy.s3_read_access.arn
}