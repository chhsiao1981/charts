#!/bin/bash -e

api='https://$\{KUBERNETES_SERVICE_HOST\}:$\{KUBERNETES_SERVICE_PORT_HTTPS\}'

printf '{'
for node in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'); do
  printf "%s%s/api/v1/nodes/%s/proxy/metrics/cadvisor" "$leading_comma" "$api" "$node"
  leading_comma=,
done
printf '}'
