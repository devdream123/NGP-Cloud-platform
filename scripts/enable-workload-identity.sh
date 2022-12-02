#!/usr/bin/env bash

set -e

function print_usage() {
  printf "A script to enable GCP workload identity for a Kubernetes service account..\n"
  printf "GCP project id is required.\n"
  printf "GCP service account name is required.\n"
  printf "Kubernetes service account name is required.\n"
  printf "Kubernetes namespace name is required.\n"
  printf "example of execution : enable-workload-identity.sh <project_id> <gcp sa name> <k8s sa name> <k8s ns>."
}

if [ ! "$1" ]  || [ ! "$2" ] || [ ! "$3" ] || [ ! "$4" ] ; then
	print_usage
	exit 1
fi


gcp_project=$1
gcp_sa=$2
k8s_sa=$3
k8s_ns=$4

gcloud iam service-accounts add-iam-policy-binding ${gcp_sa}@${gcp_project}.iam.gserviceaccount.com \
 --role="roles/iam.workloadIdentityUser" \
 --member="serviceAccount:${gcp_project}.svc.id.goog[${k8s_ns}/${k8s_sa}]"

kubectl annotate serviceaccount ${k8s_sa} iam.gke.io/gcp-service-account=${gcp_sa}@${gcp_project}.iam.gserviceaccount.com -n ${k8s_ns} --overwrite=true