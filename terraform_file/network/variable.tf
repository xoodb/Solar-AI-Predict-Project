variable "env" {}
variable "project" {}
variable "cluster_name" {}

/* set vpc settings */
variable "vpc_name" {
  type    = string
  default = "saps-vpc"
}
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

/* set public subnet settings */
variable "public_subnets" {
  type = map(any)
  default = {
    public_subnet_1a = {
      zone = "ap-northeast-2a"
      cidr = "10.0.1.0/24"
      desc = "1"
    },
    public_subnet_2c = {
      zone = "ap-northeast-2c"
      cidr = "10.0.2.0/24"
      desc = "2"
    }
  }
}

/* set private subnet settings */
variable "private_subnets" {
  type = map(any)
  default = {
    private_subnet_1a = {
      zone   = "ap-northeast-2a"
      cidr   = "10.0.20.0/22"
      pri_rt = "public_subnet_1a"
    },
    private_subnet_2c = {
      zone   = "ap-northeast-2c"
      cidr   = "10.0.24.0/22"
      pri_rt = "public_subnet_2c"
    }
  }
}