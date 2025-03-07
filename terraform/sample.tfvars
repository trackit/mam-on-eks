# This file is a sample of the variables that you can use to create the EKS cluster.
profile            = "sandbox"
env                = "sandbox"
owner              = "Leandro Mota"
project            = "mam-inside-eks"
vpc_name           = "vpc-mam-sandbox"
cidr               = "10.1.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
pv_subnets_cidr    = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
pb_subnets_cidr    = ["10.1.11.0/24", "10.1.12.0/24", "10.1.13.0/24"]
cluster = {
  name    = "mam-sandbox"
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