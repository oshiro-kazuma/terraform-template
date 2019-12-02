# db security group
resource "aws_security_group" "db" {
  name        = "${var.base_name}-db"
  description = "It is a security group on db of ${var.base_name}}_vpc."
  vpc_id      = aws_vpc.prod-vpc.id
  tags = {
    Name = "${var.base_name}-db"
  }
}

resource "aws_security_group_rule" "db" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.db.id
}

resource "aws_db_subnet_group" "main" {
  name        = "${var.base_name}-dbsubnet"
  description = "It is a DB subnet group on ${var.base_name}-vpc."
  subnet_ids  = [aws_subnet.private-db-subnet-a.id, aws_subnet.private-db-subnet-c.id]
  tags = {
    Name = "${var.base_name}-dbsubnet"
  }
}

resource "aws_db_parameter_group" "default" {
  name = "${var.base_name}-rds-pg"
  family = "postgres11"
  description = "Managed by Terraform"

  parameter {
    name = "timezone"
    value = "Asia/Tokyo"
  }
}

resource "aws_db_instance" "db" {
  identifier              = var.base_name
  allocated_storage       = 20
  engine                  = "postgres"
  engine_version          = "11.5"
  instance_class          = "db.t2.micro"
  storage_type            = "gp2"
  username                = "root"
  password                = var.db_passsword
  publicly_accessible     = false
  backup_retention_period = 1
  backup_window           = "22:00-22:30"
  multi_az                = true
  vpc_security_group_ids  = [aws_security_group.db.id]
  db_subnet_group_name    = aws_db_subnet_group.main.name
  parameter_group_name    = aws_db_parameter_group.default.name
}

output "rds_endpoint" {
  value = aws_db_instance.db.address
}
