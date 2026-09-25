# Terraform Least-Privilege IAM Model

## Purpose

This project separates routine Terraform execution from IAM bootstrap and
recovery administration.

The goal is to minimize the AWS permissions used for normal infrastructure
operations while preserving a controlled administrative path for IAM changes.

## Roles and responsibilities

### Bootstrap administrator

The bootstrap credential path is responsible for administrative operations
that the Terraform operator is intentionally not allowed to perform.

Examples include:

- creating or changing the Terraform operator role;
- creating or changing its managed policies;
- attaching or detaching IAM policies;
- recovery if the operator policy becomes unusable.

The bootstrap identity is not intended to be the normal Terraform execution
identity.

### Terraform operator

`TerraformOperatorRole` is the normal infrastructure execution role.

It manages the approved development infrastructure and remote Terraform state
but does not administer IAM.

## Authentication flow

The local authentication chain is:

~~~text
AWS Login
   |
   v
portfolio-dev
   |
   v
credential_process
   |
   v
portfolio-dev-process
   |
   v
STS AssumeRole
   |
   v
portfolio-operator
   |
   v
TerraformOperatorRole
   |
   v
Terraform
~~~

`credential_process` bridges AWS Login credentials into a credential format
that Terraform's AWS SDK credential chain can consume.

No permanent access keys are required for this workflow.

## IAM policy structure

The role uses four project-specific functional policies.

### CIF-Terraform-StatePrivate

Provides:

- access to the development Terraform state and lock object;
- required infrastructure read operations;
- private administrative access through EC2 Instance Connect Endpoint.

### CIF-Terraform-NetworkCore

Provides controlled creation and management of:

- VPC;
- subnets;
- route tables;
- routes;
- route-table associations.

Creation is constrained using project/environment tagging and approved
development resources.

### CIF-Terraform-NetworkControls

Provides controlled management of:

- security groups;
- security-group rules;
- Internet Gateway;
- selected network lifecycle operations.

### CIF-Terraform-ComputeAccess

Provides controlled management of:

- the approved development EC2 workload;
- encrypted gp3 storage;
- EC2 Instance Connect Endpoint resources;
- instance lifecycle operations.

Compute creation is intentionally constrained by characteristics such as
approved AMI, private subnet, workload security group, instance type, IMDSv2,
encryption, and volume size.

## Guardrails

Two additional customer-managed policies remain attached to the operator role.

### Region guardrail

Provides explicit deny protection against disallowed regional operations.

The development environment is restricted to `us-east-1`.

### Cost guardrail

Provides explicit deny controls for resource configurations that could create
unexpected cost.

Examples include restrictions around:

- larger EC2 instance types;
- oversized or non-gp3 EBS volumes;
- public IPv4 usage;
- NAT Gateways;
- load balancers;
- dedicated hosts;
- selected expensive managed services.

Explicit deny takes precedence over allow permissions in the functional
operator policies.

## IAM self-management

The operator intentionally does not receive IAM permissions such as:

~~~text
iam:CreateRole
iam:CreatePolicy
iam:CreatePolicyVersion
iam:AttachRolePolicy
iam:PutRolePolicy
iam:UpdateAssumeRolePolicy
~~~

This prevents the operational role from changing or elevating its own access.

The `operator-iam` Terraform stack must therefore be executed with the
bootstrap administrative credential path.

## Terraform state

The IAM bootstrap stack uses:

~~~text
bootstrap/operator-iam/terraform.tfstate
~~~

in the existing encrypted S3 Terraform backend.

S3 native state locking is enabled with `use_lockfile = true`.

Local backend configuration and `.tfvars` files are excluded from Git.

## Validation evidence

The role has successfully performed a no-change Terraform plan against the
current development infrastructure.

The following negative authorization tests were also validated:

- IAM user enumeration is denied to the operator;
- EC2 API access outside the approved region is explicitly denied.

The IAM resources were imported into the `operator-iam` Terraform stack and a
subsequent Terraform plan reported no differences.

The repository validation pipeline runs:

~~~text
terraform fmt -check
terraform init -backend=false
terraform validate
tflint
checkov
~~~

against the bootstrap and development Terraform stacks.

`-backend=false` ensures CI validation does not require AWS credentials or
access to remote state.

## Important limitation

The operator should not be described as proven capable of rebuilding the
entire environment from scratch.

Current-state refresh and normal no-change planning have been tested against
AWS. Creation permissions were also evaluated through IAM Policy Simulator.

Some permissions deliberately bind creation to approved existing resource
identifiers. If those boundaries change, the bootstrap administrator must
review and update the IAM policy.

This is an approval boundary, not an accidental limitation.

## Security principle

The design follows a separation-of-duties model:

~~~text
Bootstrap administration
        |
        | creates and governs
        v
TerraformOperatorRole
        |
        | operates within constrained permissions
        v
Development infrastructure
~~~

The Terraform execution role cannot modify the mechanism that defines its own
authority.
