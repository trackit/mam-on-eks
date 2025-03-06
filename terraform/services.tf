# declare all services in the service folder as modules here

module "rabbitmq" {
  source = "./services/mq-broker"
  #host              = aws_mq_broker.rabbitmq_broker.broker_instances.0.ip_address
  username          = var.rabbit_mq.username
  password          = var.rabbit_mq.password
  name              = var.rabbit_mq.name
  instance_type     = var.rabbit_mq.instance_type
  rabbit_mq_version = var.rabbit_mq.version
  deployment_mode   = var.rabbit_mq.deployment_mode
  subnet_ids        = [module.vpc.public_subnets[0]]
  vpc_id            = module.vpc.vpc_id
}
