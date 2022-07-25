#!/usr/bin/env bash
set -e

function print_usage() {
  printf "A script to restart the GraphQL mesh.\n"
  printf "Environment name is required i.e. dev, uat, prd."
  printf '\t-h | --help\n'
  printf '\t-e | --environment (string, optional, the name of the environment config to use during deployment)\n'
}

function check_deployment_completeness () {
   status=$(kubectl rollout status deployments/${1} -n ${2} -w=false)
   echo $status | grep 'deployment "'${1}'" successfully rolled out' 
}

function check_all_deployments () {
   deployment_statuses=()
   
   for deployment in ${deployments[@]}; do 
      check_deployment_completeness $deployment $GRAPHQL_SERVICE_NAMESPACE
      deployment_statuses+=($?) 
   done
   
   for status in ${deployment_statuses[@]}; do
      if [ $status != 0 ]; then 
         return $status
      fi
   done 
   
   return 0
 }

if [ ! "$1" ]; then
	print_usage
	exit 1
fi

environment=$1
source ${BASE_DIR}/export-env-variables.sh $environment
deployments=("calendar-api" "dealsheet-api" "eventschedule-api" "hierarchy-api")


for cluster in ${CLOUDSDK_CONTAINER_CLUSTERS}; do
  
   cluster_context="gke_${GCLOUD_PROJECT}_${CLOUDSDK_COMPUTE_REGION}_${cluster}"
   echo "Switching to context:${cluster_context} to restart GraphQL mesh service." 
   kubectl config use-context "${cluster_context}"
  
   until check_all_deployments 
      do 
      echo "Waiting for deployments of services in cluster: ${cluster} to be ready before restarting GraphQL mesh."
      sleep 20 
   done

   echo "Restarting GraphQL mesh in cluster: ${cluster} of ${environment} environment"
   kubectl rollout restart deployment/graphql-mesh --namespace=${GRAPHQL_SERVICE_NAMESPACE} 

done
