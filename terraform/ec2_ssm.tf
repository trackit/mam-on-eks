locals {
  services = {
    "ec2messages" : {
      "name" : "com.amazonaws.${var.aws_region}.ec2messages"
    },
    "ssm" : {
      "name" : "com.amazonaws.${var.aws_region}.ssm"
    },
    "ssmmessages" : {
      "name" : "com.amazonaws.${var.aws_region}.ssmmessages"
    }
  }
}

resource "aws_iam_role" "ssm_role" {
  name = "ssm-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "eks_policy" {
  name        = "EKSAccessPolicy"
  description = "Policy to allow EKS access"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:ListNodegroups",
          "eks:ListUpdates",
          "eks:AccessKubernetesApi"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = aws_iam_policy.eks_policy.arn
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_vpc_endpoint" "ssm_endpoint" {
  for_each = local.services
  vpc_id              = module.vpc.vpc_id
  service_name        = each.value.name
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.ssm_https.id]
  private_dns_enabled = true
  ip_address_type     = "ipv4"
  subnet_ids          = module.vpc.private_subnets
}

resource "aws_security_group" "ssm_https" {
  name        = "allow_ssm"
  description = "Allow SSM traffic"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = var.cluster.name
    Environment = var.env
    Terraform   = "true"
    Owner       = var.owner
    Project     = var.project
  }
}

resource "aws_security_group" "eks_control_plane_sg" {
  name        = "eks_control_plane_sg"
  description = "Allow traffic from instance to EKS control plane"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  tags = {
    Name        = var.cluster.name
    Environment = var.env
    Terraform   = "true"
    Owner       = var.owner
    Project     = var.project
  }
}

resource "aws_instance" "ssm_instance" {
  ami                    = "ami-05572e392e80aee89"
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.private_subnets[0]
  associate_public_ip_address = false
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
  vpc_security_group_ids = [aws_security_group.ssm_https.id]

  user_data = <<-EOF
              #!/bin/bash
              cd /tmp
              curl -LO https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
              chmod +x ./kubectl
              sudo mv kubectl /usr/local/bin/
              aws eks --region ${var.aws_region} update-kubeconfig --name ${var.cluster.name}
              EOF

  tags = {
    Name        = var.cluster.name
    Environment = var.env
    Terraform   = "true"
    Owner       = var.owner
    Project     = var.project
  }
}
