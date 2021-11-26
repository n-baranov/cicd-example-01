#!/bin/bash

external_ip=""
while [ -z $external_ip ]; do
  echo "Waiting for the LB to up..."
  external_ip=$(kubectl get svc laravel-lb --output="jsonpath={.status.loadBalancer.ingress[0].hostname}")
  [ -z "$external_ip" ] && sleep 10
done
echo 'End point ready:'
echo $external_ip
