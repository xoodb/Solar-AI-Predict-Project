output "management_app_alb_dns_name" {
  value = aws_lb.management_app.dns_name
}
output "management_app_alb_zone_id" {
  value = aws_lb.management_app.zone_id
}