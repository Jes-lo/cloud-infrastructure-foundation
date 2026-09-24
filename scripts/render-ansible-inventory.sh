#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${REPO_ROOT}/terraform/environments/dev"
INVENTORY="${REPO_ROOT}/ansible/inventories/dev/hosts.yml"

INSTANCE_ID="$(terraform -chdir="${TF_DIR}" output -raw workload_instance_id)"

if [[ -z "${INSTANCE_ID}" ]]; then
  echo "ERROR: Terraform did not return workload_instance_id." >&2
  exit 1
fi

cat > "${INVENTORY}" <<EOF
---
all:
  children:
    workload:
      hosts:
        dev-workload:
          ansible_host: ${INSTANCE_ID}
          ansible_user: ec2-user
          ansible_python_interpreter: /usr/bin/python3
          ansible_ssh_common_args: >-
            -o ProxyCommand="aws ec2-instance-connect open-tunnel --instance-id %h"
            -o StrictHostKeyChecking=accept-new
EOF

echo "Generated Ansible inventory:"
echo "  ${INVENTORY}"
echo "Instance:"
echo "  ${INSTANCE_ID}"
