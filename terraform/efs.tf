resource "aws_efs_file_system" "shared_filesystem" {
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  throughput_mode = "bursting"

  encrypted = true

  tags = {
    Name        = "mam-on-eks-fs-${var.env}"
    Environment = var.env
    Terraform   = "true"
    Owner       = var.owner
    Project     = var.project
  }
}

resource "aws_efs_mount_target" "shared_efs_mount" {
  for_each = toset(local.private_subnets)

  file_system_id  = aws_efs_file_system.shared_filesystem.id
  subnet_id       = each.value
  security_groups = [aws_security_group.shared_filesystem_sg.id]
}

# Security Group para o EFS:

resource "aws_security_group" "shared_filesystem_sg" {
  name        = "mam-on-eks-fs-sg-${var.env}"
  description = "Allow the node to use the EFS"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = local.private_subnets_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}