# Cloud & Infrastructure Automation Foundation

A hands-on infrastructure engineering portfolio project focused on
designing, provisioning, configuring, securing, and validating
reproducible cloud infrastructure.

## Current status

Initial repository and development environment setup.

## Project goals

- Infrastructure as Code with Terraform
- Configuration Management with Ansible
- AWS cloud infrastructure
- Linux administration and hardening
- Networking and IAM
- Automated infrastructure security validation
- CI/CD for infrastructure
- Monitoring and operational practices
- Cost-aware cloud engineering

## Core technologies

- Terraform
- Ansible
- AWS
- Linux
- Git
- GitHub Actions
- TFLint
- Checkov

## Engineering principles

- Infrastructure must be reproducible.
- Infrastructure changes must be version controlled.
- Secrets must never be committed to source control.
- Security validation is integrated into the workflow.
- Infrastructure should be ephemeral when practical.
- Cloud cost must be considered during architecture decisions.
- Architecture decisions must be documented.
- Third-party tools remain subject to their respective licenses.

## Environments

The project is designed to support:

- Development
- UAT
- Production

Development will be implemented first.

The same Terraform modules will later be reused across environments
with environment-specific configuration.
