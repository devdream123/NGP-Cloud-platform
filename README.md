# Cloud platform repository of next generation promotion  

## Overview
This repository contains changes which describe the state of Next gen promo cloud platform.

The resources in this repository are separated into release environments ( i.e. dev, staging, prod ) and declare entities like configuration, deployments, services and data pipeline components.

## Repository Structure

### charts
- this folder contains the helmcharts for NGP, including `calendar-api`, `dealsheet-api`, etc.
- these describe the specification i.e. replica-set, container image(s) and configurations i.e. secrets, environment variables of each NGP service. 
- values from the relevant file are substituted into values.yaml to configure each application
    - the relevant file for each cluster is suffixed with the cluster name: values-<cluster_name>.yaml

### config  
- contains config files, which declare constants, for each operation environment, i.e. `dev` and `uat`

### scripts
- contains scripts to be executed during the deploy stage

### values
- Contains values objects used in relevant operation environments.  Objects in these files are passed into a HELM 
template from the template engine and substituted accordingly. Cluster specific objects should go into the corresponding override file
### cloudbuild.yaml
- sets environment variables for build and calls the `deploy` script

### helmfile.yaml 
- contains deployment configurations for each helmchart
- used by cloudbuild to deploy each helmchart in each environment

## Making Changes

The base branch for any changes, and destination branch for any PRs, should be the `main` branch.

### How to prepare and inject a secret into a helmchart

To provision a secret and inject it into the build, follow this [Secret Provisioning Guide](https://woolworths-agile.atlassian.net/wiki/spaces/NGP/pages/32258916745/Secret+Provisioning+Guide).