variable "username" {
  description = "Username for the RabbitMQ broker"
  type        = string
}

variable "password" {
  description = "Password for the RabbitMQ broker"
  type        = string
}

variable "name" {
  description = "Name for the RabbitMQ broker"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the RabbitMQ broker"
  type        = string
}

variable "rabbit_mq_version" {
  description = "Version for the RabbitMQ broker"
  type        = string
}

variable "deployment_mode" {
  description = "Deployment mode for the RabbitMQ broker"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the RabbitMQ broker"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the RabbitMQ broker"
  type        = string
}

variable "owner" {
  description = "Owner of the RabbitMQ broker"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}
