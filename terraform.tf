terraform {
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

module "roles" {
  source = "./infrastructure/roles"
}

resource "aws_ecr_repository" "random_character_ui" {
  name                 = "random-character-ui"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "development"
  }

  force_delete = true
}

# TODO: Create global artefacts bucket and reuse between projects. Do not declare , but use an existing one here.
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "random-character-ui-artefacts"
  force_destroy = true
}

resource "aws_codebuild_project" "docker_build" {
  name          = "random-character-ui-build"
  service_role  = module.roles.codebuild_security_role.arn

  source {
    type            = "GITHUB"
    location        = "https://github.com/BlindLionBato/IdealProject.RandomCharacter.UI.git"
    buildspec       = file("buildspec.yml")
    git_clone_depth = 1
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true

    environment_variable {
      name  = "REPOSITORY_NAME"
      value = aws_ecr_repository.random_character_ui.name
    }
  }

  cache {
    type = "LOCAL"
    modes = [ "LOCAL_SOURCE_CACHE", "LOCAL_DOCKER_LAYER_CACHE" ]
  }
}

resource "aws_codepipeline" "pipeline" {
  name     = "random-character-ui-pipeline"
  role_arn = module.roles.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.codepipeline_bucket.bucket
  }

  stage {
    name = "Source"

    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      # TODO: Replace ARN to constants
      configuration = {
        ConnectionArn    = "arn:aws:codestar-connections:eu-west-1:756244214202:connection/32f03d52-c278-466f-baa0-2dcb30cb0216"
        FullRepositoryId = "BlindLionBato/IdealProject.RandomCharacter.UI"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Docker_Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.docker_build.name
      }
    }
  }
}


# resource "aws_iam_instance_profile" "ec2_instance_profile" {
#   name = "EC2_Instance_Profile"
#   role = module.roles.ec2_access_role_name
# }
#
# resource "aws_instance" "random_character_server" {
#   ami                  = "ami-0343a21cd4b9d8ee8"
#   instance_type        = "t2.micro"
#   key_name             = "IdealProject.EC2.KeyPair"
#   vpc_security_group_ids = [
#     module.security_groups.allow_default_connections_id
#   ]
#   iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
#   user_data            = file("./infrastructure/scripts/ec2/bootstrap.sh")
# }