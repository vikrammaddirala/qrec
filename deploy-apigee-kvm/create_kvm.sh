#!/bin/bash

# Set variables
APIGEE_ORG="YOUR_APIGEE_ORGANIZATION"
APIGEE_ENV="dev"
BUILD_TOKEN="$(gcloud auth application-default print-access-token)"
KVM_PAYLOAD='{
    "name": "SampleKVM",
    "entry": [
        {
            "name": "COMPANY",
            "value": "example.com"
        },
        {
            "name": "LOCATION",
            "value": "San Francisco"
        }
    ]
}'

# Create KVM using curl
curl -X POST "https://apigee.googleapis.com/v1/organizations/${APIGEE_ORG}/environments/${APIGEE_ENV}/keyvaluemaps" \
    -H "Authorization: Bearer ${BUILD_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "${KVM_PAYLOAD}"
