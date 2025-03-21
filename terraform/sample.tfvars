# This file is a sample of the variables that you can use to create the EKS cluster.
profile            = "sandbox"
env                = "sandbox"
owner              = "Your Name" #Change it for the name of the person running terraform
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
