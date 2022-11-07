#!/usr/bin/env bash
set -e
script_dir=$(dirname "$0")
export BASE_DIR=$(cd "${script_dir}"; pwd -P)

if [ "$1" ]; then
   environments=("$1")	
 else 
   environments=("tst" "dev" "uat" "prd")
fi

deployments=(
   "calendar-api"
   "dealsheet-api"
   "eventschedule-api"
   "forecast-api"
   "graphql-mesh"
   "hierarchy-api"
   "istio-control-plane"
)

echo "Beginning Helm Template checks..."


for deployment in "${deployments[@]}"; do
    echo "Deployment: $deployment"
    
    for environment in "${environments[@]}"; do
       
       echo "Environment: $environment"
       source ${BASE_DIR}/export-env-variables.sh $environment
       
        # Check helm chart
        for cluster in ${CLOUDSDK_CONTAINER_CLUSTERS}; do
            
           echo "Checking services chart for $environment $deployment with values from ./charts/${deployment}/values-${cluster}.yaml"
           helm template ${BASE_DIR}/../charts/${deployment} --output-dir ${BASE_DIR}/../outputs/${environment} --values ${BASE_DIR}/../charts/${deployment}/values-${cluster}.yaml

        done
  
   done

done
