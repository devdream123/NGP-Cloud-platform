#!/usr/bin/env bash

set -e

function print_usage() {
  printf "A script to export environment specific variables.\n"
  printf "Environment name is required i.e. dev, uat, prd."
  printf '\t-h | --help\n'
  printf '\t-e | --environment (string, optional, the name of the environment config to use during deployment)\n'
}

if [ ! "$1" ]; then
	print_usage
	exit 1
fi

environment=$1

export CLOUDSDK_COMPUTE_REGION=$(yq eval '.env.CLOUDSDK_COMPUTE_REGION' "${BASE_DIR}/../config/${environment}.env.yaml")
export CLOUDSDK_CONTAINER_CLUSTERS=$(yq eval '.env.CLOUDSDK_CONTAINER_CLUSTERS[]' "${BASE_DIR}/../config/${environment}.env.yaml")
export GCLOUD_PROJECT=$(yq eval '.env.GCLOUD_PROJECT' "${BASE_DIR}/../config/${environment}.env.yaml")
export HIERARCHY_SERVICE_NAMESPACE=$(yq eval '.hierarchy.namespace' "${BASE_DIR}/../values/${environment}.yaml")
export GRAPHQL_SERVICE_NAMESPACE=$(yq eval '.graphql.namespace' "${BASE_DIR}/../values/${environment}.yaml")