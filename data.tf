# Move to Terraform.Infrastructure.IdealProject.Global

data "aws_route53_zone" "main" {
  name = local.domain_name
}

data "aws_ami" "eks_node_ami" {
  owners      = ["602401143452"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-${local.kubernetes_version}-v*"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}