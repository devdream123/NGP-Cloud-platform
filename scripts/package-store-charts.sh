#!/usr/bin/env bash

set -e

function print_usage() {
  printf "a script to package and store helm charts on a remote repository.\n"
  
}

script_dir=$(dirname "$0")
root_dir=$(cd "${script_dir}/.."; pwd -P)


charts_dir="${root_dir}/charts"
destination_dir="${root_dir}/outputs/packages"

for dir in  $(ls ${charts_dir}); do
   helm package "${charts_dir}/${dir}" -d ${destination_dir}
done 


for package in $(ls ${destination_dir}); do
echo "${destination_dir}/${package}"
 helm push "${destination_dir}/${package}" oci://us-central1-docker.pkg.dev/gcp-wow-corp-infra-qrtl-prod/ngp-helm-charts
done