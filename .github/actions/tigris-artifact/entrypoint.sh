#!/bin/bash
set -e

OPERATION=$1
LOCAL_PATH=$2
REMOTE_PATH=$3

# Install AWS CLI if missing
if ! command -v aws &> /dev/null; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    sudo ./aws/install
fi

# Configure Tigris S3
aws configure set aws_access_key_id "${TIGRIS_ACCESS_KEY_ID}"
aws configure set aws_secret_access_key "${TIGRIS_SECRET_ACCESS_KEY}"
aws configure set default.region us-east-1
aws configure set default.s3.endpoint_url "${TIGRIS_ENDPOINT}"

# Perform operation
if [[ "$OPERATION" == "upload" ]]; then
    tar -czf /tmp/artifact.tar.gz -C "$LOCAL_PATH" .
    aws s3 cp /tmp/artifact.tar.gz s3://${TIGRIS_BUCKET}/$REMOTE_PATH
elif [[ "$OPERATION" == "download" ]]; then
    aws s3 cp s3://${TIGRIS_BUCKET}/$REMOTE_PATH /tmp/artifact.tar.gz
    mkdir -p "$LOCAL_PATH"
    tar -xzf /tmp/artifact.tar.gz -C "$LOCAL_PATH"
else
    echo "Invalid operation: $OPERATION. Use 'upload' or 'download'."
    exit 1
fi
