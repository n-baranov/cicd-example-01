#!/bin/bash

# Arguments
LARAVEL_ENDPOINT=$1

Counter=1
echo "Waiting for the \"200\" from Laravel. Attempt #$Counter of 60"
until [ $(curl -LI $LARAVEL_ENDPOINT -o /dev/null -w '%{http_code}\n' -s) == "_200" ] || [ $Counter == 10 ]
do
  ((Counter++))
  echo "Waiting for the \"200\" response from Laravel. Attempt #$Counter of 10"
done

if [ $Counter == 10 ]
then
  echo "-------------------- Something's wrong. This deployment is not ok --------------------"
  exit 1
else
  echo "-------------------- This deployment is ok --------------------"
fi
