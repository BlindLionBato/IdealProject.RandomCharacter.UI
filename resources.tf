# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.36.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.32"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  eks_managed_node_groups = {}

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false

  cluster_addons = {
    # coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }

  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = "dev"
  }
}

# Launch template for EC2 nodes
resource "aws_launch_template" "eks_node_lt" {
  name_prefix   = "${local.project_name_short}-EKS-Node-"
  image_id      = data.aws_ami.eks_node_ami.id
  instance_type = "t3.medium"

  iam_instance_profile {
    name = aws_iam_instance_profile.eks_node.name
  }

  key_name = local.ssh_key_name

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    cluster_name = local.cluster_name
  }))

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.eks_node_sg.id]
  }
}

resource "aws_iam_instance_profile" "eks_node" {
  name = "${local.project_name_short}-EKS-Node-Profile"
  role = module.eks_node_role.name
}

# Auto Scaling Group
resource "aws_autoscaling_group" "eks_nodes" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1

  vpc_zone_identifier  = module.vpc.public_subnets

  launch_template {
    id      = aws_launch_template.eks_node_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "kubernetes.io/cluster/${local.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}

# TODO: Why it doesn't work automatically???
# Add worker role to aws-auth
resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = module.eks_node_role.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = [
          "system:bootstrappers",
          "system:nodes"
        ]
      }
    ])
  }

  depends_on = [module.eks, aws_autoscaling_group.eks_nodes]
}

resource "aws_ecr_repository" "random_character_ui" {
  name                 = "random-character-ui"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true
}

data "kubernetes_service" "random_character_ui" {
  depends_on = [ module.eks ]

  metadata {
    name      = "random-character-ui-service"
    namespace = "default"
  }
}

data "aws_lb" "random_character_ui" {
  name = local.nlb_name
}

resource "aws_route53_record" "random_character_ui_route" {
  zone_id = data.aws_route53_zone.main.id
  name    = data.aws_route53_zone.main.name
  type    = "A"

  alias {
    name                   = local.nlb_hostname
    zone_id                = data.aws_lb.random_character_ui.zone_id
    evaluate_target_health = false
  }
}

locals {
  nlb_hostname = data.kubernetes_service.random_character_ui.status[0].load_balancer[0].ingress[0].hostname
  nlb_full_name = regex("^([^.]+)", local.nlb_hostname)[0]
  nlb_name = substr(local.nlb_full_name, 0, 32)
}