terraform {
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }

  backend "s3" {
    bucket         = "ideal-project-terraform-states"
    key            = "dev/random-character-ui.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

provider "aws" {

}

resource "aws_instance" "random_character_server" {
  ami                  = "ami-0343a21cd4b9d8ee8"
  instance_type        = "t2.micro"
  key_name             = "IdealProject.EC2.KeyPair"
  vpc_security_group_ids = [aws_security_group.ec2_instance_security_group.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  user_data            = file("./terraform-data/ec2/bootstrap.sh")
}

resource "aws_s3_bucket" "artefacts_s3_bucket" {
  bucket = "ideal-project-random-character-ui-artefacts"
}

resource "aws_s3_bucket_ownership_controls" "artefacts_s3_bucket_ownership" {
  bucket = aws_s3_bucket.artefacts_s3_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "artefacts_s3_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.artefacts_s3_bucket_ownership]

  bucket = aws_s3_bucket.artefacts_s3_bucket.id
  acl    = "private"
}

resource "archive_file" "random_character_ui_artefact" {
  type        = "zip"
  source_dir = "./dist"
  output_path = "./dist.zip"
}

resource "aws_s3_object" "random_character_ui_artefact_s3_object" {
  bucket = aws_s3_bucket.artefacts_s3_bucket.bucket
  key    = "dist.zip"
  source = archive_file.random_character_ui_artefact.output_path
}