module "github_role" {
  source = "git@github.com:BlindLionBato/Terraform.AWS.Security.CustomRole.git"
  project_name = local.project_name
  service_name = "github"
  role_statements = [
    {
      Effect = "Allow",
      Principal = {
        Federated = module.global.github_openid_connect_provider.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub" : "repo:${local.organization_name}/${local.project_name}:*"
        }
      }
    }
  ]
  statements = [
    module.statements.cloudwatch_full_access,
    module.statements.ecr_read_access,
    module.statements.ecr_write_access,
    module.statements.ec2_read_access,
    module.statements.ssm_full_access,
    module.statements.eks_full_access,
    module.statements.ecr_full_access,
    module.statements.autoscaling_full_access,
    module.statements.iam_pass_access
  ]
}