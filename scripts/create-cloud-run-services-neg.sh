#!/usr/bin/env bash

echo "Starting create-cloud-run-services-neg.sh"

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

echo "using base dir: ${BASE_DIR}"
source "${BASE_DIR}"/export-env-variables.sh "${environment}"

if [[ ${#CLOUD_RUN_SERVICES[@]} -eq 0 ]]; then
 echo "There is no Cloud Run service in ${environment} environment to create network endpoint group for.."
 echo "Exiting the script with success status code..."
 exit 0
fi

for cloud_run_service in "${CLOUD_RUN_SERVICES[@]}"; do

  create_neg=$(echo "${cloud_run_service}" | yq .createNEG)
  service_name=$(echo "${cloud_run_service}" | yq .name)
  network_endpoint_group_name="ngp-${environment}-${service_name}-neg"

  if [[ "${create_neg}" == false ]]; then
    continue;
  fi

  if [[ $(gcloud compute network-endpoint-groups describe \
                  "${network_endpoint_group_name}" \
                  --region="${CLOUDSDK_COMPUTE_REGION}" \
                  --project="${GCLOUD_PROJECT}") \
      ]]; then

        echo "Network endpoint group for the Cloud Run service: ${service_name} already exists"
        echo "Continuing with other services..."
        continue;
  fi 

  info_message="Checking the health status of the service: ${service_name} before"
  info_message+=" creating a network endpoint group for it"
  echo "${info_message}"

  source "${BASE_DIR}"/check-cloud-run-service-health.sh "${environment}" "${service_name}"

  service_health=$?

  if [[ "${service_health}" -gt 0 ]]; then
     exit "${service_health}"
  fi

  echo "Creating a network endpoint group for the Cloud Run service: ${service_name}..."

  gcloud compute network-endpoint-groups create \
    "${network_endpoint_group_name}" \
    --network-endpoint-type=serverless \
    --cloud-run-service="${service_name}" \
    --region="${CLOUDSDK_COMPUTE_REGION}" \
    --project="${GCLOUD_PROJECT}"

done

echo "Completed the exeuction of create-cloud-run-services-neg.sh script in ${environment} environment."