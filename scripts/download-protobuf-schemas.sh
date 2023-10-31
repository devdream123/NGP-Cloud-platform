#!/usr/bin/env bash

echo "Starting download-protobuff-schemas.sh"

set -o errexit   # abort on nonzero exitstatus
set -o pipefail  # don't hide errors within pipes
set -o nounset   # abort on unbound variable

schemas_bucket_folder_path=$1
destination_folder=$2
mkdir -p "${destination_folder}"

gsutil ls "${schemas_bucket_folder_path}"
if [ $? -ne 0 ]; then
  echo "Directory ${schemas_bucket_folder_path} not found. Check that the provided tag exists"
  exit 1
fi

echo "Downloading schemas from ${schemas_bucket_folder_path}..."
gsutil -m cp -r "${schemas_bucket_folder_path}/*" "${destination_folder}"
