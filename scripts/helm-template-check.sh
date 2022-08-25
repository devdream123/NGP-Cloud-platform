#!/usr/bin/env bash

script_dir=$(dirname "$0")
base_dir=$(cd "${script_dir}"; pwd -P)

environments=(
    "tst"
    "dev"
    "uat"
    "prd"
)
deployments=(
    "calendar-api"
    "dealsheet-api"
    "eventschedule-api"
    "forecast-api"
    "graphql-mesh"
    "hierarchy-api"
)

echo "Beginning Helm Template checks..."

for deployment in "${deployments[@]}"; do
    echo "Deployment: $deployment"
    for environment in "${environments[@]}"; do
        echo "Environment: $environment"

        # add temp db password for forecast-api services cluster values to allow helm template command to succeed. 
        # avoid using `-i` in sed commands as it is not portable between OSX (BSD) and GNU versions
        [[ "$deployment" == "forecast-api" ]] && sed "s/pwd: /pwd: tempvalue/g" ${base_dir}/../charts/forecast-api/values-ngp-${environment}-us1-services1-gke.yaml > temp.yaml && mv temp.yaml ${base_dir}/../charts/forecast-api/values-ngp-${environment}-us1-services1-gke.yaml

        # Check helm chart
        echo "Checking services chart for $environment $deployment with values from ./charts/${deployment}/values-ngp-${environment}-us1-services1-gke.yaml-us1-services1-gke.yaml"
        helm template ${base_dir}/../charts/${deployment} --output-dir ${base_dir}/../outputs/${environment} --values ${base_dir}/../charts/${deployment}/values-ngp-${environment}-us1-services1-gke.yaml
                
        # remove temp db password for forecast-api
        [[ "$deployment" == "forecast-api" ]] && sed "s/pwd: tempvalue/pwd: /g" ${base_dir}/../charts/forecast-api/values-ngp-${environment}-us1-services1-gke.yaml > temp.yaml && mv temp.yaml ${base_dir}/../charts/forecast-api/values-ngp-${environment}-us1-services1-gke.yaml

        # perform the same steps for playground cluster
        if [[ "$environment" == "dev" ]]; then

            # add temp db password for forecast-api
            [[ "$deployment" == "forecast-api" ]] && sed "s/pwd: /pwd: tempvalue/g" ${base_dir}/../charts/forecast-api/values-ngp-${environment}-us1-services1-gke.yaml > temp.yaml && mv temp.yaml ${base_dir}/../charts/forecast-api/values-ngp-${environment}-us1-playground1-gke.yaml

            echo "Checking playground chart for $environment $deployment with values from ./charts/forecast-api/values-ngp-${environment}-us1-playground1-gke.yaml"
            helm template ${base_dir}/../charts/${deployment} --output-dir ${base_dir}/../outputs/${environment} --values ${base_dir}/../charts/${deployment}/values-ngp-${environment}-us1-playground1-gke.yaml

            # remove temp db password for forecast-api
            [[ "$deployment" == "forecast-api" ]] && sed "s/pwd: tempvalue/pwd: /g" ${base_dir}/../charts/forecast-api/values-ngp-${environment}-us1-services1-gke.yaml > temp.yaml && mv temp.yaml ${base_dir}/../charts/forecast-api/values-ngp-${environment}-us1-playground1-gke.yaml
        fi

    done
done
