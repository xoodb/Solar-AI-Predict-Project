variable "project" {}
variable "env" {}
variable "region" {}

/* VPC */
variable "vpc_id" {}
variable "eks_subnet_ids" {}
variable "azs" {}

/* EKS cluster */
variable "cluster_name" {}

variable "cluster_version" {
  type        = string
  default     = "1.29"
  description = "EKS cluster version"
}
variable "enable_irsa" {
  type        = bool
  default     = true
  description = "Enable IRSA"
}
variable "cluster_endpoint_private_access" {
  type        = bool
  default     = true
  description = "Enable private access for EKS cluster endpoint"
}
variable "cluster_endpoint_public_access" {
  type        = bool
  default     = true
  description = "Enable public access for EKS cluster endpoint"
}
variable "cluster_addons" {
  type = map(object({
    resolve_conflicts = string
  }))
  default = {
    coredns    = { resolve_conflicts = "OVERWRITE" }
    kube-proxy = { resolve_conflicts = "OVERWRITE" }
    vpc-cni    = { resolve_conflicts = "OVERWRITE" }
  }
  description = "EKS cluster addons configuration"
}
variable "create_cloudwatch_log_group" {
  type        = bool
  default     = false
  description = "Create CloudWatch log group"
}

/* EKS nodeGroup */
variable "eks_managed_node_group_defaults" {
  type = object({
    ami_type                   = string
    use_name_prefix            = bool
    instance_types             = list(string)
    iam_role_attach_cni_policy = bool
    capacity_type              = string
    create_iam_role            = bool
    iam_role_use_name_prefix   = bool
  })
  default = {
    ami_type                   = "AL2_x86_64"
    use_name_prefix            = false
    instance_types             = ["t3.medium"]
    iam_role_attach_cni_policy = true
    capacity_type              = "ON_DEMAND"
    create_iam_role            = false
    iam_role_use_name_prefix   = false
  }
  description = "Default configuration for EKS managed node group"
}
variable "node_security_group_additional_rules" {
  type = object({
    ingress_self_all = object({
      description = string
      protocol    = string
      from_port   = number
      to_port     = number
      type        = string
      self        = bool
    })
    egress_all = object({
      description      = string
      protocol         = string
      from_port        = number
      to_port          = number
      type             = string
      cidr_blocks      = list(string)
      ipv6_cidr_blocks = list(string)
    })
    ingress_cluster_to_node_all_traffic = object({
      description                   = string
      protocol                      = string
      from_port                     = number
      to_port                       = number
      type                          = string
      source_cluster_security_group = bool
    })
  })
  default = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    ingress_cluster_to_node_all_traffic = {
      description                   = "Cluster API to Nodegroup all traffic"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }
  description = "Additional security group rules for nodes"
}
variable "builders_node" {
  type = object({
    min_size     = number
    max_size     = number
    desired_size = number
  })
  default = {
    min_size     = 1
    max_size     = 5
    desired_size = 1
  }
  description = "Builders node group configuration"
}
variable "workers_node" {
  type = object({
    min_size       = number
    max_size       = number
    desired_size   = number
    instance_types = list(string)
  })
  default = {
    min_size       = 1
    max_size       = 5
    desired_size   = 1
    instance_types = ["t3.medium"]
  }
  description = "Workers node group configuration"
}

/* IAM */
variable "trusted_role_services" {
  type        = list(string)
  default     = ["ec2.amazonaws.com"]
  description = "Trusted role services"
}
variable "custom_role_policy_arns" {
  type = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess",
  ]
  description = "Custom role policy ARNs"
}
variable "additional_policy_actions" {
  type = list(string)
  default = [
    "ec2:*",
    "elasticloadbalancing:*",
    "iam:ListServerCertificates",
    "iam:GetServerCertificate",
  ]
  description = "Additional policy actions"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags"
}
