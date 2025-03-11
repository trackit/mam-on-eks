# declare all services in the service folder as modules here

module "rabbitmq" {
  source            = "./services/mq-broker"
  username          = var.rabbit_mq.username
  password          = var.rabbit_mq.password
  name              = var.rabbit_mq.name
  instance_type     = var.rabbit_mq.instance_type
  rabbit_mq_version = var.rabbit_mq.version
  deployment_mode   = var.rabbit_mq.deployment_mode
  subnet_ids        = [module.vpc.public_subnets[0]]
  vpc_id            = module.vpc.vpc_id
  owner             = var.owner
}

module "database" {
  source              = "./services/rds-database"
  identifier          = var.database.identifier
  instance_type       = var.database.instance_type
  storage             = var.database.storage
  username            = var.database.username
  password            = var.database.password
  pv_subnets_cidr     = module.vpc.private_subnets
  owner               = var.owner
  vpc_id              = module.vpc.vpc_id
  skip_final_snapshot = var.database.skip_final_snapshot
}
