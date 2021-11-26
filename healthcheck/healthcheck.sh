#!/bin/bash

# Fail fast
set -e

# Arguments
LARAVEL_ENDPOINT=$1

Counter=0
until [ $(curl -LI $LARAVEL_ENDPOINT -o /dev/null -w '%{http_code}\n' -s) == "200" || $Counter -gt 60]; do sleep 10 && ((Counter++)); done

if curl $LARAVEL_ENDPOINT 2>&1 | grep -q 'Laravel'
then
  echo "-------------------- This deployment is ok --------------------"
else
  echo "-------------------- Something's wrong. This deployment is not ok --------------------"
fi
