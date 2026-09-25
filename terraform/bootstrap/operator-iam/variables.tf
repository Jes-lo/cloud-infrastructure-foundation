variable "aws_region" {
  description = "AWS region used by the project."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project identifier used by IAM conditions and tags."
  type        = string
  default     = "cloud-infrastructure-foundation"
}

variable "environment" {
  description = "Environment controlled by the Terraform operator."
  type        = string
  default     = "dev"
}

variable "operator_principal_arn" {
  description = "IAM principal allowed to assume TerraformOperatorRole."
  type        = string
}

variable "state_bucket_name" {
  description = "S3 bucket containing Terraform remote state."
  type        = string
}

variable "private_subnet_id" {
  description = "Approved private subnet for the DEV workload."
  type        = string
}

variable "workload_security_group_id" {
  description = "Approved workload security group."
  type        = string
}

variable "eice_security_group_id" {
  description = "Approved EC2 Instance Connect Endpoint security group."
  type        = string
}

variable "approved_ami_id" {
  description = "Amazon Linux 2023 AMI currently approved for RunInstances."
  type        = string
}

variable "private_subnet_cidr" {
  description = "Private CIDR reachable through EC2 Instance Connect Endpoint."
  type        = string
  default     = "10.20.20.0/24"
}

variable "repository_name" {
  description = "Repository identifier required by IAM tag conditions."
  type        = string
  default     = "cloud-infrastructure-foundation"
}

variable "vpc_id" {
  description = "VPC controlled by the DEV Terraform operator."
  type        = string
}
