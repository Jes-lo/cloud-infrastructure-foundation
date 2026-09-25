#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

TF_STATE_BACKEND="${REPO_ROOT}/terraform/bootstrap/state-backend"
TF_OPERATOR_IAM="${REPO_ROOT}/terraform/bootstrap/operator-iam"
TF_DEV="${REPO_ROOT}/terraform/environments/dev"

TEMP_TF_DATA_ROOT="$(mktemp -d)"

cleanup() {
  rm -rf "${TEMP_TF_DATA_ROOT}"
}

trap cleanup EXIT

validate_terraform_directory() {
  local name="$1"
  local directory="$2"
  local tf_data_dir="${TEMP_TF_DATA_ROOT}/${name}"

  mkdir -p "${tf_data_dir}"

  echo
  echo "==> Validating Terraform stack: ${name}"

  echo "    -> terraform init -backend=false"
  TF_DATA_DIR="${tf_data_dir}" \
    terraform -chdir="${directory}" init \
      -backend=false \
      -input=false

  echo "    -> terraform validate"
  TF_DATA_DIR="${tf_data_dir}" \
    terraform -chdir="${directory}" validate

  echo "    -> tflint"
  tflint --chdir="${directory}"
}

echo "==> Checking Terraform formatting"
terraform -chdir="${REPO_ROOT}" fmt -check -recursive

validate_terraform_directory \
  "state-backend" \
  "${TF_STATE_BACKEND}"

validate_terraform_directory \
  "operator-iam" \
  "${TF_OPERATOR_IAM}"

validate_terraform_directory \
  "dev" \
  "${TF_DEV}"

echo
echo "==> Running Checkov"
checkov \
  --directory "${REPO_ROOT}/terraform" \
  --framework terraform \
  --quiet

echo
echo "==> Infrastructure validation completed successfully"
