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

  if [ "${environment}" == "prd" ]; then

    echo "Starting prod firestore backup"
    gcloud scheduler jobs run ngp-prd-us1-firestore_backup_schedule1-csj --location=us-central1 --project=gcp-wow-corp-qretail-ngp-prod
    echo "Waiting 60 seconds for firestore backup job"
    sleep 60
  
  fi

done

for environment in "${environments[@]}"; do
  
  "${BASE_DIR}"/install-helm-charts.sh "${environment}" 
  "${BASE_DIR}"/enable-service-mesh-features.sh "${environment}" 

done

for environment in "${environments[@]}"; do
  
  "${BASE_DIR}"/restart-graphql-service.sh "${environment}"
  
done