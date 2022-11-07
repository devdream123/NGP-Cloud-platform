#!/usr/bin/env bash

set -e

function print_usage() {
  printf "A script to enable service mesh features.\n"
  printf "Environment name is required i.e. dev, uat, prd."
  printf '\t-h | --help\n'
  printf '\t-e | --environment (string, optional, the name of the environment config to use during deployment)\n'
}

if [ ! "$1" ]; then
	print_usage
	exit 1
fi

environment=$1
source ${BASE_DIR}/export-env-variables.sh ${environment}

echo "Applying the Istio control plane configuration in ${environment} environment."
kubectl apply -f ./outputs/${environment}/istio-control-plane/templates/ -n ${ASM_CONTROL_PLANE_NAMESPACE}