resource "aws_lb" "management_app" {
  name               = "${var.env}-${var.project}-management-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.jenkins_alb_sg.id]
  subnets            = ["${var.public_subnets["public_subnet_1a"]}", "${var.public_subnets["public_subnet_2c"]}"]

  enable_deletion_protection = true
  tags = {
    Name = "${var.env}-${var.project}-management-app-alb"
    env  = var.env
  }
}

/* Set target group */
resource "aws_alb_target_group" "Jenkins" {
  name     = "Jenkins-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
resource "aws_alb_target_group_attachment" "Jenkins_ec2_instance" {
  target_group_arn = aws_alb_target_group.Jenkins.arn
  target_id        = var.jenkins_ec2_id
  port             = 80
}

/* Set ALB Listener */
resource "aws_alb_listener" "HTTP" {
  load_balancer_arn = aws_lb.management_app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.Jenkins.arn
  }
}
resource "aws_lb_listener" "HTTPS" {
  load_balancer_arn = aws_lb.management_app.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:ap-northeast-2:422837884582:certificate/c2f8cb02-5d36-4067-a2dc-3530c1803295"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.Jenkins.arn
  }
}

/* ALB security group */
resource "aws_security_group" "jenkins_alb_sg" {
  name        = "jenkins_alb_sg"
  vpc_id      = var.vpc_id
  description = "allow In 80, 443 and Out all"
  tags = {
    Name = "jenkins_alb_sg"
  }
}

/* http, https, git webhook ingress */
resource "aws_security_group_rule" "allowed_http_ip" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jenkins_alb_sg.id
  description       = "Allowed http ip band"
}
resource "aws_security_group_rule" "allowed_https_ip" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jenkins_alb_sg.id
  description       = "Allowed https ip band"
}
resource "aws_security_group_rule" "git_webhook_1" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.jenkins_alb_sg.id
  description       = "Git Webhook allowed IP range 192.30.252.0/22"
  cidr_blocks       = ["192.30.252.0/22"]
}
resource "aws_security_group_rule" "git_webhook_2" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.jenkins_alb_sg.id
  description       = "Git Webhook allowed IP range 185.199.108.0/22"
  cidr_blocks       = ["185.199.108.0/22"]
}
resource "aws_security_group_rule" "git_webhook_3" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.jenkins_alb_sg.id
  description       = "Git Webhook allowed IP range 140.82.112.0/20"
  cidr_blocks       = ["140.82.112.0/20"]
}
resource "aws_security_group_rule" "git_webhook_4" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.jenkins_alb_sg.id
  description       = "Git Webhook allowed IP range 143.55.64.0/20"
  cidr_blocks       = ["143.55.64.0/20"]
}

/* Outbound */
resource "aws_security_group_rule" "alb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jenkins_alb_sg.id
  description       = "outbound"
}