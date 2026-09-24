# ADR-004: Remote Terraform State with Amazon S3

## Status

Accepted

## Context

The development environment initially used local Terraform state.

Local state is appropriate during early development, but it creates
limitations for recovery, collaboration, centralized storage, and state
locking.

The project already provisions a dedicated S3 bucket through an isolated
Terraform bootstrap configuration.

## Decision

The development environment will use the Amazon S3 Terraform backend.

The backend will use:

- A dedicated private S3 bucket.
- S3 bucket versioning.
- Server-side encryption.
- Public access blocking.
- BucketOwnerEnforced ownership controls.
- TLS-only access enforced by bucket policy.
- Native S3 state locking with `use_lockfile = true`.
- A state key of `environments/dev/terraform.tfstate`.

DynamoDB will not be used for state locking.

Backend-specific runtime configuration will be supplied through a local
`backend.hcl` file rather than hard-coded into the Terraform source.

The local backend configuration file will not be committed to Git.

## Consequences

Terraform state will be centrally stored in S3 rather than persisted as
the active state only on an engineer workstation.

S3 versioning provides recovery options for previous state versions.

Terraform operations that modify state will use native S3 locking to
reduce the risk of concurrent state modification.

Users running Terraform must have appropriate access to the state bucket
and lock object.

The bootstrap configuration that creates the state bucket remains
separate from the infrastructure configuration that consumes the
backend.
