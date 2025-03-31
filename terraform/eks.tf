module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name                   = var.cluster.name
  cluster_version                = var.cluster.version
  cluster_endpoint_public_access = true

  cluster_addons = {
    eks-pod-identity-agent = {}
    aws-efs-csi-driver     = {}
  }

  vpc_id     = local.vpc_id
  subnet_ids = local.private_subnets

  cluster_compute_config = {
    # this enable the auto mode for the cluster
    enabled    = true
    node_pools = ["general-purpose"]
    labels = {
      role = "applications"
    }
  }

  # eks_managed_node_groups = {
  #   eks-nodes = {
  #     ami_type           = "AL2023_x86_64_STANDARD"
  #     instance_types     = ["t3.large"]
  #     min_size           = 1
  #     max_size           = 10
  #     desired_size       = 2
  #     labels = {
  #       role = "applications"
  #     }
  #   }
  # }

  # Remove the eks_managed_node_groups block if the objective is to use Fargate
  # eks_managed_node_groups = {}

  # fargate_profiles = {
  #   default = {
  #     name = "fargate-profile"
  #     selectors = [
  #       {
  #         namespace = "default"
  #       },
  #       {
  #         namespace = "kube-system"
  #         labels = {
  #           role = "applications"
  #         }
  #       }
  #     ]
  #     subnet_ids = local.private_subnets
  #   }
  # }

  # Cluster access entry
  enable_cluster_creator_admin_permissions = true

  # access_entries = {
  #   default = {
  #     kubernetes_groups = []
  #     principal_arn     = aws_iam_role.eks_role.arn

  #     policy_associations = {
  #       default = {
  #         policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
  #         access_scope = {
  #           type = "cluster"
  #         }
  #       }
  #     }
  #   }
  # }
  tags = {
    Name        = var.cluster.name
    Environment = var.env
    Terraform   = "true"
    Owner       = var.owner
    Project     = var.project

    # Ensure workspace check logic runs before resources created
    always_zero = length(null_resource.check_workspace)
  }
}
