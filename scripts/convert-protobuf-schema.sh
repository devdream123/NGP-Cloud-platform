#!/usr/bin/env bash

echo "Starting convert-protobuf-schema.sh"

set -o errexit   # abort on nonzero exitstatus
set -o pipefail  # don't hide errors within pipes
set -o nounset   # abort on unbound variable


protobuf_schemas_folder=$1
protobuf_schema_filename=$2

#protoc --bq-schema_out=. ApprovalRequest.proto --proto_path=.
protoc --bq-schema_out=. "${protobuf_schema_filename}" --proto_path="${protobuf_schemas_folder}"