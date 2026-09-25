locals {
  policy_template_vars = {
    account_id                 = data.aws_caller_identity.current.account_id
    aws_region                 = var.aws_region
    project_name               = var.project_name
    repository_name            = var.repository_name
    environment                = var.environment
    state_bucket_name          = var.state_bucket_name
    vpc_id                     = var.vpc_id
    private_subnet_id          = var.private_subnet_id
    workload_security_group_id = var.workload_security_group_id
    eice_security_group_id     = var.eice_security_group_id
    approved_ami_id            = var.approved_ami_id
    private_subnet_cidr        = var.private_subnet_cidr
  }

  state_private_policy = jsonencode(
    jsondecode(
      templatefile(
        "${path.module}/policies/state-private.json.tftpl",
        local.policy_template_vars
      )
    )
  )

  network_core_policy = jsonencode(
    jsondecode(
      templatefile(
        "${path.module}/policies/network-core.json.tftpl",
        local.policy_template_vars
      )
    )
  )

  network_controls_policy = jsonencode(
    jsondecode(
      templatefile(
        "${path.module}/policies/network-controls.json.tftpl",
        local.policy_template_vars
      )
    )
  )

  compute_access_policy = jsonencode(
    jsondecode(
      templatefile(
        "${path.module}/policies/compute-access.json.tftpl",
        local.policy_template_vars
      )
    )
  )
}
