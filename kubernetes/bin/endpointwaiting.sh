#!/bin/bash

until [ -n "$(kubectl get services laravel-lb --output jsonpath='{.status.loadBalancer.ingress[0].hostname}')" ]; do
  sleep 10
done
