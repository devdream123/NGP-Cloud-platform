#!/usr/bin/env bash

set -e

function print_usage() {
  printf "A script to package and store helm charts on a remote repository.\n"
  printf "Artifact registry uri is required."
}

if [ ! "$1" ]; then
	print_usage
	exit 1
fi

script_dir=$(dirname "$0")
export BASE_DIR=$(cd "${script_dir}"; pwd -P)
charts_dir="${BASE_DIR}/../charts"
destination_dir="${BASE_DIR}/../outputs/packages"
artifact_registry_uri=$1

for dir in  $(ls ${charts_dir}); do
  helm package "${charts_dir}/${dir}" -d ${destination_dir}
done 

for package in $(ls ${destination_dir}); do
  echo "${destination_dir}/${package}"
  helm push "${destination_dir}/${package}" oci://${artifact_registry_uri}
done
