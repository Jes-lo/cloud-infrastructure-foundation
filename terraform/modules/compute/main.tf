data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "workload" {
  #checkov:skip=CKV_AWS_126:Detailed monitoring is intentionally disabled in the cost-constrained development environment.
  #checkov:skip=CKV2_AWS_41:No IAM role is attached because the workload currently requires no AWS
  ami           = data.aws_ssm_parameter.al2023_ami.value
  instance_type = var.instance_type

  ebs_optimized = true

  credit_specification {
    cpu_credits = "standard"
  }

  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [var.workload_security_group_id]
  associate_public_ip_address = false

  monitoring = false

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-workload"
  }
}
