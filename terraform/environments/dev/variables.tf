variable "aws_region" {
  description = "AWS region where the development environment is deployed."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = var.aws_region == "us-east-1"
    error_message = "This sandbox project is restricted to us-east-1."
  }
}

variable "project_name" {
  description = "Name used to identify project resources."
  type        = string
  default     = "cloud-infrastructure-foundation"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "Environment must be dev, uat, or prod."
  }
}

variable "vpc_cidr" {
  description = "CIDR block assigned to the VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block assigned to the public subnet."
  type        = string
  default     = "10.20.10.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block assigned to the private subnet."
  type        = string
  default     = "10.20.20.0/24"
}

variable "availability_zone" {
  description = "Availability Zone used by the development environment."
  type        = string
  default     = "us-east-1a"

  validation {
    condition     = startswith(var.availability_zone, "us-east-1")
    error_message = "Availability Zone must belong to us-east-1."
  }
}
