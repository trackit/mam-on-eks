locals {
  node_sg         = module.eks.node_security_group_id
  cluster_sg      = module.eks.cluster_security_group_id
  cluster_prim_sg = module.eks.cluster_primary_security_group_id
  oidc_arn        = module.eks.oidc_provider_arn
}

locals {
  vpc_id               = module.vpc.vpc_id
  private_subnets      = module.vpc.private_subnets
  public_subnets       = module.vpc.public_subnets
  private_subnets_cidr = module.vpc.private_subnets_cidr_blocks
  public_subnets_cidr  = module.vpc.public_subnets_cidr_blocks
}

locals {
  account_id = data.aws_caller_identity.current.account_id
}