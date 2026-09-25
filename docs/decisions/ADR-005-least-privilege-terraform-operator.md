# ADR-005: Separate Least-Privilege Terraform Operator from Bootstrap Administration

## Status

Accepted

## Context

The development environment was initially administered with a bootstrap IAM
principal that has broader account permissions than are required for routine
Terraform operations.

Using broad administrative permissions for normal infrastructure lifecycle
operations increases the impact of credential misuse, configuration mistakes,
or unintended Terraform changes.

The project therefore requires a separation between:

- bootstrap and recovery administration;
- routine Terraform infrastructure operations.

The Terraform operator must be able to manage the intended development
infrastructure without being able to modify its own IAM permissions.

## Decision

Use a dedicated IAM role named `TerraformOperatorRole` for routine Terraform
operations.

The role is managed by a separate Terraform bootstrap stack:

~~~text
terraform/bootstrap/operator-iam
~~~

The operator role does not receive IAM permissions that would allow it to
create, modify, attach, or delete its own policies or role configuration.

Administrative IAM changes remain a bootstrap responsibility and are performed
using a separate bootstrap credential path.

The operator uses four project-specific customer-managed policies:

- `CIF-Terraform-StatePrivate`
- `CIF-Terraform-NetworkCore`
- `CIF-Terraform-NetworkControls`
- `CIF-Terraform-ComputeAccess`

Two sandbox guardrail policies are also attached:

- regional restriction to `us-east-1`;
- cost and resource restriction policy.

The guardrails remain separate from the project-specific policies so that
explicit-deny controls are independently visible and reusable.

## Authentication model

Local authentication follows this chain:

~~~text
AWS Login
   |
   v
credential_process
   |
   v
STS AssumeRole
   |
   v
TerraformOperatorRole
   |
   v
Terraform
~~~

No permanent AWS access keys are required for the Terraform operator workflow.

The bootstrap credential path is used only for administrative operations such
as managing the operator IAM stack itself.

Routine development Terraform operations use the assumed operator role.

## State separation

The Terraform state backend itself is bootstrapped separately.

~~~text
terraform/bootstrap/state-backend
~~~

This stack creates the S3 backend and therefore retains its bootstrap state
independently.

The operator IAM stack uses remote S3 state at:

~~~text
bootstrap/operator-iam/terraform.tfstate
~~~

The development environment uses a separate remote state key.

## Least-privilege boundaries

The operator permissions are constrained through combinations of:

- AWS service actions;
- project and environment resource tags;
- request tags during resource creation;
- approved resource types;
- approved development resources where appropriate;
- private networking requirements;
- instance type and storage restrictions;
- regional guardrails;
- cost guardrails.

The role intentionally does not include general IAM administration.

## Validation

The implemented role has been validated through:

- successful Terraform refresh and no-change plan of the development stack;
- successful remote-state access and state locking;
- denial of IAM user enumeration;
- explicit denial of EC2 API activity outside the approved region;
- IAM Policy Simulator tests for expected infrastructure operations;
- Terraform import of the existing IAM role, policies, and attachments;
- no-change plan after the IAM resources were brought under Terraform;
- remote-state migration of the operator IAM stack;
- Terraform, TFLint, and Checkov repository validation.

## Limitations

A successful no-change Terraform plan proves that the role can read and refresh
the current infrastructure and access its remote state.

It does not prove every possible complete destroy-and-recreate path.

Some creation permissions intentionally reference currently approved
development resources such as subnet, security group, and AMI identifiers.

Replacement of those security boundaries may therefore require an explicit
bootstrap review and IAM policy update.

This behavior is intentional. Changes to approved security boundaries should
require an administrative approval step rather than granting the operational
role unrestricted self-service access.

Policy Simulator results support the designed creation permissions, but they
are not treated as equivalent to executing destructive infrastructure tests.

## Consequences

Routine Terraform work no longer requires broad administrative permissions.

The operator cannot elevate its own IAM permissions.

IAM administration remains recoverable through the separate bootstrap path.

Some infrastructure replacements may require coordinated bootstrap IAM
updates.

The architecture now has an explicit separation between bootstrap
administration and day-to-day infrastructure operation.
