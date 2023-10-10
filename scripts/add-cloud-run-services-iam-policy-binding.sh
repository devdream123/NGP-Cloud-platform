#!/usr/bin/env bash

echo "Starting add-cloud-run-services-iam-policy-binding.sh"

set -o errexit   # abort on nonzero exitstatus
set -o pipefail  # don't hide errors within pipes
set -o nounset   # abort on unbound variable

function print_usage() {
  printf "Environment name is required i.e. dev, uat, prd."
  printf '\t-h | --help\n'
  printf '\t-e | --environment (string, the name of the environment config to use during deployment)\n'
}

if [ ! "$1" ]; then
  print_usage
  exit 1
fi

script_dir=$(dirname "$0")

BASE_DIR=$(cd "${script_dir}"; pwd -P)
export BASE_DIR
environment=$1

source "${BASE_DIR}"/export-env-variables.sh "${environment}"

iam_principal="serviceAccount:service-${GCLOUD_PROJECT_NUMBER}@gcp-sa-iap.iam.gserviceaccount.com"
iam_role="roles/run.invoker"

for cloud_run_service in "${CLOUD_RUN_SERVICES[@]}"; do

  service_name=$(echo "${cloud_run_service}" | yq .name)
  echo "Adding IAM policy binding for the Cloud Run service: ${service_name} in ${environment} environment."

  gcloud run services add-iam-policy-binding "${service_name}" \
         --member="${iam_principal}" \
         --role="${iam_role}" \
         --region="${CLOUDSDK_COMPUTE_REGION}" \
         --project="${GCLOUD_PROJECT}"

done