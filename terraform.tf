terraform {
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }

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

locals {
  project_name = "Test"
}

module "statements" {
  source = "git@github.com:BlindLionBato/Terraform.AWS.Security.Statements.git"
}