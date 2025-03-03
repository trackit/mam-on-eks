module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.cidr

  azs             = var.availability_zones
  private_subnets = var.pv_subnets_cidr
  public_subnets  = var.pb_subnets_cidr

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  tags = {
    Terraform   = "true"
    Environment = var.env

    # Ensure workspace check logic runs before resources created
    always_zero = length(null_resource.check_workspace)
  }

  public_subnet_tags = {
    Terraform                                   = "true"
    Environment                                 = var.env
    KubernetesRole                              = "elb"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster.name}" = "owned"
  }
}