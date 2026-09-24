variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet used by the EC2 Instance Connect Endpoint."
  type        = string
}

variable "eice_security_group_id" {
  description = "Security group ID attached to the EC2 Instance Connect Endpoint."
  type        = string
}
