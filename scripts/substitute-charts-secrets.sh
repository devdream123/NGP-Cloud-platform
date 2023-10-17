#!/usr/bin/env bash

echo "Starting substitute-charts-secrets.sh"

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
  source "${BASE_DIR}"/export-env-variables.sh "${environment}"

  for cluster in ${CLOUDSDK_CONTAINER_CLUSTERS}; do

    echo "Substituting secrets' values for cluster: ${cluster} in environment : ${environment}"

    sed -i "s/typesenseAPIKey:/typesenseAPIKey: ${TYPESENSE_API_KEY}/" "./charts/hierarchy-api/values-${cluster}.yaml"
    sed -i "s/typesenseAPIKey:/typesenseAPIKey: ${TYPESENSE_API_KEY}/" "./charts/calendar-api/values-${cluster}.yaml"
    sed -i "s/typesenseAPIKey:/typesenseAPIKey: ${TYPESENSE_API_KEY}/" "./charts/dealsheet-api/values-${cluster}.yaml"
    sed -i "s/typesenseAPIKey:/typesenseAPIKey: ${TYPESENSE_API_KEY}/" "./charts/frontend-ui/values-${cluster}.yaml"
    sed -i "s/typesenseAPIKey:/typesenseAPIKey: ${TYPESENSE_API_KEY}/" "./charts/graphql-mesh/values-${cluster}.yaml"

    if [ "${environment}" != "prd" ]; then
      pmr_api_credential_secret_name="PMR_ENDPOINT_API_CREDENTIAL_${environment^^}"
      pmr_api_credential_secret_value="${!pmr_api_credential_secret_name}"
      sed -i "s/pmrEndpointAPICredential:/pmrEndpointAPICredential: ${pmr_api_credential_secret_value}/" "./charts/pmr-sync/values-${cluster}.yaml"
    fi
  
  done

done
