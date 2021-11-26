#!/bin/bash

# Fail fast
set -e

# Arguments
LARAVEL_ENDPOINT=$1

if curl $LARAVEL_ENDPOINT 2>&1 | grep -q 'Laravel'
then
   echo "-------------------- This deployment is ok --------------------"
else
   echo "-------------------- Something's wrong. This deployment is not ok --------------------"
fi
