#!/usr/bin/env bash

set -e

script_dir=$(dirname "$0")
base_dir=$(cd "${script_dir}"; pwd -P)

function print_usage() {
  printf "a build script for helm\n"
  printf '\t-h | --help\n'
  printf '\t-e | --environment (string, optional, the name of the environment config to use during deployment)\n'
}

if [ ! "$1" ]; then
	print_usage
	exit 1
fi

environment=$1

echo "using base dir: ${base_dir}"
echo "deploying to environment: ${environment}"

if [[ -d "/root/.local/share/helm/plugins" ]]; then
  mkdir -p /builder/home/.local/share/helm
  cp -r /root/.local/share/helm/plugins /builder/home/.local/share/helm/plugins
fi

CLOUDSDK_COMPUTE_REGION=$(yq eval '.env.CLOUDSDK_COMPUTE_REGION' "${base_dir}/../config/${environment}.env.yaml")
CLOUDSDK_CONTAINER_CLUSTERS=$(yq eval '.env.CLOUDSDK_CONTAINER_CLUSTERS[]' "${base_dir}/../config/${environment}.env.yaml")
GCLOUD_PROJECT=$(yq eval '.env.GCLOUD_PROJECT' "${base_dir}/../config/${environment}.env.yaml")

  for cluster in $CLOUDSDK_CONTAINER_CLUSTERS; do
    export CLUSTER_NAME="$cluster"
    echo "Running: gcloud container clusters get-credentials --project=\"$GCLOUD_PROJECT\" --region=\"$CLOUDSDK_COMPUTE_REGION\" \"$CLUSTER_NAME\""
    gcloud container clusters get-credentials --project="$GCLOUD_PROJECT" --region="$CLOUDSDK_COMPUTE_REGION" "$CLUSTER_NAME"

    bash ${base_dir}/inject-cluster-secrets.sh $environment $cluster

    if [[  "${environment}" == "uat" ]]; then
      
      echo "${environment}"
      echo "Deploying Istio gateway to cluster: ${CLUSTER_NAME} in ${environment} environment" 
      helmfile -f "${base_dir}/../helmfile-istio-gateway.yaml" --environment "${environment}" apply \
      --skip-deps \
      --concurrency 1
      
    fi

    echo "Deploying services to cluster: ${CLUSTER_NAME} in ${environment} environment"
    helmfile -f  "${base_dir}/../helmfile.yaml" --environment "${environment}" apply \
      --skip-deps \
      --concurrency 1
      
  done
