#!/usr/bin/env bash

################
## This script automates some of the steps documented in these ASM guides
## https://cloud.google.com/service-mesh/docs/managed/provision-managed-anthos-service-mesh#enable_automatic_management
## https://cloud.google.com/service-mesh/docs/managed/enable-managed-anthos-service-mesh-optional-features#enable_cloud_tracing
################

set -e

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
source ${BASE_DIR}/export-env-variables.sh ${environment}

for cluster in ${CLOUDSDK_CONTAINER_CLUSTERS}; do

  cluster_context="gke_${GCLOUD_PROJECT}_${CLOUDSDK_COMPUTE_REGION}_${cluster}"
  kubectl config use-context "${cluster_context}"

  echo "Applying the Istio control plane configuration in ${environment} environment for ${cluster} cluster."
  kubectl apply -f ./outputs/${environment}/${cluster}/istio-control-plane/templates/ -n ${ASM_CONTROL_PLANE_NAMESPACE}

  echo "Enabling auto management of ASM control and data planes for envoy proxies in ${environment} environment for ${cluster} cluster."
  gcloud container fleet mesh update \
      --management automatic \
      --memberships "${cluster}-membership" \
      --project ${GCLOUD_PROJECT}

done