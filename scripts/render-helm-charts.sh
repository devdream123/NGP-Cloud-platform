#!/usr/bin/env bash

echo "Starting render-helm-charts.sh"

set -o errexit   # abort on nonzero exitstatus
set -o pipefail  # don't hide errors within pipes

script_dir=$(dirname "$0")
BASE_DIR=$(cd "${script_dir}"; pwd -P)
export BASE_DIR

if [ "$1" ]; then
  environments=("$1")
 else
  environments=("tst" "dev" "uat" "prd")
fi

echo "Beginning Helm Template checks for Kubernetes clusters deployments..."

for environment in "${environments[@]}"; do

  source "${BASE_DIR}/export-env-variables.sh" "${environment}"
  for deployment in ${KUBERNETES_CLUSTER_DEPLOYMENTS}; do

    # Check helm charts for Kubernetes cluster deployments
    for cluster in ${CLOUDSDK_CONTAINER_CLUSTERS}; do

      echo "Checking services chart for Kubernetes deployment : ${deployment} in ${environment} environment with values from ./charts/${deployment}/values-${cluster}.yaml"
      helm template "${BASE_DIR}/../charts/${deployment}" --output-dir "${BASE_DIR}/../outputs/${environment}/${cluster}" --values "${BASE_DIR}/../charts/${deployment}/values-${cluster}.yaml"

    done

  done

done

echo "Beginning Helm Template checks for Cloud Run services..."

  for environment in "${environments[@]}"; do

    echo "Environment: ${environment}"
    source "${BASE_DIR}/export-env-variables.sh" "${environment}"

    # Check helm charts for Cloud Run services
    for cloud_run_service in "${CLOUD_RUN_SERVICES[@]}"; do

      service_name=$(echo "${cloud_run_service}" | yq .name)
      echo "Checking Cloud Run services chart for ${service_name} in ${environment} environment with values from ./charts/${service_name}/values-${GCLOUD_PROJECT}.yaml"
      helm template "${BASE_DIR}/../charts/${service_name}" --output-dir "${BASE_DIR}/../outputs/${environment}/${service_name}" --values "${BASE_DIR}/../charts/${service_name}/values-${GCLOUD_PROJECT}.yaml"

    done

  done
