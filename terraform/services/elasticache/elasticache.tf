resource "aws_elasticache_replication_group" "elasticache" {
  replication_group_id = var.cluster_id
  description          = "Elasticache replication group"
  engine               = "valkey"
  node_type            = var.node_type
  num_cache_clusters   = 1
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.eks_shared.name
  security_group_ids   = [aws_security_group.elasticache_sg.id]
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
  }
}
