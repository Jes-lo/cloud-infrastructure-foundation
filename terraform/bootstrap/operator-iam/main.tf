data "aws_iam_policy_document" "operator_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.operator_principal_arn]
    }
  }
}

resource "aws_iam_role" "terraform_operator" {
  name                 = "TerraformOperatorRole"
  description          = "Least-privilege Terraform operator for cloud-infrastructure-foundation DEV"
  assume_role_policy   = data.aws_iam_policy_document.operator_trust.json
  max_session_duration = 3600
}

resource "aws_iam_policy" "state_private" {
  name        = "CIF-Terraform-StatePrivate"
  description = "Consolidated least-privilege policy for cloud-infrastructure-foundation"
  policy      = local.state_private_policy
}

resource "aws_iam_policy" "network_core" {
  name        = "CIF-Terraform-NetworkCore"
  description = "Consolidated least-privilege policy for cloud-infrastructure-foundation"
  policy      = local.network_core_policy
}

resource "aws_iam_policy" "network_controls" {
  name        = "CIF-Terraform-NetworkControls"
  description = "Consolidated least-privilege policy for cloud-infrastructure-foundation"
  policy      = local.network_controls_policy
}

resource "aws_iam_policy" "compute_access" {
  name        = "CIF-Terraform-ComputeAccess"
  description = "Consolidated least-privilege policy for cloud-infrastructure-foundation"
  policy      = local.compute_access_policy
}

locals {
  functional_policies = {
    state_private    = aws_iam_policy.state_private.arn
    network_core     = aws_iam_policy.network_core.arn
    network_controls = aws_iam_policy.network_controls.arn
    compute_access   = aws_iam_policy.compute_access.arn
  }

  guardrail_policies = {
    region = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/Sandbox-Region-Guardrail-us-east-1"
    cost   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/Sandbox-Cost-Guardrail"
  }

  operator_policies = merge(
    local.functional_policies,
    local.guardrail_policies
  )
}

resource "aws_iam_role_policy_attachment" "operator" {
  for_each = local.operator_policies

  role       = aws_iam_role.terraform_operator.name
  policy_arn = each.value
}
