#!/usr/bin/env bash


script_dir=$(dirname "$0")

export BASE_DIR=$(cd "${script_dir}"; pwd -P)

if [ "$1" ]; then
   environments=("$1")	
 else 
   environments=("tst" "dev" "uat" "prd")
fi

for environment in ${environments[@]}; do
   source ${BASE_DIR}/export-env-variables.sh $environment
   
   for cluster in ${CLOUDSDK_CONTAINER_CLUSTERS}; do
    
   echo "Substituting secrets' values for cluster: ${cluster} in environment : ${environment}"
   
    ENVIRONMENT_UPPER_CASE=$(echo $environment | tr '[:lower:]' '[:upper:]')
    FORECAST_POSTGRES_DB_PASSWORD=FORECAST_POSTGRES_PWD_$ENVIRONMENT_UPPER_CASE
    REACT_APP_ERROR_REPORTING_API_KEY=REACT_APP_ERROR_REPORTING_API_KEY_$ENVIRONMENT_UPPER_CASE
    REACT_APP_LAUNCHDARKLY_CLIENT_ID=REACT_APP_LAUNCHDARKLY_CLIENT_ID_$ENVIRONMENT_UPPER_CASE

    sed -i "s/pwd: /pwd: ${!FORECAST_POSTGRES_DB_PASSWORD}/" "./charts/forecast-api/values-${cluster}.yaml"
    sed -i "s/typesenseAPIKey:/typesenseAPIKey: ${TYPESENSE_API_KEY}/" "./charts/hierarchy-api/values-${cluster}.yaml"
    sed -i "s/typesenseAPIKey:/typesenseAPIKey: ${TYPESENSE_API_KEY}/" "./charts/calendar-api/values-${cluster}.yaml"
    sed -i "s/typesenseAPIKey:/typesenseAPIKey: ${TYPESENSE_API_KEY}/" "./charts/dealsheet-api/values-${cluster}.yaml"
    sed -i "s/reactAppErrorReportingApiKey:/reactAppErrorReportingApiKey: ${!REACT_APP_ERROR_REPORTING_API_KEY}/" "./charts/frontend-ui/values-${cluster}.yaml"
    sed -i "s/reactAppLaunchDarklyClientId:/reactAppLaunchDarklyClientId: ${!REACT_APP_LAUNCHDARKLY_CLIENT_ID}/" "./charts/frontend-ui/values-${cluster}.yaml"
    sed -i "s/typesenseAPIKey:/typesenseAPIKey: ${TYPESENSE_API_KEY}/" "./charts/frontend-ui/values-${cluster}.yaml"
   
   done
done
