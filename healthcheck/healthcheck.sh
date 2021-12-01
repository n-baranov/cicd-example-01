#!/bin/bash

# Arguments
LARAVEL_ENDPOINT=$1

Counter=1
echo "Waiting for the \"200\" response from Laravel. Attempt #$Counter of 60"
until [ $(curl -LI $LARAVEL_ENDPOINT -o /dev/null -w '%{http_code}\n' -s) == "200" ] || [ $Counter == 60 ]
do
  sleep 5
  ((Counter++))
  echo "Waiting for the \"200\" response from Laravel. Attempt #$Counter of 60"
done

if [ $Counter == 60 ]
then
  echo "-------------------- Something's wrong! This deployment is gonna be destroyed --------------------"
  exit 1
else
  echo "-------------------- This deployment is ok and it's gonna be destroyed --------------------"
fi
