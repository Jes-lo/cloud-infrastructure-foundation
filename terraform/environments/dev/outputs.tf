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
