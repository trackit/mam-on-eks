variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}

variable "profile" {
  description = "AWS cli profile to be used by terraform"
  type        = string
}

variable "env" {
  description = "Environment to be deployed"
  type        = string
}

variable "owner" {
  description = "Resource Owner"
  type        = string
}

variable "project" {
  description = "Resource Owner"
  type        = string
}

variable "vpc_name" {
  description = "VPC Name to be created"
  type        = string
}

variable "cidr" {
  description = "VPC IP Range"
  type        = string
}

variable "availability_zones" {
  description = "AZ to be used"
  type        = list(string)
}

variable "pv_subnets_cidr" {
  description = "Private Subnets IP Range"
  type        = list(string)
}

variable "pb_subnets_cidr" {
  description = "Public Subnets IP Range"
  type        = list(string)
}

variable "cluster" {
  description = "EKS cluster configuration"
  type = object({
    name    = string
    version = string
  })
  default = {
    name    = "mam-sandbox"
    version = "1.31"
  }
}

variable "rabbit_mq" {
  description = "RabbitMQ configuration"
  type = object({
    username        = string
    password        = string
    name            = string
    instance_type   = string
    version         = string
    deployment_mode = string
  })
  default = {
    username        = "rabbit"
    password        = "rabbitrabbit"
    name            = "rabbitmq"
    instance_type   = "mq.t3.micro"
    version         = "3.13"
    deployment_mode = "SINGLE_INSTANCE"
  }
}

variable "database" {
  description = "Database configuration"
  type = object({
    name                = string
    identifier          = string
    instance_type       = string
    storage             = number
    username            = string
    password            = string
    skip_final_snapshot = bool
  })
  default = {
    name                = "mamsandbox"
    identifier          = "mam-sandbox"
    instance_type       = "db.t3.micro"
    storage             = 5
    username            = "root"
    password            = "phraseanet"
    skip_final_snapshot = true
  }
}

variable "elasticache" {
  description = "Elasticache configuration"
  type = object({
    cluster_id = string
    node_type  = string
  })
  default = {
    cluster_id = "mam-sandbox"
    node_type  = "cache.t3.micro"
  }
}

variable "elasticsearch" {
  description = "Elasticsearch configuration"
  type = object({
    name          = string
    instance_type = string
    volume_size   = number
  })
  default = {
    name          = "mam-sandbox"
    instance_type = "t3.small.elasticsearch"
    volume_size   = 10
  }
}

variable "iam_role_additional_policies" {
  description = "Additional policies for the cluster role"
  type        = map(string)
  default     = {}
}
