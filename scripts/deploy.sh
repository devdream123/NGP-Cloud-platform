#!/usr/bin/env bash

script_dir=$(dirname "$0")

export BASE_DIR=$(cd "${script_dir}"; pwd -P)

if [ "$1" ]; then
   environments=("$1")
   betaReleaseEnvironments=("$1")	
 else 
   environments=("dev" "uat" "prd")
   betaReleaseEnvironments=("dev")
fi

echo "using base dir: ${BASE_DIR}"

for environment in ${environments[@]}; do
   
   bash ${BASE_DIR}/install-helm-charts.sh $environment 
   
   if [ ${environment} == "dev" ]; then
      bash ${BASE_DIR}/enable-service-mesh-features.sh $environment 
   fi

done

for betaReleaseEnvironment in ${betaReleaseEnvironments[@]}; do
   bash ${BASE_DIR}/install-beta-helm-charts.sh $betaReleaseEnvironment 
done

for environment in ${environments[@]}; do   
   bash ${BASE_DIR}/restart-graphql-service.sh $environment
done