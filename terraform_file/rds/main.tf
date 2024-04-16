/* RDS instance */
resource "aws_db_instance" "saps_mysql_db" {
  allocated_storage    = 10
  db_name              = "saps_mysql_db"
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.db_instance
  multi_az             = true

  username             = "admin"
  password             = "saps_admin"
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  
  skip_final_snapshot  = true
}

/* RDS subent group */
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = ["${var.private_subnets["private_subnet_1a"]}", "${var.private_subnets["private_subnet_2c"]}"]
  tags = {
    Name = "${var.env}-${var.project}-subnet"
  }
}

/* RDS security group */
resource "aws_security_group" "mysql_db_sg" {
  name        = "mysql-db-sg"
  vpc_id      = var.vpc_id
  description = "allow In 3306 and Out all"
  tags = {
    Name = "${var.env}-${var.project}-db-sg"
  }
}

/* ingress */
resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.db_sg.id
  description       = "Allowed Host IP band"
}

/* egress */
resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.db_sg.id
  description       = "outbound"
}