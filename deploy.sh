#!/bin/bash
set -e


if [ ! "$1" ]; then
	echo "usage: $0  <tenant (e.g. dev, uat, prd, canary, preprd)>"
	exit 1
fi


environment=$1

KUBECTL_DRY_RUN="${KUBECTL_DRY_RUN:-server}"


echo ================================================================================
echo "Deploying environment specific settings for $environment"
echo ================================================================================
gcloud container clusters get-credentials qr-dev-analytics-backend --region us-central1 --project gcp-wow-corp-qretail-ngp-dev
kubectl cluster-info
echo $CLOUDSDK_CONTAINER_CLUSTER
kubectl apply --dry-run=$KUBECTL_DRY_RUN -R -f environments/$environment/namespaces/
kubectl apply --dry-run=$KUBECTL_DRY_RUN -R -f environments/$environment/deplyoments/
kubectl apply --dry-run=$KUBECTL_DRY_RUN -R -f environments/$environment/services/

