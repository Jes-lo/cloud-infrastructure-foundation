resource "aws_ec2_instance_connect_endpoint" "this" {
  subnet_id          = var.private_subnet_id
  security_group_ids = [var.eice_security_group_id]

  preserve_client_ip = false

  tags = {
    Name = "${var.project_name}-${var.environment}-eice"
  }
}
