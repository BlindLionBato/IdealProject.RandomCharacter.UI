# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.36.0"

  cluster_name    = local.cluster_name
  cluster_version = local.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access  = true
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    default = {
      min_size     = length(data.aws_availability_zones.available.names)
      max_size     = length(data.aws_availability_zones.available.names) * 2
      desired_size = length(data.aws_availability_zones.available.names)

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }
}

# VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "${local.cluster_name}-VPC"
  cidr = local.vpc_cidr

  azs             = data.aws_availability_zones.available.names
  public_subnets  = [for index, zone in data.aws_availability_zones.available.names : cidrsubnet(local.vpc_cidr, 8, index)]
  private_subnets = [for index, zone in data.aws_availability_zones.available.names : cidrsubnet(local.vpc_cidr, 8, index + length(data.aws_availability_zones.available.names))]

  enable_nat_gateway = true
  single_nat_gateway = false

  tags = {
    "kubernetes.io/role/elb" = 1
    # "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}
