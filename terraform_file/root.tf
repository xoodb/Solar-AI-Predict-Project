/* VPC setting */
module "network" {
  source = "./network"

  env          = var.env
  project      = var.project
  cluster_name = "${var.env}-${var.project}-eks-service" # 순환 종속성 오류
}

/* EC2 setting */
module "jenkins_ec2_instance" {
  source = "./ec2"

  env             = var.env
  project         = var.project
  public_subnets  = module.network.public_subnets
  vpc_internet_GW = module.network.vpc_igw_id
  vpc_id          = module.network.vpc_id
}

/* EKS setting */
module "eks_cluster" {
  source = "./eks"

  env            = var.env
  project        = var.project
  region         = var.region
  cluster_name   = "${var.env}-${var.project}-eks-service"
  vpc_id         = module.network.vpc_id
  eks_subnet_ids = module.network.private_subnets
  azs            = var.azs
}

/* ALB setting */
module "web_alb" {
  source = "./alb"

  env            = var.env
  project        = var.project
  vpc_id         = module.network.vpc_id
  public_subnets = module.network.public_subnets
  jenkins_ec2_id = module.jenkins_ec2_instance.jenkins_ec2_id
}

/* ROUTE53 setting */
module "domain" {
  source = "./route53"

  management_app_alb_dns_name = module.web_alb.management_app_alb_dns_name
  management_app_alb_zone_id  = module.web_alb.management_app_alb_zone_id
}

/* RDS setting */
module "rds_instance" {
  source = "./rds"

  env             = var.env
  project         = var.project
  azs             = var.azs
  vpc_id          = module.network.vpc_id
  private_subnets = module.network.private_subnets
}