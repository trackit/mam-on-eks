data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "current" {
  name = var.cluster.name
}