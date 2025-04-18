resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
}

resource "aws_elasticsearch_domain" "elasticsearch" {
  domain_name           = var.name
  elasticsearch_version = "7.10"

  cluster_config {
    instance_type  = var.instance_type
    instance_count = 1
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.volume_size
  }

  vpc_options {
    subnet_ids         = [var.pv_subnet_ids[0]]
    security_group_ids = [aws_security_group.es_sg.id]
  }

  access_policies = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Resource": "arn:aws:es:us-west-2:123456789012:domain/${var.name}/*"
    }
  ]
}
POLICY

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  tags = {
    Domain = var.name
    Owner  = var.owner
    Project = var.project
  }
}

resource "aws_security_group" "es_sg" {
  name        = "${var.name}-security-group"
  description = "Allow inbound traffic from EKS nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.pv_subnets_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.pv_subnets_cidr
  }

  tags = {
    Name  = "${var.name}-security-group"
    Owner = var.owner
  }
}
