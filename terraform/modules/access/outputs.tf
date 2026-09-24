output "endpoint_id" {
  description = "ID of the EC2 Instance Connect Endpoint."
  value       = aws_ec2_instance_connect_endpoint.this.id
}
