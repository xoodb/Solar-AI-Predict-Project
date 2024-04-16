locals {
  env_code = var.env == "dev" ? "dev" : (var.env == "prod" ? "prod" : "stage")
  project  = var.project
  code     = "${local.project}-${local.env_code}"

  /* VPC */
  vpc_id         = var.vpc_id
  eks_subnet_ids = ["${var.eks_subnet_ids["private_subnet_1a"]}", "${var.eks_subnet_ids["private_subnet_2c"]}"]


  /* EKS Cluster */
  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  enable_irsa                     = var.enable_irsa
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_addons                  = var.cluster_addons
  create_cloudwatch_log_group     = var.create_cloudwatch_log_group

  /* EKS NodeGroup */
  eks_managed_node_group_defaults = merge(var.eks_managed_node_group_defaults, { labels = { "alpha.eksctl.io/cluster-name" = local.cluster_name } })
  eks_managed_node_groups = {
    builders = merge(var.builders_node, { name = "${local.cluster_name}-eng-builders-Node", iam_role_arn = module.iam.iam_role_arn }, { labels = { "alpha.eksctl.io/nodegroup-name" = "${local.cluster_name}-builders", "role" = "builders" } })
    workers  = merge(var.workers_node, { name = "${local.cluster_name}-eng-workers-Node", iam_role_arn = module.iam.iam_role_arn }, { labels = { "alpha.eksctl.io/nodegroup-name" = "${local.cluster_name}-workers", "role" = "workers" } })
  }
  node_security_group_additional_rules = var.node_security_group_additional_rules


  /* IAM */
  role_name               = format("%s-eks-worker-role", local.project)
  policy_name             = format("%s-eks-worker-policy", local.project)
  trusted_role_services   = var.trusted_role_services
  custom_role_policy_arns = concat(var.custom_role_policy_arns, [aws_iam_policy.this.arn])

  tags = merge(var.tags, { Environment = var.env })


  /* SG */
  sg_name        = "sec-${local.code}-eks-node"
  sg_description = "sec-${local.code}-eks-node"

  egress_rules = ["all-all"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 30000
      to_port     = 32767
      protocol    = "tcp"
      description = "nodeport"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}