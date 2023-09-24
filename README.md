# Cloud platform repository of next generation promotion

## Overview
This repository contains changes which describe the state of Next gen promo cloud platform.

The resources in this repository are separated into release environments ( i.e. dev, test, uat & prod ) and declare deployment entities like Helm charts, Shell scripts and continuous delivery pipeline.

# Repository Structure

## Charts
This folder contains all the NGP teams specific and community-based Helm charts for the NGS Slotting app. For more information about what a Helm chart is, please refer to Helm project documentation [here](https://helm.sh/docs/topics/charts/).

### NGS Teams Helm Charts
These charts are created by NGS infrastructure squad and maintained by NGS teams to deploy internal services such as `calendar-api`, `dealsheet-api`, `forecasting-api`, `eventschedule-api` to GCP computing resources such as a Kubernetes cluster or Cloud Run service.

#### kubernetes
The manifests in each chart's `templates` folder describe the specification of Kubernetes resources such as Deployment, ConfigMap, Secret, Service etc.
- Config values from the cluster-specific value file are substituted into or override the Helm chart `values.yaml` file. This file is then used by HELM template engine to produce the final Kubernetes manifest.
  - The relevant file for each cluster is suffixed with the cluster name: `values-<cluster_name>.yaml`

#### Cloud Run

GCP Cloud Run service is based on [Knative](https://knative.dev/docs/) open source project. The manifest in each Cloud Run service chart describes the specification of [Knative service](https://github.com/knative/specs/blob/main/specs/serving/knative-api-specification-1.0.md#service) concept.
- Similar to a Kubernetes manifest, config values from the project-specific value file are substituted into or override the Helm chart `values.yaml` file. This file is then used by HELM template engine to produce the final Knative service manifest file.
  - The relevant file for each Cloud Run service is suffixed with the GCP project name: `values-<gcp-project-name>.yaml`

### Community-based Helm Charts

These charts are obtained from open source community to enable more features i.e. *Istio Service mesh* in a Kubernetes cluster. These charts include `istio`, `istio-gateway`.
**Note:**  we modified these charts for our use cases in the project and you need to take that into the account when upgrading or re-installing the chart. For more information about each chart please refer to its `README` file in the chart folder.


## config
- Contains config files, which declare constants such as `cluster name(s), GCP project Id, etc.` for each operation environment, i.e. `tst`, `dev`, `uat` and `prd`.

## scripts
- Contains Shell scripts to be executed during the deploy stage.

### values
Contains values objects used in relevant operation environments. Objects in these files are passed into a HELM chart from the template engine and substituted accordingly. Cluster specific objects should go into the corresponding override file.

### cloudbuild.yaml
This file describes the continuous delivery pipeline steps.
- The pipeline first sets the deployment environment variables such as Kubernetes secrets from GCP secret manager for each release.
- Then it renders each HELM template and ensure that each chart yaml files are valid ones.
- Lastly it runs the `deploy.sh` script
  - The script first install or upgrade each HELM releases.
  - Subsequently it deploys Cloud Run services by executing `gcloud` cli commands.

### helmfile  
- This repository utilizes the [helmfile](https://github.com/helmfile/helmfile) utility to deploy the Kubernetes Helm charts.
- A `helmfile` is the main building block of this utility and contains deployment configurations for each Helm chart. See more information about the `helmfile` [here](https://helmfile.readthedocs.io/en/latest/#configuration).
- This repository contains multiple helm files to deploy specific charts.
- All the helm files that have names starting with `helmfile` are called by scripts to deploy one or a collection of charts in one environment.

#### Why Multiple Helmfile
To control the sequence of installing Helm charts, preventing a `helmfile` file from getting bigger in terms of number of lines and separation of concerns, Helm charts installation is separated into different `helmfile` files.

## Making Changes

The base branch for any changes, and destination branch for any PRs, should be the `main` branch.

### How to prepare and inject a secret into a Helm chart

To provision a secret and inject it into the build, follow this [Secret Provisioning Guide](https://woolworths-agile.atlassian.net/wiki/spaces/NGP/pages/32258916745/Secret+Provisioning+Guide).