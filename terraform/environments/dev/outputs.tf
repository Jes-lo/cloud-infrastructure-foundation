output "vpc_id" {
  description = "Development VPC ID."
  value       = module.network.vpc_id
}

output "public_subnet_id" {
  description = "Development public subnet ID."
  value       = module.network.public_subnet_id
}

output "private_subnet_id" {
  description = "Development private subnet ID."
  value       = module.network.private_subnet_id
}

output "availability_zone" {
  description = "Availability Zone used by the development network."
  value       = module.network.availability_zone
}
output "workload_security_group_id" {
  description = "ID of the workload security group."
  value       = module.security.workload_security_group_id
}
output "instance_connect_endpoint_id" {
  description = "ID of the EC2 Instance Connect Endpoint."
  value       = module.access.endpoint_id
}
output "workload_instance_id" {
  description = "ID of the workload EC2 instance."
  value       = module.compute.instance_id
}

output "workload_private_ip" {
  description = "Private IPv4 address of the workload EC2 instance."
  value       = module.compute.private_ip
}

output "workload_ami_id" {
  description = "Amazon Linux 2023 AMI used by the workload instance."
  value       = module.compute.ami_id
}
