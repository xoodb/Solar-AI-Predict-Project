variable "project" {}
variable "env" {}
variable "private_subnets" {}
variable "vpc_id" {}
variable "azs" {}
variable "engine" {
  type    = string
  default = "mysql"
}
variable "engine_version" {
  type    = string
  default = "8.0.32"
}
variable "db_instance" {
  type    = string
  default = "db.t3.micro"
}