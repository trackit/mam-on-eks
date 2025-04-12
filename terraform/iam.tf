resource "aws_iam_role_policy_attachment" "ecr_policy_attachment" {
  for_each   = module.eks.eks_managed_node_groups
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = each.value.iam_role_name
}

resource "aws_iam_role_policy_attachment" "secret_manager_policy_attachment" {
  for_each   = module.eks.eks_managed_node_groups
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  role       = each.value.iam_role_name
}

resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  for_each   = module.eks.eks_managed_node_groups
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = each.value.iam_role_name
}

resource "aws_iam_role_policy_attachment" "efs_policy_attachment" {
  for_each   = module.eks.eks_managed_node_groups
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role       = each.value.iam_role_name
}

# resource "aws_iam_role_policy_attachment" "ebs_policy_attachment" {
#   for_each   = module.eks.eks_managed_node_groups
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
#   role       = each.value.iam_role_name
# }

# ALB IAM resources

# resource "aws_iam_role" "alb_controller_role" {
#   name = "AWSLoadBalancerControllerRole-${var.env}"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = {
#           Service = "eks.amazonaws.com"
#         },
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# IAM Role to access the Secrets Manager

resource "aws_iam_role" "secrets_manager_role" {
  name = "AWSSecretManagerAccessRole-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "${local.oidc_arn}"
        },
        Action = "sts:AssumeRoleWithWebIdentity"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_manager_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  role       = aws_iam_role.secrets_manager_role.name
}

# IAM Role to access the ALB Resources
resource "aws_iam_role" "aws_lb_controller" {
  name               = "aws-load-balancer-controller-role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.aws_lb_controller_assume_role.json
}

resource "aws_iam_role_policy_attachment" "aws_lb_controller_attach" {
  role       = aws_iam_role.aws_lb_controller.name
  policy_arn = aws_iam_policy.aws_lb_controller.arn
}

resource "aws_iam_policy" "aws_lb_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy-${var.env}"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = data.http.aws_lb_controller_policy.response_body
}

