resource "aws_iam_policy" "s3_read_access" {
  name        = "S3_Read_Access_Policy"
  description = "Policy allowing read-only access to all S3 buckets"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetObjectAcl",
          "s3:GetObjectTagging",
          "s3:GetBucketLocation"
        ],
        "Resource" : [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "s3_full_access" {
  name        = "S3_Full_Access_Policy"
  description = "Policy allowing full access to all S3 buckets"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetObjectAcl",
          "s3:GetObjectTagging",
          "s3:GetBucketLocation",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:PutObjectAcl",
          "s3:PutObjectTagging",
          "s3:DeleteObjectTagging"
        ],
        "Resource" : [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*"
        ]
      }
    ]
  })
}