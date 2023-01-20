#!/usr/bin/env bash
set -e

function print_usage() {
  printf "A script to install canary helm charts.\n"
  printf "Environment name is required i.e. tst, dev, uat, prd."
  printf '\t-h | --help\n'
  printf '\t-e | --environment (string, optional, the name of the environment config to use during deployment)\n'
}

if [ ! "$1" ]; then
	print_usage
	exit 1
fi

environment=$1
source ${BASE_DIR}/export-env-variables.sh $environment

for cluster in ${CLOUDSDK_CONTAINER_CLUSTERS}; do
  
  export CLUSTER_NAME="$cluster"
  cluster_context="gke_${GCLOUD_PROJECT}_${CLOUDSDK_COMPUTE_REGION}_${cluster}"
  kubectl config use-context "${cluster_context}"
  
  echo "Installing 'kube state metrics' chart to cluster: ${cluster} in ${environment} environment"
  helmfile -f  "${BASE_DIR}/../helmfile-kube-state-metrics.yaml" --environment "${environment}" apply \
    --skip-deps \
    --concurrency 1

done
