#!/usr/bin/env bash

set -o errexit   # abort on nonzero exitstatus
set -o pipefail  # don't hide errors within pipes

script_dir=$(dirname "$0")

BASE_DIR=$(cd "${script_dir}"; pwd -P)
export BASE_DIR

if [ "$1" ]; then
  environments=("$1")
 else 
  environments=("dev" "uat" "prd")
fi

echo "using base dir: ${BASE_DIR}"

for environment in "${environments[@]}"; do

  "${BASE_DIR}"/install-helm-charts.sh "${environment}"
  "${BASE_DIR}"/enable-service-mesh-features.sh "${environment}"

done

for environment in "${environments[@]}"; do

  "${BASE_DIR}"/restart-graphql-service.sh "${environment}"

done