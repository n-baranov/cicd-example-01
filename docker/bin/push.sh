#!/bin/bash

# Fail fast
set -e

# Arguments
aws_ecr_repository_url_with_tag=$1
region=$2

if ( ! aws ecr describe-repositories | grep php-laravel )
then
   aws ecr create-repository \
   --repository-name php-laravel \
   --image-scanning-configuration scanOnPush=false \
   --region $region
fi

# Push image
docker push $aws_ecr_repository_url_with_tag
