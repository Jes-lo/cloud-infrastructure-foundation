# Ansible Linux Baseline Validation

## Objective

Validate that a private Amazon Linux workload can be configured securely
and reproducibly with Ansible through EC2 Instance Connect Endpoint.

## Access Model

Ansible connects as:

`ec2-user`

Administrative tasks use Ansible privilege escalation through `sudo`.

Direct SSH login as root is not used.

The connection path is:

Ansible
→ temporary SSH key
→ EC2 Instance Connect
→ EC2 Instance Connect Endpoint
→ private EC2 instance

The workload has no public IPv4 address.

## Connectivity Validation

Before configuration was applied:

- EC2 system status: `ok`
- EC2 instance status: `ok`
- EICE state: `create-complete`
- Ansible connectivity test: `pong`
- Privilege escalation validation: `whoami` returned `root`

## Existing System State

`chronyd` was already:

- enabled
- active

The existing SSH configuration included:

`/etc/ssh/sshd_config.d/*.conf`

Amazon Linux also provided:

`/etc/ssh/sshd_config.d/50-redhat.conf`

The effective SSH configuration before the baseline included:

- MaxAuthTries: 6
- ClientAliveInterval: 0
- ClientAliveCountMax: 3
- PermitRootLogin: without-password
- PasswordAuthentication: no
- KbdInteractiveAuthentication: no
- X11Forwarding: yes
- PermitEmptyPasswords: no

## Baseline Configuration

The Ansible role manages:

- chronyd service state
- SSH configuration directory ownership and permissions
- SSH hardening configuration

The managed SSH configuration is:

`/etc/ssh/sshd_config.d/00-cloud-infrastructure-hardening.conf`

The configured values are:

- PermitRootLogin no
- PasswordAuthentication no
- KbdInteractiveAuthentication no
- PermitEmptyPasswords no
- X11Forwarding no
- MaxAuthTries 3
- ClientAliveInterval 300
- ClientAliveCountMax 2

The configuration file is owned by root and uses mode `0600`.

## Safe SSH Reload

The Ansible handler validates the SSH daemon configuration with:

`/usr/sbin/sshd -t`

before reloading `sshd`.

If validation fails, the reload does not proceed.

## Post-Change Validation

After the baseline was applied:

- Ansible connectivity through EICE still returned `pong`.
- SSH configuration validation succeeded.
- The effective SSH configuration reported:

  - MaxAuthTries: 3
  - ClientAliveInterval: 300
  - ClientAliveCountMax: 2
  - PermitRootLogin: no
  - PasswordAuthentication: no
  - KbdInteractiveAuthentication: no
  - X11Forwarding: no
  - PermitEmptyPasswords: no

## Idempotence

The playbook was executed a second time after successful configuration.

Result:

`changed=0`

This confirms that the baseline converges on the desired state without
making unnecessary changes on subsequent executions.

## Terraform Integration

The Ansible runtime inventory is not committed to Git.

A repository script reads the current workload instance ID from the
Terraform output:

`workload_instance_id`

and generates the local Ansible inventory.

This prevents an ephemeral EC2 instance ID from being hardcoded into the
version-controlled configuration.
