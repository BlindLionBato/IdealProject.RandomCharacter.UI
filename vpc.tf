module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "${local.project_name_short}-EKS-VPC"
  cidr = local.vpc_cidr

  azs             = data.aws_availability_zones.available.names
  public_subnets  = [for index, zone in data.aws_availability_zones.available.names : cidrsubnet(local.vpc_cidr, 8, index)]
  private_subnets = [for index, zone in data.aws_availability_zones.available.names : cidrsubnet(local.vpc_cidr, 8, index + length(data.aws_availability_zones.available.names))]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}