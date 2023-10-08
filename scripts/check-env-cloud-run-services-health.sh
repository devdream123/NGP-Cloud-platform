#!/usr/bin/env bash

echo "Starting check-env-cloud-run-services-health.sh"

set -o errexit   # abort on nonzero exitstatus
set -o pipefail  # don't hide errors within pipes
set -o nounset   # abort on unbound variable

function print_usage() {
  printf "Environment name is required i.e. tst, dev, uat, prd."
  printf '\t-h | --help\n'
  printf '\t-e | --environment (string, the name of the environment config to use during deployment)\n'
}

function check_cloud_run_deployment_status() {

  deployment_status=$(gcloud run services describe "${1}" \
    --region="${2}" \
    --project="${3}" \
    --format=yaml \
    | yq '.status.conditions[] | select(.type == "Ready") | .status')

  echo "${deployment_status}"

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
 echo "There is no Cloud Run service in ${environment} environment to check its deployment status.."
 echo "Exiting the script with success status code..."
 exit 0
fi

for cloud_run_service in "${CLOUD_RUN_SERVICES[@]}"; do

  service_name=$(echo "${cloud_run_service}" | yq .name)
  check_deployment=$(echo "${cloud_run_service}" | yq .checkDeployment)
  
  if [[ "${check_deployment}" == false ]]; then
    info_message="Checking the deployment status of the Cloud Run service: ${service_name}"
    info_message+=" in ${environment} environment is not required. Continuing with other services.."
    echo "$info_message"
    continue;
  fi

  source "${BASE_DIR}"/check-cloud-run-service-health.sh "${environment}" "${service_name}"
  
  service_health=$?
  if [[ "${service_health}" -gt 0 ]]; then
    exit "${service_health}"
  fi

done

echo "Deployment of the Cloud Run services in ${environment} environment is completed now..."
echo "Exiting the script with success status code..."
exit 0