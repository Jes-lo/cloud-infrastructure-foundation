output "instance_id" {
  description = "ID of the workload EC2 instance."
  value       = aws_instance.workload.id
}

output "private_ip" {
  description = "Private IPv4 address of the workload EC2 instance."
  value       = aws_instance.workload.private_ip
}

output "ami_id" {
  description = "Amazon Linux 2023 AMI used by the workload instance."
  value       = nonsensitive(data.aws_ssm_parameter.al2023_ami.value)
}
