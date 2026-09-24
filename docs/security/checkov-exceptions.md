# Checkov Security Exceptions

## Purpose

Checkov is used as a security validation gate for Terraform code.

Security checks are not globally disabled. Exceptions are scoped to
specific Terraform resources and require an engineering justification.

## Development Environment Exceptions

### CKV_AWS_126 - EC2 Detailed Monitoring

Status: Accepted development trade-off.

Detailed EC2 monitoring is intentionally disabled in the current
cost-constrained development environment.

Basic monitoring remains available.

This decision should be reconsidered for production environments.

### CKV2_AWS_41 - EC2 IAM Role

Status: Accepted by design.

The workload currently requires no AWS API permissions.

An IAM role is therefore not attached solely to satisfy a static-analysis
control.

If the workload later requires AWS API access, a least-privilege instance
role should be introduced.

### CKV_AWS_24 - SSH Internet Exposure

Status: Static-analysis exception.

The workload SSH rule does not permit an Internet CIDR.

TCP/22 uses a referenced security group and accepts traffic only from the
EC2 Instance Connect Endpoint security group.

No `0.0.0.0/0` SSH ingress rule is configured.

### CKV2_AWS_5 - Workload Security Group

Status: Static-analysis exception.

The workload security group is attached to the EC2 instance through
Terraform module outputs.

The association crosses module boundaries and is not recognized by this
Checkov evaluation.

### CKV2_AWS_5 - EICE Security Group

Status: Static-analysis exception.

The EICE security group is attached to the EC2 Instance Connect Endpoint
through Terraform module outputs.

The association crosses module boundaries and is not recognized by this
Checkov evaluation.

### CKV2_AWS_11 - VPC Flow Logs

Status: Accepted development trade-off.

VPC Flow Logs are intentionally deferred in the current development
environment due to cost considerations.

The architecture decision and consequences are documented in:

`docs/decisions/ADR-002-vpc-flow-logs.md`

This decision should be reconsidered for production environments.

## Terraform State Backend Exceptions

### CKV_AWS_144 - Cross-Region Replication

Status: Accepted development trade-off.

Cross-region replication is not enabled for the development Terraform
state bucket.

Bucket versioning provides recovery from accidental state overwrites or
deletions within the current region.

Cross-region disaster recovery should be reconsidered for production
state.

### CKV_AWS_18 - S3 Access Logging

Status: Accepted development trade-off.

Server access logging is not enabled for the development state bucket.

Enabling it would require additional logging storage and lifecycle
management that is not currently justified for this development
environment.

### CKV2_AWS_62 - S3 Event Notifications

Status: Not currently applicable.

No event-driven consumer exists for Terraform state changes.

Notifications should be introduced only if a defined monitoring or
automation requirement requires them.

### CKV_AWS_145 - KMS Encryption

Status: Accepted development trade-off.

The development state bucket explicitly uses SSE-S3 with AES256
encryption.

A customer-managed KMS key is not introduced in the current
cost-constrained environment.

KMS-based encryption and stronger key-access controls should be
reconsidered for production Terraform state.

## Policy

A Checkov finding may only be skipped when:

- the control is demonstrably not applicable to the resource;
- static analysis cannot correctly resolve the architecture; or
- an explicit engineering trade-off has been documented.

New findings must not be globally ignored simply to make CI succeed.
