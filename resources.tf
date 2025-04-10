resource "aws_instance" "random_character_ui" {
  ami                  = "ami-0343a21cd4b9d8ee8"
  instance_type        = "t2.micro"
  key_name             = "IdealProject.EC2.KeyPair"
  vpc_security_group_ids = [aws_security_group.default_connections.id]
  iam_instance_profile = aws_iam_instance_profile.default_ec2_instance_profile.name
  user_data = file("./scripts/bootstrap.sh")

  tags = {
    Name = "IdealProject.RandomCharacter.UI"
  }
}

resource "aws_cloudwatch_log_group" "random_character_ui" {
  name              = "random-character-ui/pipeline"
  retention_in_days = 14
}

resource "aws_s3_bucket" "random_character_ui" {
  bucket = "random-character-ui-artefacts"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "default" {
  bucket = aws_s3_bucket.random_character_ui.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "default" {
  depends_on = [aws_s3_bucket_ownership_controls.default]

  bucket = aws_s3_bucket.random_character_ui.id
  acl    = "private"
}
