#!/usr/bin/env bash

script_dir=$(dirname "$0")
base_dir=$(cd "${script_dir}"; pwd -P)

release_name='qr-ngp'
release_env='dev'

function print_usage() {
  printf "a build script for helm\n"
  printf '\t-h | --help\n'
  printf '\t-r | --release-name (string, optional, the name of the helm release)\n'
  printf '\t-e | --release-env (string, optional, the name of the environment to release to)\n'
}

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
  -r | --release-name)
    release_name="$2"
    shift # past argument
    shift # past value
    ;;
  -e | --release-env)
    release_env="$2"
    shift # past argument
    shift # past value
    ;; 
  *) # unknown option
	print_usage
    shift
    ;;
  esac
done

if [[ -z "${release_name}" || -z "${release_env}" ]]; then
	print_help
	exit 1
fi

mkdir -p "${base_dir}/../charts-rendered/dev"

helm template "${base_dir}/../charts/istio" \
  -f "${base_dir}/../charts/istio/values-dev.yaml" \
  --atomic \
  --name-template="${release_name}" > "${base_dir}/../charts-rendered/dev/istio-0.0.1.yml"

helm template "${base_dir}/../charts/graphql-mesh" \
	-f "${base_dir}/../charts/graphql-mesh/values-dev.yaml" \
	--atomic \
	--name-template="${release_name}" > "${base_dir}/../charts-rendered/dev/graphql-mesh-0.0.1.yml"

helm template "${base_dir}/../charts/dealsheet-api" \
	-f "${base_dir}/../charts/dealsheet-api/values-dev.yaml" \
	--atomic \
	--name-template="${release_name}" > "${base_dir}/../charts-rendered/dev/dealsheet-api-0.0.1.yml"
