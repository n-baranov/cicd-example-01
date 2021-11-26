#!/bin/bash

# Fail fast
set -e

# Arguments
s3bucketname=$1
region=$2

if aws s3 ls "s3://$s3bucketname" 2>&1 | grep -q 'NoSuchBucket'
then
  echo "Bucket $s3bucketname doesn't exist. Creating it..."
  aws s3 mb s3://$s3bucketname --region=$region
fi
