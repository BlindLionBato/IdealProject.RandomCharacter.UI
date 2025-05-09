module "aws_lbc_role" {
  source = "git@github.com:BlindLionBato/Terraform.AWS.Security.CustomRole.git"
  project = local.project_name_short
  service = "lbc"
  custom_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": module.eks.oidc_provider_arn
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${module.eks.oidc_provider}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
  attached_policies = [
    aws_iam_policy.aws_lbc_iam_policy.arn
  ]
}

resource "aws_iam_role" "external_dns" {
  name = "ExternalDNSRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          "AWS": module.eks.eks_managed_node_groups.default.iam_role_arn
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  depends_on = [module.eks]
}

resource "aws_iam_policy" "aws_lbc_iam_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "Access policy for the AWS Load Balancer Controller service in the EKS cluster"
  policy      = file("./policies/aws-lbc-iam-policy.json")
}

resource "aws_iam_policy" "external_dns_policy" {
  name        = "ExternalDNSRoleIAMPolicy"
  description = "Access policy for the External DNS service in the EKS cluster"
  policy      = file("./policies/external-dns-iam-policy.json")
}

resource "aws_iam_role_policy_attachment" "external_dns_policy_attachment" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns_policy.arn
}
