module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  for_each                    = toset(["phraseanet/phraseanet-fpm", "phraseanet/gateway","phraseanet/setup"])
  repository_name             = each.key
  repository_read_access_arns = [module.eks.eks_managed_node_groups["eks-nodes"].iam_role_arn]
  # test read_write access
  repository_read_write_access_arns = [
    "arn:aws:iam::${local.account_id}:role/eks_role_${var.env}"
  ]

  repository_image_tag_mutability = "MUTABLE"
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only 10 images"
        selection = {
          countType   = "imageCountMoreThan"
          countNumber = 10
          tagStatus   = "untagged"
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  repository_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${local.account_id}:role/eks-nodes-eks-node-group-2025021020263663390000000b",
            "arn:aws:iam::${local.account_id}:role/eks_role_${var.env}"
          ]
        }
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:GetDownloadUrlForLayer",
          "ecr:ListImages"
        ]
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.account_id}:role/eks_role_${var.env}"
        }
        Action = [
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  })

}