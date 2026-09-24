# ADR-001: Terraform as the Primary Infrastructure as Code Tool

## Status

Accepted

## Context

The project requires a reproducible and version-controlled method for
provisioning cloud infrastructure.

Manual provisioning through the AWS Management Console would make the
environment harder to reproduce, review, and automate.

## Decision

Terraform will be used as the primary Infrastructure as Code tool.

Ansible will complement Terraform as the configuration management tool.

Terraform will be responsible for provisioning infrastructure.

Ansible will be responsible for operating system and service
configuration where appropriate.

## Consequences

### Benefits

- Reproducible infrastructure
- Version-controlled infrastructure changes
- Infrastructure review through pull requests
- Automated validation
- Reusable Terraform modules
- Support for multiple environments

### Considerations

- Terraform state must be protected.
- Secrets must not be stored in Terraform source files.
- State management requires a defined strategy.
- Infrastructure changes require validation before deployment.
