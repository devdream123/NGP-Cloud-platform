#!/usr/bin/env bash

################
## This script automates the step documented in this ASM guide
## https://cloud.google.com/service-mesh/docs/managed/enable-managed-anthos-service-mesh-optional-features#enable_cloud_tracing
################

echo "Starting enable-service-mesh-features.sh"

set -o errexit   # abort on nonzero exitstatus
set -o pipefail  # don't hide errors within pipes
set -o nounset   # abort on unbound variable

function print_usage() {
  printf "A script to enable service mesh features.\n"
  printf "Environment name is required i.e. dev, uat, prd."
  printf '\t-h | --help\n'
  printf '\t-e | --environment (string, optional, the name of the environment to use for applying the mesh features)\n'
}

if [ ! "$1" ]; then
  print_usage
  exit 1
fi

environment=$1
source "${BASE_DIR}"/export-env-variables.sh "${environment}"

for cluster in ${CLOUDSDK_CONTAINER_CLUSTERS}; do

  cluster_context="gke_${GCLOUD_PROJECT}_${CLOUDSDK_COMPUTE_REGION}_${cluster}"
  kubectl config use-context "${cluster_context}"

  echo "Applying the Istio control plane configuration in ${environment} environment for ${cluster} cluster."
  kubectl apply -f "./outputs/${environment}/${cluster}/istio-control-plane/templates/" --namespace "${ASM_CONTROL_PLANE_NAMESPACE}"

done
