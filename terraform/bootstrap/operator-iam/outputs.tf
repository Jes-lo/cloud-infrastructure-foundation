output "terraform_operator_role_arn" {
  description = "ARN of the least-privilege Terraform operator role."
  value       = aws_iam_role.terraform_operator.arn
}

output "terraform_operator_policy_arns" {
  description = "Customer-managed functional policies attached to the operator."
  value = {
    state_private    = aws_iam_policy.state_private.arn
    network_core     = aws_iam_policy.network_core.arn
    network_controls = aws_iam_policy.network_controls.arn
    compute_access   = aws_iam_policy.compute_access.arn
  }
}
