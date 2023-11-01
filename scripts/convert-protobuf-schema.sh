#!/usr/bin/env bash

echo "Starting convert-protobuf-schema.sh"

set -o errexit   # abort on nonzero exitstatus
set -o pipefail  # don't hide errors within pipes
set -o nounset   # abort on unbound variable


protobuf_schemas_folder=$1
protobuf_schema_file_name=$2

echo "Converting protobuf schema ${protobuf_schema_file_name} to BigQuery format..."
protoc --bq-schema_out=. \
      "${protobuf_schemas_folder}/${protobuf_schema_file_name}" \
      --proto_path="${protobuf_schemas_folder}"

conversion_status=$?

if [[ "${conversion_status}" -ne 0 ]]; then
error_message="An error occured during the conversion."
error_message=" Exiting the script with error status code..."
echo "${error_message}"
exit 1
fi

echo "Conversion was successful."

