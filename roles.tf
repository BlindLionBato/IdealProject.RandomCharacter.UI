module "github_role" {
  source = "git@github.com:BlindLionBato/Terraform.AWS.Security.CustomRole.git"
  project = local.project_name_short
  service = "github"
  custom_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
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
  })
  custom_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      module.statements.cloudwatch_full_access,
      module.statements.ecr_full_access,
      module.statements.ec2_read_access,
      module.statements.ssm_full_access,
      module.statements.eks_full_access,
      module.statements.autoscaling_full_access,
      module.statements.iam_pass_access
    ]
  })
}

module "eks_cluster_role" {
  source = "git@github.com:BlindLionBato/Terraform.AWS.Security.CustomRole.git"
  project = local.project_name_short
  service = "eks"
  attached_policies = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  ]
}

module "eks_node_role" {
  source = "git@github.com:BlindLionBato/Terraform.AWS.Security.CustomRole.git"
  project = local.project_name_short
  service = "ec2"
  attached_policies = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]
}