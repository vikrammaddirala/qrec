#!/bin/bash

# Loop through each proxy and export, then import to the destination project and environment
gcloud apigee apis list --project=$1 --environment=$2 --format="value(name)" |
while read -r PROXY; do
  echo "Processing proxy: $PROXY"
  
  # Export the proxy
  gcloud apigee apis export --project=$1 --environment=$2 --api=$PROXY --output="${PROXY}.zip"
  
  # Import the proxy to the destination project
  gcloud apigee apis import --project=$3 --environment=$4 --api=$PROXY --file="${PROXY}.zip"
  
  echo "Uploaded proxy: $PROXY to project: $3 environment: $4"
done
