#!/usr/bin/env bash

script_dir=$(dirname "$0")

export BASE_DIR=$(cd "${script_dir}"; pwd -P)

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