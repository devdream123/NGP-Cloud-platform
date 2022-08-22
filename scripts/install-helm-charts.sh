#!/usr/bin/env bash

set -e

function print_usage() {
  printf "a deployment script for helm charts.\n"
  printf "Environment name is required i.e. dev, uat, prd."
  printf '\t-h | --help\n'
  printf '\t-e | --environment (string, optional, the name of the environment config to use during deployment)\n'
}

if [ ! "$1" ]; then
	print_usage
	exit 1
fi

# Use the GCloud Auth Plugin
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

environment=$1
source ${BASE_DIR}/export-env-variables.sh $environment

echo "using base dir: ${BASE_DIR}"
echo "deploying to environment: ${environment}"

if [[ -d "/root/.local/share/helm/plugins" ]]; then
  mkdir -p /builder/home/.local/share/helm
  cp -r /root/.local/share/helm/plugins /builder/home/.local/share/helm/plugins
fi

  for cluster in ${CLOUDSDK_CONTAINER_CLUSTERS}; do
    
    export CLUSTER_NAME="$cluster"
    echo "Running: gcloud container clusters get-credentials --project=\"$GCLOUD_PROJECT\" --region=\"${CLOUDSDK_COMPUTE_REGION}\" \"${cluster}\""
    gcloud container clusters get-credentials --project="${GCLOUD_PROJECT}" --region="${CLOUDSDK_COMPUTE_REGION}" "${cluster}"
    
    echo "Substituting secrets' values for cluster: ${cluster}"
    bash ${BASE_DIR}/inject-cluster-secrets.sh ${environment} ${cluster}
      
    echo "Installing Istio gateway chart to cluster: ${cluster} in ${environment} environment" 
    helmfile -f "${BASE_DIR}/../helmfile-istio-gateway.yaml" --environment "${environment}" apply \
    --skip-deps \
    --concurrency 1

    echo "Installing back-end services charts to cluster: ${cluster} in ${environment} environment"
    helmfile -f  "${BASE_DIR}/../helmfile.yaml" --environment "${environment}" apply \
      --skip-deps \
      --concurrency 1

  done 