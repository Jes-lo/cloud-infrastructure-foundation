# ADR-003: Private Administrative Access with EC2 Instance Connect Endpoint

## Status

Accepted

## Context

The development workload runs on an Amazon EC2 instance located in a
private subnet.

The project requires administrative access for Linux configuration and
Ansible automation while maintaining the following constraints:

- No public IPv4 address on the workload.
- No SSH exposure to the Internet.
- No permanent EC2 key pair stored for administrative access.
- No bastion host unless operationally justified.
- No NAT Gateway for administrative connectivity.
- Cloud cost should remain minimal.
- Access should integrate with AWS IAM and temporary credentials.

## Decision

Administrative access will use Amazon EC2 Instance Connect Endpoint
(EICE).

The endpoint is deployed in the private subnet and communicates with the
workload using security-group-to-security-group rules.

The access path is:

WSL / administrative workstation
→ AWS IAM authentication
→ EC2 Instance Connect Endpoint
→ private TCP/22
→ EC2 workload

The workload security group permits TCP/22 only from the EICE security
group.

The EICE security group permits TCP/22 only to the workload security
group.

The EC2 instance does not have a public IPv4 address.

SSH authentication uses temporary keys published through EC2 Instance
Connect rather than a persistent EC2 key pair.

## Ansible Integration

Ansible connects through EICE using the AWS CLI as an SSH ProxyCommand.

The runtime inventory is generated from Terraform outputs rather than
storing an EC2 instance ID in source control.

The local AWS profile and region are inherited from the operator's
environment and are not hardcoded into the repository.

## Alternatives Considered

### Public SSH access

Rejected because it would require a public IP and expose SSH to an
Internet-routable path.

### Bastion host

Not selected because it would introduce an additional EC2 workload,
operational overhead, patching requirements, and cost for the current
development environment.

### NAT Gateway

Not selected because NAT is not required for inbound administrative
access and would introduce unnecessary recurring cost.

### AWS Systems Manager Session Manager

Considered a valid alternative, but the current private instance would
require an outbound path or additional VPC endpoints for Systems Manager
services. EICE satisfies the current administrative-access requirement
with a smaller development architecture.

## Consequences

### Positive

- Workload remains private.
- No public SSH exposure.
- No permanent EC2 SSH key pair is required.
- Access integrates with AWS IAM.
- Security groups use resource relationships instead of broad CIDR
  ingress rules.
- Ansible can manage the private workload.
- The design avoids a dedicated bastion host.

### Trade-offs

- Administrative access depends on AWS IAM and EICE availability.
- Temporary SSH keys must be published before Ansible connections.
- The current workflow requires AWS CLI authentication on the
  administrative workstation.
- Additional automation is useful to simplify temporary-key handling.
