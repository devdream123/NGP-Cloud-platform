#!/usr/bin/env bash

script_dir=$(dirname "$0")
base_dir=$(cd "${script_dir}"; pwd -P)

export BASE_DIR=$(cd "${script_dir}"; pwd -P)

environments=("dev" "uat" "prd")

echo "using base dir: ${BASE_DIR}"

for environment in ${environments[@]}; do
   bash ${BASE_DIR}/deploy-environment.sh $environment 
done

for environment in ${environments[@]}; do   
   bash ${BASE_DIR}/restart-graphql-service.sh $environment
done