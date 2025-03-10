resource "aws_db_instance" "database" {
  identifier             = var.identifier
  instance_class         = var.instance_type
  allocated_storage      = var.storage
  engine                 = "mysql"
  engine_version         = "8.0.25"
  username               = var.username
  password               = var.password
  db_subnet_group_name   = aws_db_subnet_group.eks_shared.name
  parameter_group_name   = aws_db_parameter_group.database_parameter_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

resource "aws_db_parameter_group" "database_parameter_group" {
  name   = "database-parameter-group"
  family = "mysql8.0"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_subnet_group" "eks_shared" {
  name       = "${var.identifier}-eks-shared"
  subnet_ids = var.pv_subnets_cidr
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow inbound traffic from EKS nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "rds-sg"
    Owner = var.owner
  }
}
