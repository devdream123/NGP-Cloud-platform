#!/usr/bin/env bash

script_dir=$(dirname "$0")
base_dir=$(cd "${script_dir}"; pwd -P)

environment="dev"

function print_usage() {
  printf "a build script for helm\n"
  printf '\t-h | --help\n'
  printf '\t-e | --environment (string, optional, the name of the environment config to use during deployment)\n'
}

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
  -e | --environment)
    environment="$2"
    shift # past argument
    shift # past value
    ;;
  *) # unknown option
    print_usage
    shift
    ;;
  esac
done

if [[ -z "${environment}" ]]; then
  print_usage
  exit 1
fi

echo "using base dir: ${base_dir}"
echo "deploying to environment: ${environment}"

CLOUDSDK_COMPUTE_REGION=$(yq eval '.env.CLOUDSDK_COMPUTE_REGION' "${base_dir}/../config/${environment}.env.yaml")
CLOUDSDK_CONTAINER_CLUSTERS=$(yq eval '.env.CLOUDSDK_CONTAINER_CLUSTERS[]' "${base_dir}/../config/${environment}.env.yaml")
GCLOUD_PROJECT=$(yq eval '.env.GCLOUD_PROJECT' "${base_dir}/../config/${environment}.env.yaml")

if [[ -d "/root/.local/share/helm/plugins" ]]; then
  mkdir -p /builder/home/.local/share/helm
  cp -r /root/.local/share/helm/plugins /builder/home/.local/share/helm/plugins
fi

for cluster in $CLOUDSDK_CONTAINER_CLUSTERS; do
  export CLUSTER_NAME="$cluster"
  echo "Running: gcloud container clusters get-credentials --project=\"$GCLOUD_PROJECT\" --region=\"$CLOUDSDK_COMPUTE_REGION\" \"$CLUSTER_NAME\""
  gcloud container clusters get-credentials --project="$GCLOUD_PROJECT" --region="$CLOUDSDK_COMPUTE_REGION" "$CLUSTER_NAME" || exit

  echo "Deploying to cluster: $CLUSTER_NAME"
  helmfile --environment "${environment}" apply \
    --skip-deps \
    --concurrency 1
done
