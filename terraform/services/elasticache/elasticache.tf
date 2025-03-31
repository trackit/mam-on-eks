resource "aws_elasticache_replication_group" "elasticache" {
  replication_group_id = var.cluster_id
  description          = "Elasticache replication group"
  engine               = "valkey"
  node_type            = var.node_type
  num_cache_clusters   = 1
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.eks_shared.name
  security_group_ids   = [aws_security_group.elasticache_sg.id]
  apply_immediately    = true

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.elasticache_slow_logs.name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.elasticache_engine_logs.name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "engine-log"
  }

  tags = {
    Owner = var.owner
    Project = var.project
  }
}

resource "aws_elasticache_parameter_group" "valkey_param_group" {
  name   = "valkey-param-group"
  family = "valkey8"

  parameter {
    name  = "slowlog-log-slower-than"
    value = "10000"
  }

  parameter {
    name  = "slowlog-max-len"
    value = "128"
  }
}

resource "aws_cloudwatch_log_group" "elasticache_engine_logs" {
  name              = "/aws/elasticache/engine-logs"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "elasticache_slow_logs" {
  name              = "/aws/elasticache/slow-logs"
  retention_in_days = 30
}

resource "aws_iam_role" "elasticache_logs_role" {
  name = "elasticache-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "elasticache.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "elasticache_logs_policy" {
  name = "elasticache-logs-policy"
  role = aws_iam_role.elasticache_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:log-group:/aws/elasticache/*"
      }
    ]
  })
}

resource "aws_elasticache_subnet_group" "eks_shared" {
  name       = "${var.cluster_id}-eks-shared"
  subnet_ids = var.pv_subnets_cidr
}

resource "aws_security_group" "elasticache_sg" {
  name        = "elasticache-sg"
  description = "Allow inbound traffic from EKS nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
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
    Name  = "elasticache-sg"
    Owner = var.owner
    Project = var.project
  }
}
