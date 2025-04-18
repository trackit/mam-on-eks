variable "username" {
  description = "Username for the database"
  type        = string
}

variable "password" {
  description = "Password for the database"
  type        = string
}

variable "identifier" {
  description = "Identifier for the database"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the database"
  type        = string
  default     = "db.t3.micro"
}

variable "storage" {
  description = "Storage for the database"
  type        = number
  default     = 5
}

variable "pv_subnet_ids" {
  description = "Subnet IDs for the database"
  type        = list(string)
}

variable "pv_subnets_cidr" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
}

variable "owner" {
  description = "Owner of the database"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name of the database"
  type        = string
  default     = "mamsandbox"
}

variable "sns_topic_arn" {
  description = "The arn for the sns topic"
  type        = string
}
