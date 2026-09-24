#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_ENV="${REPO_ROOT}/terraform/environments/dev"

echo "==> Checking Terraform formatting"
terraform -chdir="${REPO_ROOT}" fmt -check -recursive

echo "==> Initializing Terraform without backend"
terraform -chdir="${TF_ENV}" init -backend=false -input=false

echo "==> Validating Terraform configuration"
terraform -chdir="${TF_ENV}" validate

echo "==> Running TFLint"
cd "${REPO_ROOT}"
tflint --recursive

echo "==> Running Checkov"
checkov \
  --directory "${REPO_ROOT}/terraform" \
  --framework terraform \
  --quiet

echo "==> Infrastructure validation completed successfully"
