# Cloud & Infrastructure Automation Foundation

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
- Architecture Decision Records.
- Incident and validation documentation.

The development workload is stopped when not required in order to reduce
cloud cost.

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

Terraform state is currently local during the development phase.

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
│   └── incidents/
├── scripts/
└── terraform/
    ├── environments/
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

## Planned Work

Future phases include:

- Additional Linux baseline controls where justified.
- Infrastructure CI/CD with GitHub Actions.
- Automated validation in pull requests.
- Remote Terraform state design.
- Cloud logging and monitoring decisions.
- Operational runbooks.
- Additional environment reuse.
- Controlled infrastructure lifecycle automation.

New services will only be introduced when they solve a defined
engineering requirement.
