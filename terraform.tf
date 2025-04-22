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

locals {
  organization_name = "BlindLionBato"
  project_name      = "IdealProject.RandomCharacter.UI"
}

module "statements" {
  source = "git@github.com:BlindLionBato/Terraform.AWS.Security.Statements.git"
}

module "global" {
  source = "git@github.com:BlindLionBato/Terraform.Infrastructure.Global.git"
}