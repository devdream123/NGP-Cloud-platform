#!/usr/bin/env bash

set -o errexit   # abort on nonzero exitstatus
set -o pipefail  # don't hide errors within pipes

function print_usage() {
  printf "A script to apply entity framework migrations for a specific chart.\n"
  printf "EF migrations bucket name is required.\n"
  printf "Chart name is required.\n"
  printf "Cluster name is required.\n"
  printf "GCP project id is required.\n"
  printf "Cloud sql instance name is required.\n"
  printf "Database name is required.\n"
  printf "Database IAM user is required.\n"
}

function sql_operations_wait() {
  echo "Waiting for any existing database operations to finish on ${cloud_sql_instance} before running the migration script ..."
  gcloud sql operations list \
    --instance "${cloud_sql_instance}" \
    --filter='NOT status:done' \
    --format='value(name)' \
    --project="${gcp_project_id}" \
    | xargs -r gcloud sql operations wait --project="${gcp_project_id}"
}

if [ ! "$1" ] || [ ! "$2" ] || [ ! "$3" ] || [ ! "$4" ] || [ ! "$5" ] || [[ ! "$6" ]] || [[ ! "$7" ]]; then
  print_usage
  exit 1
fi
 
ef_migrations_bucket=$1
chart_name=$2
cluster_name=$3
gcp_project_id=$4
cloud_sql_instance=$5
database=$6
database_iam_user=$7

tag=$(yq eval '.image.tag' "${BASE_DIR}/../charts/${chart_name}/values-${cluster_name}.yaml")
migration_script_gcs_object_uri="gs://${ef_migrations_bucket}/${database}/${tag}_migration_script.sql"

echo "Checking if entity framework migration script for tag: ${tag} and database: ${database} exists in the bucket."

if [[ $(gsutil ls "${migration_script_gcs_object_uri}") ]]; then

  sql_operations_wait

  echo "Importing entity framework migration script for tag: ${tag} into the database: ${database} on ${cloud_sql_instance} cloud SQL instance."
  gcloud sql import sql "${cloud_sql_instance}" "${migration_script_gcs_object_uri}" \
    --database="${database}" \
    --user="${database_iam_user}" \
    --project="${gcp_project_id}"

else
  
  echo "The migration script in the following path: ${migration_script_gcs_object_uri} was not found"

fi