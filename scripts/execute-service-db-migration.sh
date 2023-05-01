#check the deployment status

#aRun a k8s container 
kubectl run db-migrator \
  --image=us-central1-docker.pkg.dev/gcp-wow-corp-infra-qrtl-prod/hub-prd-us1-shared-asset-registry1/psql:test \
  --restart=Never \
  -n ngp-frontend \
  -- sleep infinity

#Check if pod is ready 


until [ "$(kubectl get pod db-migrator -n ngp-frontend --output=yaml | yq '.status.containerStatuses[] | select(.name == "db-migrator")| .ready')" = false ]; do
  echo "waiting for pod to be running"
  sleep 5
done

# #Copy the migration script 
gsutil cp gs://ngp-prd-us1-ef-migration-bundles1-af2c-bucket/customGroupsMigrations_50c0db7.tar.gz . 
kubectl config current-context
kubectl cp customGroupsMigrations_50c0db7.tar.gz ngp-frontend/db-migrator:/tmp
kubectl cp apply-sequlize-migrations.sh ngp-frontend/db-migrator:/tmp

# # Execute the migration script. 

kubectl exec db-migrator -c db-migrator  -i -t -n ngp-frontend -- bash tmp/apply-sequlize-migrations.sh