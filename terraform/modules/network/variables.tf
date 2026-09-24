variable "project_name" {
  description = "Project name used for resource naming and tagging."
  type        = string
}

variable "environment" {
  description = "Environment where the network is deployed."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block assigned to the VPC."
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block assigned to the public subnet."
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block assigned to the private subnet."
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone used by the subnets."
  type        = string
}
