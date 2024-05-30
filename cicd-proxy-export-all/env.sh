# Authenticate with Google Cloud
gcloud auth login
gcloud config set project apigee-x-379708

# Set environment variables
PROXY_NAME=helloworld
REVISION=8
ORG=default-dev
HOSTNAME=34.117.73.180.nip.io
BUCKET_NAME=proxy-storage-01

# Export the proxy from the source environment
curl -X GET \
  "https://$HOSTNAME/v1/organizations/$ORG/apis/$PROXY_NAME/revisions/$REVISION?format=bundle" \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -o $PROXY_NAME-$REVISION.zip

# Upload the proxy bundle to Google Cloud Storage
gsutil cp $PROXY_NAME-$REVISION.zip gs://$BUCKET_NAME/
