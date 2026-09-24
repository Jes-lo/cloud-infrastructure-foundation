# INC-001: Terraform Apply Interrupted by Unexpected EOF

## Status

Resolved

## Summary

During development infrastructure provisioning, Terraform encountered
unexpected EOF errors while processing AWS EC2 API responses.

The failures occurred after some AWS resources had already been created.

This created a partial-apply situation where Terraform execution failed
even though portions of the requested infrastructure existed in AWS.

## Impact

The incident affected provisioning of:

- Security-group resources.
- EC2 Instance Connect Endpoint resources.
- Terraform state reconciliation.

The EC2 workload had also been created successfully during the apply.

Because the project prioritizes cost containment, the EC2 instance was
stopped while the infrastructure state was investigated.

## Detection

Terraform returned errors containing:

`decomposing response: unexpected EOF`

Direct AWS CLI queries were then used to determine the actual state of
the affected resources.

## Response

The recovery process followed these principles:

1. Do not immediately rerun the original saved Terraform plan.
2. Stop potentially billable compute while investigating.
3. Inspect Terraform state.
4. Inspect the actual AWS resources independently with AWS CLI.
5. Compare Terraform state with AWS state.
6. Recover only the resources that still required reconciliation.
7. Generate a new Terraform plan after recovery.

A security group temporarily marked as tainted was inspected directly in
AWS before being untainted.

A subsequent recovery plan contained only the resources that were still
required.

During creation of the EC2 Instance Connect Endpoint, another unexpected
EOF occurred after AWS had already reported the endpoint as
`create-complete`.

Terraform was subsequently able to refresh the resource successfully.

## Validation

Recovery was considered complete only after:

- The EC2 Instance Connect Endpoint reported `create-complete`.
- Security-group rules existed as designed.
- The workload remained in the private subnet.
- Terraform refreshed all managed resources successfully.
- `terraform plan` returned no infrastructure changes.

## Root Cause

A definitive root cause was not established.

The observed failure occurred while Terraform/AWS provider processing
encountered incomplete response data from EC2 API operations.

Because the cloud-side resources could still complete successfully, the
incident was treated as a state-reconciliation problem rather than
assuming that failed Terraform execution meant failed AWS resource
creation.

## Lessons Learned

- Terraform apply operations should not be treated as globally atomic.
- A failed apply does not guarantee that no resources were created.
- Cloud state must be inspected before retrying potentially destructive
  or duplicate operations.
- Saved Terraform plans should not be reused blindly after a partial
  apply.
- Cost-sensitive resources should be stopped or removed while
  troubleshooting when practical.
- Terraform state and actual cloud state must both be considered during
  recovery.
- Direct provider/API errors should be documented without claiming a
  root cause that has not been proven.
