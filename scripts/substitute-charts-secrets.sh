#!/usr/bin/env bash

set -o errexit   # abort on nonzero exitstatus
set -o pipefail  # don't hide errors within pipes

script_dir=$(dirname "$0")

BASE_DIR=$(cd "${script_dir}"; pwd -P)
export BASE_DIR

if [ "$1" ]; then
  environments=("$1")	
 else 
  environments=("tst" "dev" "uat" "prd")
fi

for environment in "${environments[@]}"; do
  source ${BASE_DIR}/export-env-variables.sh "${environment}"
  
  for cluster in ${CLOUDSDK_CONTAINER_CLUSTERS}; do
   
    echo "Substituting secrets' values for cluster: ${cluster} in environment : ${environment}"

    sed -i "s/typesenseAPIKey:/typesenseAPIKey: ${TYPESENSE_API_KEY}/" "./charts/hierarchy-api/values-${cluster}.yaml"
    sed -i "s/typesenseAPIKey:/typesenseAPIKey: ${TYPESENSE_API_KEY}/" "./charts/calendar-api/values-${cluster}.yaml"
    sed -i "s/typesenseAPIKey:/typesenseAPIKey: ${TYPESENSE_API_KEY}/" "./charts/dealsheet-api/values-${cluster}.yaml"
    sed -i "s/typesenseAPIKey:/typesenseAPIKey: ${TYPESENSE_API_KEY}/" "./charts/frontend-ui/values-${cluster}.yaml"
    sed -i "s/typesenseAPIKey:/typesenseAPIKey: ${TYPESENSE_API_KEY}/" "./charts/graphql-mesh/values-${cluster}.yaml"
    if [ "${environment}" == "dev" ]; then
      sed -i "s/pmrEndpointAPICredential:/pmrEndpointAPICredential: ${PMR_ENDPOINT_API_CREDENTIAL_DEV}/" "./charts/pmr-sync/values-${cluster}.yaml"
    fi
  done

done
