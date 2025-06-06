terraform {
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