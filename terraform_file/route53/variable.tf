variable "management_app_alb_dns_name" {}
variable "management_app_alb_zone_id" {}
/* Root Domain */
variable "root_domain" {
  type    = string
  default = ""
}
/* Sub Domain */
variable "jenkins_sub_domain" {
  type    = string
  default = ""
}
variable "argocd_sub_domain" {
  type    = string
  default = ""
}
variable "grafana_sub_domain" {
  type    = string
  default = ""
}
variable "web_sub_doamin" {
  type    = string
  default = ""
}