#!/usr/bin/env bash

echo "Starting check-cloud-run-services-deployment.sh"

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
    --project="${3}"  --format=yaml \
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

if [[ -z ${CLOUD_RUN_SERVICES} ]]; then 
 echo "There is no Cloud Run service in ${environment} environment to check its deployment status.."
 echo "Exiting the script  with success status code..."
 exit 0
fi

for cloud_run_service in ${CLOUD_RUN_SERVICES}; do

  echo "Checking the deployment status of the Cloud Run service: ${cloud_run_service} in ${environment} environment..."
  deployment_status=$(check_cloud_run_deployment_status "${cloud_run_service}" \
                        "${CLOUDSDK_COMPUTE_REGION}" \
                        "${GCLOUD_PROJECT}")
  recheck_attempts=3
  wait_seconds=15

  while [[ "${deployment_status}" == "Unknown" &&  ${recheck_attempts} -gt 0 ]]; do

    echo "Deployment status of the Cloud Run service: ${cloud_run_service} in ${environment} environment is unknown..."
    echo "Waiting ${wait_seconds} seconds before checking again..."
    echo "${recheck_attempts} retry attempts remaining..."
    sleep ${wait_seconds}

    echo "Checking the deployment status of the Cloud Run service: ${cloud_run_service} in ${environment} environment..."
    deployment_status=$(check_cloud_run_deployment_status "${cloud_run_service}" \
                        "${CLOUDSDK_COMPUTE_REGION}" \
                      "${GCLOUD_PROJECT}")

    wait_seconds=$((wait_seconds * recheck_attempts))
    recheck_attempts=$((recheck_attempts-1))

  done

  if [[ "${deployment_status}" == "True" ]]; then
    error_message="Deployment of the Cloud Run service ${cloud_run_service} "
    error_message+="in ${environment} environment is ready..."
    echo "${error_message}"
    echo "Continue with checking the deployment status of other services.."
    continue;
  fi

  if [[ "${deployment_status}" == "False" ]]; then
    error_message="Deployment of the Cloud Run service ${cloud_run_service} "
    error_message+="in ${environment} environment is unhealthy..."
    echo "${error_message}"
    echo "Exiting the script with error status code..."
    exit 1
  fi

  if [[ "${deployment_status}" == "Unknown" ]]; then
    error_message="Deployment of the Cloud Run service ${cloud_run_service} "
    error_message+="in ${environment} environment is still unknown after 3 checks..."
    echo "${error_message}"
    echo "Exiting the script with error status code..."
    exit 1
  fi

done

echo "Deployment of the Cloud Run services in all the environments is completed now..."
echo "Exiting the script with success status code..."
exit 0