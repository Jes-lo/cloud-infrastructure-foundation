# Cloud & Infrastructure Automation Foundation

**Core technologies:** Terraform · Ansible · AWS · Linux · GitHub Actions · TFLint · Checkov

A hands-on cloud infrastructure engineering portfolio project focused on
designing, provisioning, securing, configuring, and validating
reproducible AWS infrastructure.

The project is built as a greenfield implementation and emphasizes
Infrastructure as Code, private administrative access, configuration
management, security validation, operational troubleshooting, and
cost-aware architecture.

## Current Status

The development environment currently includes:

- Modular Terraform infrastructure.
- AWS VPC with public and private subnets.
- Dedicated public and private route tables.
- Internet Gateway for the public network path.
- Private workload with no public IPv4 address.
- Amazon Linux 2023 EC2 instance.
- Encrypted gp3 root storage.
- IMDSv2 enforcement.
- EC2 Instance Connect Endpoint for private administrative access.
- Security-group-to-security-group SSH access.
- Temporary SSH authentication through EC2 Instance Connect.
- Ansible configuration management through EICE.
- Linux and SSH security baseline.
- Terraform-to-Ansible runtime inventory integration.
- Terraform validation, TFLint, and Checkov security analysis.
- Encrypted remote Terraform state with native S3 locking.
- Dedicated least-privilege Terraform operator role for routine operations.
- Separate Terraform bootstrap stack for IAM operator administration.
- Regional and cost guardrails applied to the Terraform operator.
- Architecture Decision Records.
- Incident and validation documentation.

The development workload is stopped when not required in order to reduce
cloud cost.

## Quick Start

### Prerequisites

The local validation workflow expects:

- Linux or WSL.
- Git.
- Terraform.
- TFLint.
- Checkov.

AWS credentials are not required to run the repository validation workflow.

### Clone and validate

Clone the repository and enter the project directory:

~~~bash
git clone https://github.com/Jes-lo/cloud-infrastructure-foundation.git
cd cloud-infrastructure-foundation
~~~

Run the infrastructure validation workflow:

~~~bash
./scripts/validate-infrastructure.sh
~~~

The validation script checks all Terraform stacks with:

- `terraform fmt -check`
- `terraform init -backend=false`
- `terraform validate`
- TFLint
- Checkov

Remote Terraform state is not accessed during this validation workflow.

### AWS deployment

AWS deployment is intentionally not part of the Quick Start.

Provisioning requires environment-specific backend configuration, Terraform
variables, AWS authentication, cost review, and appropriate IAM permissions.

Local files such as `backend.hcl`, `terraform.tfvars`, Terraform state,
Terraform plans, and generated runtime inventory are intentionally excluded
from Git.

Review the architecture decisions and security documentation before performing
infrastructure lifecycle operations.

## Architecture

```text
Administrative workstation / WSL
            |
            | AWS IAM authentication
            | temporary SSH key
            v
EC2 Instance Connect Endpoint
            |
            | TCP/22
            | security-group relationship
            v
Private EC2 workload
Amazon Linux 2023
10.20.0.0/16 VPC
```

The workload does not require a public IPv4 address for administrative
access.

## Infrastructure Design

The development VPC uses:

```text
VPC
10.20.0.0/16

├── Public subnet
│   10.20.10.0/24
│
└── Private subnet
    10.20.20.0/24
    ├── EC2 workload
    └── EC2 Instance Connect Endpoint
```

The public subnet has a route to an Internet Gateway.

The private subnet intentionally has no default Internet route.

A NAT Gateway is not currently deployed because the workload does not
require general outbound Internet access and the project prioritizes
cost-aware architecture.

## Infrastructure as Code

Terraform is the authoritative tool for infrastructure provisioning.

The repository uses reusable modules for:

- Networking.
- Security groups.
- Private administrative access.
- Compute.

Terraform state is separated according to bootstrap responsibility.

The development environment uses encrypted remote S3 state with native
state locking.

The Terraform operator IAM stack also uses remote state under its own
isolated S3 state key.

The `state-backend` bootstrap stack retains local state because that stack
creates the remote backend itself.

Environment-specific Terraform configuration is stored under:

`terraform/environments/dev`

Reusable infrastructure components are stored under:

`terraform/modules`

## Configuration Management

Ansible manages operating-system configuration after Terraform provisions
the infrastructure.

The current Linux baseline manages:

- `chronyd` service state.
- SSH configuration directory permissions.
- SSH daemon hardening.
- Safe SSH configuration validation before reload.

The effective SSH baseline includes:

```text
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitEmptyPasswords no
X11Forwarding no
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
```

Ansible connects as `ec2-user`.

Administrative tasks use privilege escalation through `sudo`; direct SSH
login as root is not used.

## Terraform and Ansible Integration

EC2 instance IDs are runtime infrastructure values and are not committed
to source control.

The script:

`scripts/render-ansible-inventory.sh`

reads the current Terraform output:

`workload_instance_id`

and generates the local Ansible inventory.

The generated inventory is excluded from Git.

This allows the EC2 instance to be destroyed and recreated without
hardcoding the new instance ID into the Ansible configuration.

## Private Administrative Access

Administrative access uses EC2 Instance Connect Endpoint.

The workload security group accepts SSH only from the EICE security
group.

The EICE security group permits SSH only toward the workload security
group.

The design avoids:

- Public SSH exposure.
- Persistent EC2 SSH key pairs.
- Public workload addresses.
- Dedicated bastion hosts.
- NAT Gateway dependency for administrative access.

The reasoning is documented in:

`docs/decisions/ADR-003-private-administrative-access.md`

## Least-Privilege Terraform Operations

Routine Terraform operations use the dedicated assumed IAM role:

`TerraformOperatorRole`

The authentication flow is:

AWS Login -> credential_process -> STS AssumeRole ->
TerraformOperatorRole -> Terraform

The operator uses four project-specific managed policies covering:

- Terraform state and private administrative access.
- Core networking.
- Network security and lifecycle controls.
- Compute and EC2 Instance Connect Endpoint operations.

Separate regional and cost guardrails provide explicit-deny protection.

The operator intentionally does not receive general IAM administration
permissions and cannot modify its own role or managed policies.

IAM bootstrap and recovery operations remain separated under:

`terraform/bootstrap/operator-iam`

The design and operational model are documented in:

- `docs/decisions/ADR-005-least-privilege-terraform-operator.md`
- `docs/security/iam-least-privilege.md`

The role has been validated for remote-state access, infrastructure refresh,
no-change planning, expected authorization denials, and IAM Policy Simulator
scenarios.

This validation is not represented as proof that every complete
destroy-and-recreate path can run without bootstrap review.

## Security Validation

Infrastructure code is validated with:

- `terraform fmt`
- `terraform validate`
- TFLint
- Checkov

Checkov findings are reviewed rather than blindly suppressed.

Some controls may represent deliberate development-environment trade-offs
or static-analysis limitations and should be documented when accepted.

## Ansible Validation

The Linux baseline was validated through the following workflow:

```text
Ansible connectivity
        |
        v
pong
        |
        v
Privilege escalation
whoami -> root
        |
        v
Apply baseline
        |
        v
sshd -t succeeds
        |
        v
Reload sshd
        |
        v
EICE connectivity still works
        |
        v
Validate effective configuration
        |
        v
Second Ansible execution
changed=0
```

The second playbook execution completed with no changes, demonstrating
idempotent configuration management.

Validation evidence is documented in:

`docs/evidence/ansible-linux-baseline.md`

## Operational Troubleshooting

A Terraform apply encountered unexpected EOF errors while some AWS
resources had already completed successfully.

Recovery required comparing:

- Terraform state.
- Actual AWS resource state.
- Direct AWS CLI queries.

Potentially billable compute was stopped during investigation.

The environment was considered reconciled only after Terraform returned
a no-change plan.

The incident is documented in:

`docs/incidents/INC-001-terraform-apply-unexpected-eof.md`

## Cost-Aware Architecture

The development environment follows a cost-conscious design.

Current decisions include:

- `t3.micro` development compute.
- 8 GiB encrypted gp3 root volume.
- Standard T3 CPU credits.
- Detailed EC2 monitoring disabled for the current development phase.
- No NAT Gateway.
- No Elastic IP.
- No load balancer.
- No managed Kubernetes cluster.
- EC2 stopped when active testing is complete.

Potentially billable infrastructure is evaluated before it is added.

## Repository Structure

```text
.
├── ansible/
│   ├── inventories/
│   ├── playbooks/
│   └── roles/
├── docs/
│   ├── decisions/
│   ├── evidence/
│   ├── incidents/
│   └── security/
├── scripts/
└── terraform/
    ├── bootstrap/
    │   ├── operator-iam/
    │   └── state-backend/
    ├── environments/
    │   └── dev/
    └── modules/
```

## Engineering Principles

- Infrastructure must be reproducible.
- Infrastructure changes must be version controlled.
- Secrets must never be committed to source control.
- Least privilege should be applied where practical.
- Administrative workloads should remain private by default.
- Security validation should be part of the engineering workflow.
- Infrastructure should be ephemeral when practical.
- Cloud cost must influence architecture decisions.
- Architecture decisions and operational incidents should be documented.
- Failed automation must be reconciled against actual cloud state before
  retrying.
- Third-party software remains subject to its respective license.

## Environments

The repository is designed to support:

- Development
- UAT
- Production

Development is implemented first.

Reusable Terraform modules are intended to support additional
environments with environment-specific configuration.

## Remote Terraform State

The development environment uses a dedicated Amazon S3 backend for
Terraform state.

The backend provides:

- S3 versioning for state recovery.
- Server-side AES256 encryption.
- Public access blocking.
- BucketOwnerEnforced ownership controls.
- TLS-only access enforced by bucket policy.
- Native S3 state locking with `use_lockfile = true`.
- Lifecycle management for previous state versions.

The state bucket is provisioned through the isolated
`terraform/bootstrap/state-backend` configuration.

Runtime backend configuration is supplied through a local,
Git-ignored `backend.hcl` file.

CI validates all Terraform stacks using isolated temporary Terraform data
directories and `terraform init -backend=false`.

The validated stacks are:

- `terraform/bootstrap/state-backend`
- `terraform/bootstrap/operator-iam`
- `terraform/environments/dev`

GitHub Actions does not require AWS credentials or access to the
remote Terraform state.

## Continuous Integration

Infrastructure changes are automatically validated with GitHub Actions.

The validation workflow runs on pushes and pull requests targeting
`main` and executes:

- Terraform formatting validation.
- Terraform initialization without a backend.
- Terraform configuration validation.
- TFLint static analysis.
- Checkov security scanning.

The CI workflow does not receive AWS credentials and does not run
`terraform plan` or `terraform apply`.

Checkov exceptions must be explicitly scoped and documented rather than
globally ignored.

The workflow uses pinned tool versions and an Ubuntu 24.04 runner to
improve reproducibility between local and CI validation.

## Planned Work

Future phases include:

- Additional Linux baseline controls where justified.
- Cloud logging and monitoring decisions.
- Operational runbooks.
- Additional environment reuse.
- Controlled infrastructure lifecycle automation.

New services will only be introduced when they solve a defined
engineering requirement.
