/* EC2 instance */
resource "aws_instance" "Jenkins" {
  ami                    = data.aws_ami.ubuntu-2204.id
  instance_type          = "t2.micro"
  subnet_id              = var.public_subnets["public_subnet_1a"]
  key_name               = aws_key_pair.ec2-keypair.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  root_block_device {
    volume_type = "gp3"
    volume_size = "30"
  }
  # server basic setting
  user_data = <<-EOF
              #!/bin/bash
              EOF
  tags = {
    Name        = "${var.env}-${var.project}-Jenkins-EC2-Server"
    Environment = "${var.env}-CI"
  }
  depends_on = [var.vpc_internet_GW]
}

/* EC2 EIP */
resource "aws_eip" "jenkins_elastic_ip" {
  instance = aws_instance.Jenkins.id
}

/* set key pair */
resource "aws_key_pair" "ec2-keypair" {
  key_name   = "Jenkinsec2_key"
  public_key = file("${path.module}/public")
}

/* define EC2 security group */
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-instance"
  vpc_id      = var.vpc_id
  description = "allow In 22, 80, 443 and Out all"
  tags = {
    Name = "${var.env}-${var.project}-jenkins-sg"
  }
}

/* 22, 80 ingress SG */
resource "aws_security_group_rule" "Allow_http_traffic" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jenkins_sg.id
  description       = "Allowed http"
}

resource "aws_security_group_rule" "Allow_https_traffic" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jenkins_sg.id
  description       = "Allowed https"
}

resource "aws_security_group_rule" "allowed_host_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["1.251.176.145/32"]
  security_group_id = aws_security_group.jenkins_sg.id
  description       = "Allowed Host ssh"
}

/* Outbound */
resource "aws_security_group_rule" "jenkins_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jenkins_sg.id
  description       = "outbound"
}