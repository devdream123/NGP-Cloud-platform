#!/usr/bin/env bash

environment=$1
cluster=$2

ENVIRONMENT_UPPER_CASE=$(echo $environment | tr '[:lower:]' '[:upper:]')
FORECAST_POSTGRES_DB_PASSWORD=FORECAST_POSTGRES_PWD_$ENVIRONMENT_UPPER_CASE

sed -i "s/pwd: /pwd: ${!FORECAST_POSTGRES_DB_PASSWORD}/" "./charts/forecast-api/values-${cluster}.yaml"