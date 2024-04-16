/* make host zone */
resource "aws_route53_zone" "main" {
  name = var.root_domain
}

/* make hosting record */
resource "aws_route53_record" "jenkins" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.jenkins_sub_domain
  type    = "A"

  alias {
    name                   = var.management_app_alb_dns_name
    zone_id                = var.management_app_alb_zone_id
    evaluate_target_health = true
  }
}

/* EKS ALB Record */
# resource "aws_route53_record" "web" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = "${var.web_sub_doamin}"
#   type    = "A"
# }

# resource "aws_route53_record" "argocd" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = "${var.argocd_sub_domain}"
#   type    = "A"
# }

# resource "aws_route53_record" "grafana" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = "${var.grafana_sub_domain}"
#   type    = "A"
# }