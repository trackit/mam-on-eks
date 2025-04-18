variable "cluster_id" {
  description = "The ID of the cluster"
  type        = string
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
  description = "Owner of the Elasticache cluster"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "node_type" {
  description = "The node type for the Elasticache cluster"
  type        = string
  default     = "cache.t2.micro"
}
