resource "aws_db_instance" "database" {
  identifier                = var.identifier
  db_name                   = var.name
  instance_class            = var.instance_type
  allocated_storage         = var.storage
  engine                    = "mysql"
  engine_version            = "8.0.40"
  username                  = var.username
  password                  = var.password
  db_subnet_group_name      = aws_db_subnet_group.eks_shared.name
  parameter_group_name      = aws_db_parameter_group.database_parameter_group.name
  vpc_security_group_ids    = [aws_security_group.rds_sg.id]
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.identifier}-final-snapshot"
  skip_final_snapshot       = true

  tags = {
    Owner = var.owner
    Project = var.project
  }
}

resource "aws_db_parameter_group" "database_parameter_group" {
  name   = "database-parameter-group"
  family = "mysql8.0"
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
    Project = var.project
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_alarm" {
  alarm_name                = "rds_cpu_utilization_alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/RDS"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors RDS CPU utilization"
  insufficient_data_actions = []

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.database.identifier
  }

  alarm_actions = [
    var.sns_topic_arn
  ]
}
