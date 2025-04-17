module "codebuild_role" {
  source = "git@github.com:BlindLionBato/Terraform.AWS.Security.CustomRole.git"
  project_name = local.project_name
  service_name = "codebuild"
  statements = [
    module.statements.cloudwatch_full_access,
    module.statements.s3_full_access
  ]
}

module "codedeploy_role" {
  source = "git@github.com:BlindLionBato/Terraform.AWS.Security.CustomRole.git"
  project_name = local.project_name
  service_name = "codedeploy"
  statements = [
    module.statements.ec2_read_access,
    module.statements.cloudwatch_full_access,
    module.statements.s3_read_access,
    module.statements.codedeploy_full_access
  ]
}

module "codepipeline_role" {
  source = "git@github.com:BlindLionBato/Terraform.AWS.Security.CustomRole.git"
  project_name = local.project_name
  service_name = "codepipeline"
  statements = [
    module.statements.cloudwatch_full_access,
    module.statements.codebuild_execute_access,
    module.statements.codedeploy_execute_access,
    module.statements.connections_execute_access,
    module.statements.s3_full_access
  ]
}

module "ec2_role" {
  source = "git@github.com:BlindLionBato/Terraform.AWS.Security.CustomRole.git"
  project_name = local.project_name
  service_name = "ec2"
  statements = [
    module.statements.s3_read_access,
    module.statements.cloudwatch_full_access
  ]
}