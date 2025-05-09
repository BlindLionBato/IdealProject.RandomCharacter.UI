locals {
  organization_name  = "BlindLionBato"
  project_name       = "IdealProject.RandomCharacter.UI"
  project_name_short = "RandomCharacterUI"
  cluster_name       = "RandomCharacterUI-EKS"
  ssh_key_name       = "IdealProject.EC2.KeyPair"
  kubernetes_version = "1.32"
  domain_name        = "random-character.org"
  vpc_cidr           = "10.0.0.0/16"
}