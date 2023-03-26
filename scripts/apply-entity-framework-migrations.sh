#!/usr/bin/env bash

set -o errexit   # abort on nonzero exitstatus
set -o pipefail  # don't hide errors within pipes

function print_usage() {
  printf "A script to apply entity framework migrations for a specific chart.\n"
  printf "EF migrations bucket name is required.\n"
  printf "Chart name is required.\n"
  printf "Cluster name is required.\n"
  printf "GCP project id is required.\n"
}

if [ ! "$1" ] || [ ! "$2" ] || [ ! "$3" ] || [ ! "$4" ]; then
  print_usage
  exit 1
fi
 
ef_migrations_bucket=$1
chart_name=$2
cluster_name=$3
gcp_project=$4

tag=$(yq eval '.image.tag' "${BASE_DIR}/../charts/${chart_name}/values-${cluster_name}.yaml")
cloud_sql_instance=$(yq eval '.database.instance' "${BASE_DIR}/../charts/${chart_name}/values-${cluster_name}.yaml")
database=$(yq eval '.database.db' "${BASE_DIR}/../charts/${chart_name}/values.yaml")
database_iam_user=$(yq eval '.database.user' "${BASE_DIR}/../charts/${chart_name}/values-${cluster_name}.yaml")
migration_script_gcs_object_uri="gs://${ef_migrations_bucket}/${database}/${tag}_migration_script.sql"

echo "Checking if entity framework migration script for tag: ${tag} and database: ${database} exists in the bucket."

if [[ $(gsutil ls "${migration_script_gcs_object_uri}") ]]; then
  
  echo "Importing entity framework migration script for tag: ${tag} on database: ${database} of ${cloud_sql_instance} cloud SQL instance."
  gcloud sql import sql "${cloud_sql_instance}" "${migration_script_gcs_object_uri}" \
    --database="${database}" \
    --user="${database_iam_user}" \
    --project="${gcp_project}"

else
  
  echo "The migration script in the following path: ${migration_script_gcs_object_uri} was not found"

fi