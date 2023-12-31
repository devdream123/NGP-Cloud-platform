#!/usr/bin/env bash

echo "Starting package-store-charts.sh"

set -o errexit   # abort on nonzero exitstatus
set -o pipefail  # don't hide errors within pipes
set -o nounset   # abort on unbound variable

function print_usage() {
  printf "A script to package and store helm charts on a remote repository.\n"
  printf "Artifact registry uri is required."
}

if [ ! "$1" ]; then
  print_usage 
  exit 1
fi

script_dir=$(dirname "$0")
BASE_DIR=$(cd "${script_dir}"; pwd -P)
export "BASE_DIR"
charts_dir="${BASE_DIR}/../charts"
destination_dir="${BASE_DIR}/../outputs/packages"
artifact_registry_uri=$1

for dir in "${charts_dir}"/*; do

  echo "Packaging the HELM chart: ${dir}"
  helm package "${dir}" --destination "${destination_dir}"

done 

for package in "${destination_dir}"/*; do

  echo "Uploading the HELM package: ${package}"
  helm push "${package}" oci://"${artifact_registry_uri}"

done