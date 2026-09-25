# Security Policy

## Scope

This repository is a portfolio and engineering demonstration project.

Security issues relevant to this repository may include:

- accidentally committed credentials or secrets;
- exposed AWS account or resource information that should remain private;
- unsafe Terraform or Ansible configuration;
- insecure CI/CD configuration;
- unintended privilege escalation;
- security-sensitive documentation errors.

## Reporting a security issue

Do not publish credentials, secrets, tokens, private keys, or other sensitive
information in a public issue.

When private vulnerability reporting is available through GitHub, use that
mechanism.

Otherwise, contact the repository owner privately before disclosing sensitive
details publicly.

## Credentials and secrets

This repository must not contain:

- AWS access keys;
- temporary AWS session credentials;
- private SSH keys;
- local Terraform variable files;
- local backend configuration;
- Terraform state files;
- Terraform plan files;
- generated Ansible runtime inventory containing environment-specific values.

Local and environment-specific artifacts are excluded through `.gitignore`.

## Infrastructure changes

Pull requests and commits should be validated before merge using:

- Terraform formatting;
- Terraform configuration validation;
- TFLint;
- Checkov.

CI intentionally does not receive AWS credentials and does not run
`terraform plan` or `terraform apply`.

Potentially billable or security-sensitive infrastructure changes should be
reviewed before being applied to AWS.

## Supported versions

This repository represents an actively developed portfolio project rather than
a versioned software product.

Only the current `main` branch is considered maintained.
