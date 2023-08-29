#!/usr/bin/env bash

set -o errexit   # abort on nonzero exitstatus
set -o pipefail  # don't hide errors within pipes

script_dir=$(dirname "$0")

export BASE_DIR=$(cd "${script_dir}"; pwd -P)

if [ "$1" ]; then
  environments=("$1")	
 else 
  environments=("tst" "dev" "uat" "prd")
fi

for environment in "${environments[@]}"; do
  source ${BASE_DIR}/export-env-variables.sh "${environment}"
  
  for cluster in ${CLOUDSDK_CONTAINER_CLUSTERS}; do
   
    echo "Substituting secrets' values for cluster: ${cluster} in environment : ${environment}"

    ENVIRONMENT_UPPER_CASE=$(echo "${environment}" | tr '[:lower:]' '[:upper:]')
    FORECAST_POSTGRES_DB_PASSWORD=FORECAST_POSTGRES_PWD_$ENVIRONMENT_UPPER_CASE
    PMR_ENDPOINT_API_CREDENTIAL=PMR_ENDPOINT_API_CREDENTIAL_$ENVIRONMENT_UPPER_CASE
    sed -i "s/pwd: /pwd: ${!FORECAST_POSTGRES_DB_PASSWORD}/" "./charts/forecast-api/values-${cluster}.yaml"
    sed -i "s/typesenseAPIKey:/typesenseAPIKey: ${TYPESENSE_API_KEY}/" "./charts/hierarchy-api/values-${cluster}.yaml"
    sed -i "s/typesenseAPIKey:/typesenseAPIKey: ${TYPESENSE_API_KEY}/" "./charts/calendar-api/values-${cluster}.yaml"
    sed -i "s/typesenseAPIKey:/typesenseAPIKey: ${TYPESENSE_API_KEY}/" "./charts/dealsheet-api/values-${cluster}.yaml"
    sed -i "s/typesenseAPIKey:/typesenseAPIKey: ${TYPESENSE_API_KEY}/" "./charts/frontend-ui/values-${cluster}.yaml"
    sed -i "s/typesenseAPIKey:/typesenseAPIKey: ${TYPESENSE_API_KEY}/" "./charts/graphql-mesh/values-${cluster}.yaml"
    sed -i "s/pmrEndpointAPICredential:/pmrEndpointAPICredential: ${PMR_ENDPOINT_API_CREDENTIAL}/" "./charts/pmr-sync-api/values-${cluster}.yaml"

  done

done
