#!/usr/bin/env bash

script_dir=$(dirname "$0")
base_dir=$(cd "${script_dir}"; pwd -P)

environments=("uat" "dev" )

echo "using base dir: ${base_dir}"

for environment in ${environments[@]}; do

   bash ${base_dir}/deploy-environment.sh $environment

done