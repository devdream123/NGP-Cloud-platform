#!/usr/bin/env bash

set -e

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
	print_usage
	exit 1
fi

rendered_chart_path="${base_dir}/../charts-rendered/dev"
mkdir -p "${rendered_chart_path}"
chart_path="${base_dir}/../charts"


helm template "${chart_path}/istio" \
  -f "${chart_path}/istio/values-dev.yaml" \
  --atomic \
  --name-template="${release_name}" > "${rendered_chart_path}/istio-0.0.1.yml"

helm template "${chart_path}/graphql-mesh" \
	-f "${chart_path}/graphql-mesh/values-dev.yaml" \
	--atomic \
	--name-template="${release_name}" > "${rendered_chart_path}/graphql-mesh-0.0.1.yml"

helm template "${chart_path}/dealsheet-api" \
	-f "${chart_path}/dealsheet-api/values-dev.yaml" \
	--atomic \
	--name-template="${release_name}" > "${rendered_chart_path}/dealsheet-api-0.0.1.yml"

helm template "${chart_path}/calendar-api" \
	-f "${chart_path}/calendar-api/values-dev.yaml" \
	--atomic \
	--name-template="${release_name}" > "${rendered_chart_path}/calendar-api-0.0.1.yml"

helm template "${chart_path}/eventschedule-api" \
	-f "${chart_path}/eventschedule-api/values-dev.yaml" \
	--atomic \
	--name-template="${release_name}" > "${rendered_chart_path}/eventschedule-api-0.0.1.yml"

helm template "${chart_path}/hierarchy-api" \
	-f "${chart_path}/hierarchy-api/values-dev.yaml" \
	--atomic \
	--name-template="${release_name}" > "${rendered_chart_path}/hierarchy-api-0.0.1.yml"

helm template "${chart_path}/forecast-api" \
	-f "${chart_path}/forecast-api/values-dev.yaml" \
	--atomic \
	--name-template="${release_name}" > "${rendered_chart_path}/forecast-api-0.0.1.yml"