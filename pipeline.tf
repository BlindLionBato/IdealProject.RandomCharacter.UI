resource "aws_codebuild_project" "random_character_ui" {
  name         = "random-character-ui"
  service_role = module.security.roles.codebuild.arn

  artifacts {
    type      = "S3"
    location  = aws_s3_bucket.random_character_ui.bucket
    packaging = "ZIP"
    path      = "build"
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/BlindLionBato/IdealProject.RandomCharacter.UI.git"
    git_clone_depth = 1
    buildspec       = "buildspec.yml"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.random_character_ui.name
      stream_name = "codebuild"
    }
  }
}

resource "aws_codedeploy_app" "random_character_ui" {
  name = "random-character-ui"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "random_character_ui" {
  app_name              = aws_codedeploy_app.random_character_ui.name
  deployment_group_name = "IdealProject.RandomCharacter.UI"
  service_role_arn      = module.security.roles.codedeploy.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "IdealProject.RandomCharacter.UI"
    }
  }

  deployment_config_name = "CodeDeployDefault.OneAtATime"

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}

resource "aws_codepipeline" "random_character_ui" {
  name     = "random-character-ui"
  role_arn = module.security.roles.codepipeline.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.random_character_ui.bucket
  }

  stage {
    name = "Source"

    action {
      name     = "GitHub_Source"
      category = "Source"
      owner    = "AWS"
      provider = "CodeStarSourceConnection"
      version  = "1"
      output_artifacts = ["source_output"]

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
      name     = "Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      input_artifacts = ["source_output"]
      output_artifacts = ["build_output"]
      version  = "1"
      configuration = {
        ProjectName = aws_codebuild_project.random_character_ui.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy_To_EC2"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ApplicationName     = aws_codedeploy_app.random_character_ui.name
        DeploymentGroupName = aws_codedeploy_deployment_group.random_character_ui.deployment_group_name
      }
    }
  }
}