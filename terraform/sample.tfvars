# This file is a sample of the variables that you can use to create the EKS cluster.
profile            = "sandbox"
env                = "sandbox"
owner              = "Leandro Mota"
email              = "example@example.com"
project            = "mam-on-eks"
vpc_name           = "vpc-mam-on-eks"
cidr               = "10.1.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
pv_subnets_cidr    = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
pb_subnets_cidr    = ["10.1.11.0/24", "10.1.12.0/24", "10.1.13.0/24"]
cluster = {
  name    = "mam-on-eks"
  version = "1.31"
}
rabbit_mq = {
  username        = "rabbit"
  password        = "rabbitrabbit"
  name            = "rabbitmq"
  instance_type   = "mq.t3.micro"
  version         = "3.13"
  deployment_mode = "SINGLE_INSTANCE"
}
database = {
  name                = "mamdb"
  identifier          = "mam-on-eks"
  instance_type       = "db.t3.micro"
  storage             = 5
  username            = "root"
  password            = "phraseanet"
  skip_final_snapshot = true
}
elasticache = {
  cluster_id = "mam-on-eks"
  node_type  = "cache.t3.micro"
}
elasticsearch = {
  name          = "mam-on-eks"
  instance_type = "t3.small.elasticsearch"
  volume_size   = 10
}
