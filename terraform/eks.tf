module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name                   = var.cluster.name
  cluster_version                = var.cluster.version
  cluster_endpoint_public_access = true

  cluster_addons = {
    eks-pod-identity-agent = {}
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
    auto_mode_defaults = {
      tags = {
        Name        = var.cluster.name
        Environment = var.env
        Terraform   = "true"
        Owner       = var.owner
        Project     = var.project
      }
    }
  }

  # Cluster access entry
  enable_cluster_creator_admin_permissions = true

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

resource "kubectl_manifest" "wait_for_nodes_job" {
  yaml_body = <<YAML
apiVersion: batch/v1
kind: Job
metadata:
  name: dummy-job
spec:
  template:
    metadata:
      labels:
        app: dummy
    spec:
      nodeSelector:
        topology.kubernetes.io/zone: ${var.aws_region}c
      containers:
      - name: dummy
        image: busybox
        command:
          - "/bin/sh"
          - "-c"
          - "echo 'Give me a node'"
      restartPolicy: Never
YAML

  depends_on = [module.eks]
}