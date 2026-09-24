resource "aws_security_group" "workload" {
  #checkov:skip=CKV2_AWS_5:This security group is attached to the EC2 workload through a cross-module Terraform output.

  name        = "${var.project_name}-${var.environment}-workload-sg"
  description = "Security group for development workloads"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment}-workload-sg"
  }
}

resource "aws_security_group" "eice" {
  #checkov:skip=CKV2_AWS_5:This security group is attached to the EC2 Instance Connect Endpoint through a cross-module Terraform output.

  name        = "${var.project_name}-${var.environment}-eice-sg"
  description = "Security group for EC2 Instance Connect Endpoint"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment}-eice-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "workload_ssh_from_eice" {
  #checkov:skip=CKV_AWS_24:SSH ingress references only the EICE security group; no Internet CIDR is configured.

  security_group_id            = aws_security_group.workload.id
  referenced_security_group_id = aws_security_group.eice.id

  description = "Allow SSH only from EC2 Instance Connect Endpoint"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "eice_ssh_to_workload" {
  security_group_id            = aws_security_group.eice.id
  referenced_security_group_id = aws_security_group.workload.id

  description = "Allow EC2 Instance Connect Endpoint to reach workload over SSH"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}
