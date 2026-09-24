# ADR-002: Defer VPC Flow Logs in the Initial Development Sandbox

## Status

Accepted - Temporary

## Context

Static security analysis recommends enabling VPC Flow Logs for all VPCs.

VPC Flow Logs require a logging destination such as CloudWatch Logs or
Amazon S3. These services may generate ingestion and storage costs when
network traffic is produced.

The initial development sandbox has a strict cost-minimization objective
and currently contains no workloads.

## Decision

VPC Flow Logs will not be enabled during the initial networking phase.

The Checkov CKV2_AWS_11 finding will remain visible instead of being
silently suppressed.

VPC Flow Logs will be implemented and evaluated during the observability
phase of the portfolio.

## Consequences

### Benefits

- Avoids unnecessary logging costs during the initial sandbox phase.
- Keeps the initial infrastructure minimal.
- Makes the accepted security trade-off explicit.
- Keeps the Checkov finding visible until it is actually resolved.

### Trade-offs

- Network flow telemetry is unavailable during this initial phase.
- The control must be revisited before treating the environment as
  production-like.
