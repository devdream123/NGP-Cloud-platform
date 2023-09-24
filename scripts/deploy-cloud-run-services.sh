#!/usr/bin/env bash

echo "Starting deploy-cloud-run-services.sh"

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

if [[ -z ${CLOUD_RUN_SERVICES} ]]; then 
 echo "There is no Cloud Run service in ${environment} environment to deploy.."
 echo "Exiting the script with success status code..."
 exit 0
fi

for cloud_run_service in ${CLOUD_RUN_SERVICES}; do

  chart_output_dir="${BASE_DIR}/../outputs/${environment}"
  service_chart_dir="${BASE_DIR}/../charts/${cloud_run_service}"
  
  echo "Rendering the template of ${cloud_run_service} Cloud Run service in ${environment}"
  helm template "${service_chart_dir}" \
    --values="${service_chart_dir}/values-${GCLOUD_PROJECT}.yaml" \
    --output-dir="${chart_output_dir}"

  gcloud run services replace \
    "${chart_output_dir}/${cloud_run_service}/templates/service.yaml" \
    --region="${CLOUDSDK_COMPUTE_REGION}" \
    --project="${GCLOUD_PROJECT}" \
    --async

done