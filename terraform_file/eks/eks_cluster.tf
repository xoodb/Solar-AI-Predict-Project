module "eks" {
  source = "./common/eks"

  /* VPC */
  vpc_id     = local.vpc_id
  subnet_ids = local.eks_subnet_ids

  /* EKS cluster */
  cluster_name                    = local.cluster_name
  cluster_version                 = local.cluster_version
  enable_irsa                     = local.enable_irsa
  cluster_endpoint_private_access = local.cluster_endpoint_private_access
  cluster_endpoint_public_access  = local.cluster_endpoint_public_access
  cluster_addons                  = local.cluster_addons
  create_cloudwatch_log_group     = local.create_cloudwatch_log_group

  node_security_group_additional_rules = local.node_security_group_additional_rules

  /* EKS nodegroup */
  eks_managed_node_group_defaults = local.eks_managed_node_group_defaults
  eks_managed_node_groups         = local.eks_managed_node_groups

  tags = {
    Environment = var.env
    Terraform   = "true"
    "eks:cluster-name" : local.cluster_name
  }
}