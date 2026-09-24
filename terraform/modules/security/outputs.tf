output "workload_security_group_id" {
  description = "ID of the workload security group."
  value       = aws_security_group.workload.id
}

output "eice_security_group_id" {
  description = "ID of the EC2 Instance Connect Endpoint security group."
  value       = aws_security_group.eice.id
}
