#!/usr/bin/env bash

script_dir=$(dirname "$0")
base_dir=$(cd "${script_dir}"; pwd -P)

namespace="ngp"
environment="dev"

function print_usage() {
  printf "a build script for helm\n"
  printf '\t-h | --help\n'
  printf '\t-n | --namespace (string, optional, the namespace to deploy resources to)\n'
  printf '\t-e | --environment (string, optional, the name of the environment config to use during deployment)\n'
}

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
  -n | --namespace)
    namespace="$2"
    shift # past argument
    shift # past value
    ;;
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

if [[ -z "${namespace}" ]]; then
	print_help
	exit 1
fi

export CLOUDSDK_COMPUTE_REGION=$(cat "config/dev.${environment}.yaml" | grep CLOUDSDK_COMPUTE_REGION | cut -d ':' -f 2 | xargs)
export CLOUDSDK_CONTAINER_CLUSTER=$(cat "config/dev.${environment}.yaml"| grep CLOUDSDK_CONTAINER_CLUSTER | cut -d ':' -f 2 | xargs)
export GCLOUD_PROJECT=$(cat "config/dev.${environment}.yaml" | grep GCLOUD_PROJECT | cut -d ':' -f 2 | xargs)
export PROJECT_ID=$(cat "config/dev.${environment}.yaml" | grep GCLOUD_PROJECT | cut -d ':' -f 2 | xargs)
export LOCATION=$(cat "config/dev.${environment}.yaml" | grep CLOUDSDK_COMPUTE_REGION | cut -d ':' -f 2 | xargs)

if [[ -z $(helm list -n ngp --filter 'ngp-base' -o yaml | grep name) ]]; then
  /builder/entrypoint.sh install --atomic ngp-base ./charts/ngp-base
else
  /builder/entrypoint.sh upgrade --atomic ngp-base ./charts/ngp-base
fi

if [[ -z $(helm list -n ngp --filter 'dealsheet' -o yaml | grep name) ]]; then
  /builder/entrypoint.sh install -n ngp --atomic dealsheet-api ./charts/dealsheet-api
else
  /builder/entrypoint.sh upgrade -n ngp --atomic dealsheet-api ./charts/dealsheet-api
fi

if [[ -z $(helm list -n ngp --filter 'graphql' -o yaml | grep name) ]]; then
  /builder/entrypoint.sh install -n ngp --atomic graphql-mesh ./charts/graphql-mesh
else
  /builder/entrypoint.sh upgrade -n ngp --atomic graphql-mesh ./charts/graphql-mesh
fi
