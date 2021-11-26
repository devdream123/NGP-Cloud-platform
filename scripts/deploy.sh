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

export CLOUDSDK_COMPUTE_REGION=$(cat "${base_dir}/../config/${environment}.env.yaml" | grep CLOUDSDK_COMPUTE_REGION | cut -d ':' -f 2 | xargs)
export CLOUDSDK_CONTAINER_CLUSTER=$(cat "${base_dir}/../config/${environment}.env.yaml"| grep CLOUDSDK_CONTAINER_CLUSTER | cut -d ':' -f 2 | xargs)
export GCLOUD_PROJECT=$(cat "${base_dir}/../config/${environment}.env.yaml" | grep GCLOUD_PROJECT | cut -d ':' -f 2 | xargs)
export PROJECT_ID=$(cat "${base_dir}/../config/${environment}.env.yaml" | grep GCLOUD_PROJECT | cut -d ':' -f 2 | xargs)
export LOCATION=$(cat "${base_dir}/../config/${environment}.env.yaml" | grep CLOUDSDK_COMPUTE_REGION | cut -d ':' -f 2 | xargs)

if [[ -d "/root/.local/share/helm/plugins" ]]; then
  mkdir -p /builder/home/.local/share/helm
  cp -r /root/.local/share/helm/plugins /builder/home/.local/share/helm/plugins
fi

echo "Running: gcloud container clusters get-credentials --project=\"$PROJECT_ID\" --region=\"$CLOUDSDK_COMPUTE_REGION\" \"$CLOUDSDK_CONTAINER_CLUSTER\""
gcloud container clusters get-credentials --project="$PROJECT_ID" --region="$CLOUDSDK_COMPUTE_REGION" "$CLOUDSDK_CONTAINER_CLUSTER" || exit

helmfile --environment "${environment}" apply \
  --skip-deps \
  --concurrency 1
