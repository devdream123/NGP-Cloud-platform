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

deployments=(
  "calendar-api"
  "dealsheet-api"
  "eventschedule-api"
  "forecast-api"
  "graphql-mesh"
  "hierarchy-api"
  "istio-control-plane"
  "istio"
  "istio-gateway"
  "pgr-api"
  "custom-groups-api"
  "pmr-sync"
  "web-proxy-ds"
)

echo "Beginning Helm Template checks for Kubernetes clusters deployments..."

for deployment in "${deployments[@]}"; do

  echo "Deployment: ${deployment}"

  for environment in "${environments[@]}"; do

    echo "Environment: ${environment}"
    source "${BASE_DIR}/export-env-variables.sh" "${environment}"

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
    for cloud_run_service in ${CLOUD_RUN_SERVICES}; do

      echo "Checking Cloud Run services chart for ${cloud_run_service} in ${environment} environment with values from ./charts/${cloud_run_service}/values-${GCLOUD_PROJECT}.yaml"
      helm template "${BASE_DIR}/../charts/${cloud_run_service}" --output-dir "${BASE_DIR}/../outputs/${environment}/${cloud_run_service}" --values "${BASE_DIR}/../charts/${cloud_run_service}/values-${GCLOUD_PROJECT}.yaml"

    done

  done

