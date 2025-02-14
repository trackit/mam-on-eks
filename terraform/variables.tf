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

variable "cluster_name" {
  description = "Name of the Cluster"
  type        = string
  default     = "mam-sandbox"
}

variable "cluster_version" {
  description = "Version of the Cluster"
  type        = string
}

variable "iam_role_additional_policies" {
  description = "Additional policies for the cluster role"
  type        = map(string)
  default     = {}
}