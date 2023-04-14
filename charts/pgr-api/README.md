## TEST PGR API on a K8s cluster.

### Prerequisites  

1. Ensure that `gcloud` is installed.
2. Install `kubectl`. Find the instructions [here](https://kubernetes.io/docs/tasks/tools/#kubectl)
3. Generate a `kubeconfig` entry for a specific cluster, for example dev cluster:
 `gcloud container clusters get-credentials ngp-dev-us1-services1-gke --region us-central1 --project gcp-wow-corp-qretail-ngp-dev`
3. If you are not comfortable with running commands in a Terminal, install k8s IDE: Lens 

### Connect to a cluster 

1. View all the k8s contexts (clusters) on your local machine: `kubectl config get-contexts`
2. Switch to a specific context from the previous step's output: `kubectl config use-context gke_gcp-wow-corp-qretail-ngp-dev_us-central1_ngp-dev-us1-services1-gke`
3. Port-forward (open a connection) to the `graphql mesh` service: `kubectl port-forward deployment/graphql-mesh -n ngp-graphql-mesh 8000:80` . In this command the port on the left side of the colon refers to the port on your local machine and the port on the right refers to the `graphql mesh` service port. The local port can change but service port must be `80` 
4. If connection is successful, keep the terminal open and start browsing the `graphql mesh` UI by using the following address: http://localhost:8000/graphql
5. Execute Graphql queries for PGR in the UI.

**NOTES** 
- Since PGR api is still in testing and development phase, it is not integrated with `graphql mesh` in all the environments. You need to enable it by setting the flag in `charts/pgr-api/values-ngp-<env>.yaml` file to true.

