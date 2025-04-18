variable "name" {
  description = "Name for the ElasticSearch"
  type        = string
  default     = "mam-sandbox"
}

variable "pv_subnet_ids" {
  description = "The IDs of the private subnets"
  type        = list(string)
}

variable "pv_subnets_cidr" {
  description = "The CIDR blocks of the private subnets"
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "owner" {
  description = "Owner of the ElasticSearch cluster"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the ElasticSearch cluster"
  type        = string
  default     = "t3.small.elasticsearch"
}

variable "volume_size" {
  description = "Volume size for the ElasticSearch cluster"
  type        = number
  default     = 10
}
