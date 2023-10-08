#!/usr/bin/env bash

echo "Starting check-cloud-run-service-health.sh"

set -o errexit   # abort on nonzero exitstatus
set -o pipefail  # don't hide errors within pipes
set -o nounset   # abort on unbound variable

function print_usage() {
  printf "Environment name is required i.e. tst, dev, uat, prd."
  printf "Cloud Run service name is required"
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

if [[ ! "$1" || ! "$2" ]]; then
  print_usage
  exit 1
fi

script_dir=$(dirname "$0")
BASE_DIR=$(cd "${script_dir}"; pwd -P)
export BASE_DIR
environment=$1
service_name=$2

echo "using base dir: ${BASE_DIR}"
source "${BASE_DIR}"/export-env-variables.sh "${environment}"

echo "Checking the deployment status of the Cloud Run service: ${service_name} in ${environment} environment..."
deployment_status=$(check_cloud_run_deployment_status "${service_name}" \
                      "${CLOUDSDK_COMPUTE_REGION}" \
                      "${GCLOUD_PROJECT}")

recheck_attempts=3
wait_seconds=15

while [[ "${deployment_status}" == "Unknown" &&  ${recheck_attempts} -gt 0 ]]; do

  echo "Deployment status of the Cloud Run service: ${service_name} in ${environment} environment is unknown..."
  echo "Waiting ${wait_seconds} seconds before checking again..."
  echo "${recheck_attempts} retry attempts remaining..."
  sleep ${wait_seconds}

  echo "Checking the deployment status of the Cloud Run service: ${service_name} in ${environment} environment..."
  deployment_status=$(check_cloud_run_deployment_status "${service_name}" \
                      "${CLOUDSDK_COMPUTE_REGION}" \
                    "${GCLOUD_PROJECT}")

  wait_seconds=$((wait_seconds * recheck_attempts))
  recheck_attempts=$((recheck_attempts-1))

done

if [[ -z "${deployment_status}" ]]; then
  error_message="Script was not able to get the status of Cloud Run service: ${service_name}"
  error_message+=" in ${environment} environment. An error occured..."
  error_message+="Exiting the script with error status code..."
  echo "$error_message"
  return 1
fi

if [[ "${deployment_status}" == "False" ]]; then
  error_message="Deployment of the Cloud Run service ${service_name} "
  error_message+="in ${environment} environment is unhealthy..."
  error_message+="Exiting the script with error status code..."
  echo "${error_message}"
  return 1
fi

if [[ "${deployment_status}" == "Unknown" ]]; then
  error_message="Deployment of the Cloud Run service ${service_name} "
  error_message+="in ${environment} environment is still unknown after 3 checks..."
  error_message+="Exiting the script with error status code..."
  echo "${error_message}"
  return 1
fi

if [[ "${deployment_status}" == "True" ]]; then
  info_message="Deployment of the Cloud Run service ${service_name} "
  info_message+="in ${environment} environment is ready..."
  echo "${info_message}"
  return 0
fi
