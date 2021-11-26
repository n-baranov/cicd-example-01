#!/bin/bash

# Fail fast
set -e

# Arguments
build_folder=$1
aws_ecr_repository_url_with_tag=$2
dockerfile_name=$3

#aws ecr create-repository \
#--repository-name php-laravel \
#--image-scanning-configuration scanOnPush=true \
#--region ${region}

# Check if aws is installed
which aws > /dev/null || { echo 'ERROR: aws-cli is not installed' ; exit 1; }

# Connect to aws
$(aws ecr get-login --no-include-email) || { echo 'ERROR: aws ecr login failed' ; exit 1; }

# Check if docker is installed and running
which docker > /dev/null && docker ps > /dev/null || { echo 'ERROR: docker is not running' ; exit 1; }

# Build image
docker build -t $aws_ecr_repository_url_with_tag -f $dockerfile_name $build_folder

# Push image
docker push $aws_ecr_repository_url_with_tag
