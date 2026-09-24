variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet where the workload instance will be deployed."
  type        = string
}

variable "workload_security_group_id" {
  description = "Security group attached to the workload instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type used by the development workload."
  type        = string
  default     = "t3.micro"

  validation {
    condition     = var.instance_type == "t3.micro"
    error_message = "The development environment only permits t3.micro."
  }
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB."
  type        = number
  default     = 8

  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 30
    error_message = "Root volume size must be between 8 and 30 GiB."
  }
}
