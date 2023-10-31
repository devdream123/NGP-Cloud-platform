#!/usr/bin/env bash

echo "Starting update-bq-table-schema.sh"

set -o errexit   # abort on nonzero exitstatus
set -o pipefail  # don't hide errors within pipes
set -o nounset   # abort on unbound variable

bigquery_gcp_project=$1
bigquery_dataset_name=$2
bigquery_table_name=$3
bigquery_table_schema_file=$4

column_name=$(cat "${bigquery_table_schema_file}" | jq .[0].name | tr -d '"')
column_data_type=$(cat "${bigquery_table_schema_file}" | jq .[0].type | tr -d '"')
#column_mode=$(cat "${bigquery_table_schema_file}" | jq .[0].mode)
bigquery_table_path="${bigquery_gcp_project}.${bigquery_dataset_name}.${bigquery_table_name}"
bigquery_table_resource_name="${bigquery_gcp_project}:${bigquery_dataset_name}.${bigquery_table_name}"

#step 1 Add a column from JSON schema to BQ table 
bq query --use_legacy_sql=false \
 "ALTER TABLE ${bigquery_table_path} ADD COLUMN IF NOT EXISTS ${column_name} ${column_data_type}"

# step2 Drop the column created by TF 
bq query --use_legacy_sql=false \
"ALTER TABLE ${bigquery_table_path} DROP COLUMN IF EXISTS data"

# step 3 Update the table Schema using the schema file 
bq update "${bigquery_table_resource_name}" "${bigquery_table_schema_file}"