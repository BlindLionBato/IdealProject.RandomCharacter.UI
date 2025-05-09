terraform {
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }

  backend "s3" {
    bucket         = "blb-terraform-states"
    key            = "ideal-project/random-character-ui/dev/tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

provider "aws" {

}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "statements" {
  source = "git@github.com:BlindLionBato/Terraform.AWS.Security.Statements.git"
}

module "global" {
  source = "git@github.com:BlindLionBato/Terraform.Infrastructure.Global.git"
}