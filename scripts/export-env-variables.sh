#!/usr/bin/env bash

echo "Starting export-env-variables.sh"

set -o errexit   # abort on nonzero exitstatus
set -o pipefail  # don't hide errors within pipes
set -o nounset   # abort on unbound variable

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

export USE_GKE_GCLOUD_AUTH_PLUGIN=True
CLOUDSDK_COMPUTE_REGION=$(yq eval '.env.CLOUDSDK_COMPUTE_REGION' "${BASE_DIR}/../config/${environment}.env.yaml")
export CLOUDSDK_COMPUTE_REGION
CLOUDSDK_CONTAINER_CLUSTERS=$(yq eval '.env.CLOUDSDK_CONTAINER_CLUSTERS[]' "${BASE_DIR}/../config/${environment}.env.yaml")
export CLOUDSDK_CONTAINER_CLUSTERS
KUBERNETES_CLUSTER_DEPLOYMENTS=$(yq eval '.env.KUBERNETES_CLUSTER_DEPLOYMENTS[]' "${BASE_DIR}/../config/${environment}.env.yaml")
export KUBERNETES_CLUSTER_DEPLOYMENTS
readarray CLOUD_RUN_SERVICES < <(yq eval -o=j -I=0 '.env.CLOUD_RUN_SERVICES[]' "${BASE_DIR}/../config/${environment}.env.yaml")
export CLOUD_RUN_SERVICES
GCLOUD_PROJECT=$(yq eval '.env.GCLOUD_PROJECT' "${BASE_DIR}/../config/${environment}.env.yaml")
export GCLOUD_PROJECT
HIERARCHY_SERVICE_NAMESPACE=$(yq eval '.hierarchy.namespace' "${BASE_DIR}/../values/${environment}.yaml")
export HIERARCHY_SERVICE_NAMESPACE
GCLOUD_PROJECT_NUMBER=$(yq eval '.env.GCLOUD_PROJECT_NUMBER' "${BASE_DIR}/../config/${environment}.env.yaml")
export GCLOUD_PROJECT_NUMBER
GRAPHQL_SERVICE_NAMESPACE=$(yq eval '.graphql.namespace' "${BASE_DIR}/../values/${environment}.yaml")
export GRAPHQL_SERVICE_NAMESPACE
ASM_CONTROL_PLANE_NAMESPACE=$(yq eval '.istioControlPlane.namespace' "${BASE_DIR}/../values/${environment}.yaml")
export ASM_CONTROL_PLANE_NAMESPACE
PROTOBUF_SCHEMA_TAG=$(yq eval '.env.PROTOBUF_SCHEMA_TAG' "${BASE_DIR}/../config/${environment}.env.yaml")
export PROTOBUF_SCHEMA_TAG
PROTOBUF_SCHEMA_BUCKET_NAME=$(yq eval '.env.PROTOBUF_SCHEMA_BUCKET_NAME' "${BASE_DIR}/../config/${environment}.env.yaml")
export PROTOBUF_SCHEMA_BUCKET_NAME
readarray PMR_EVENTS < <(yq eval -o=j -I=0 '.env.PMR_EVENTS[]' "${BASE_DIR}/../config/${environment}.env.yaml")
export PMR_EVENTS