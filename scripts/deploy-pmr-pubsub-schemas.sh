#!/usr/bin/env bash

echo "Starting deploy-pmr-pubsub-schemas.sh"

set -o errexit   # abort on nonzero exitstatus
set -o pipefail  # don't hide errors within pipes
set -o nounset   # abort on unbound variable

script_dir=$(dirname "$0")
BASE_DIR=$(cd "${script_dir}"; pwd -P)
export BASE_DIR

environment=$1
source "${BASE_DIR}"/export-env-variables.sh "${environment}"

protobuf_schemas_destination_folder_name="schemaFiles"
protobuf_schemas_bucket_folder_name="gs://${PROTOBUF_SCHEMA_BUCKET_NAME}/${PROTOBUF_SCHEMA_TAG}"

#1 download the schemas from storage bucket 
source "${BASE_DIR}/download-protobuf-schemas.sh" "${protobuf_schemas_bucket_folder_name}" "${protobuf_schemas_destination_folder_name}" 

for pmr_event in "${PMR_EVENTS[@]}"; do

#2 create pubsub topic schema
  topic_schema_name=$(echo "${pmr_event}" | yq .topicSchemaName)
  protobuf_schema_filename=$(echo "${pmr_event}" | yq .protobufSchemaFileName)
  topic_full_id=$(echo "${pmr_event}" | yq .topicFullId)

  source "${BASE_DIR}/create-pubsub-topic-schema.sh" \
        "${protobuf_schemas_destination_folder_name}/${protobuf_schema_filename}" \
        "${topic_schema_name}" \
        "${topic_full_id}" \
        "${GCLOUD_PROJECT}"

#3 convert protobuf schema to json schema 
  # echo "Converting protobuf schema ${protobuf_schema_filename} to BigQuery format..."
  # source "${BASE_DIR}/convert-protobuf-schema.sh" "${protobuf_schemas_destination_folder_name}" "${protobuf_schema_filename}"

#4 update bq table schema
#     bigquery_table_name=$(echo "${pmr_event}" | yq .bigqueryTableName)
#     bigquery_table_schema_file="${PROTOBUF_SCHEMA_PACKAGE_NAME}/${bigquery_table_name}.schema"
#     bigquery_dataset_name=$(echo "${pmr_event}" | yq .bigqueryDatasetId)

# source "${BASE_DIR}/update-bq-table-schema.sh" \
#         "${GCLOUD_PROJECT}" \
#         "${bigquery_dataset_name}" \
#         "${bigquery_table_name}" \
#         "${bigquery_table_schema_file}"

done