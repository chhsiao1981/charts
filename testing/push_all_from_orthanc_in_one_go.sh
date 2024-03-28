#!/bin/bash

port=$(kubectl get service -n kk -l app.kubernetes.io/name=orthanc -o jsonpath='{.items[0].spec.ports[0].nodePort}')
auth="$(helm get values -n kk cacao -o json | jq -r '.orthanc.config.registeredUsers | to_entries | .[0] | .key + ":" + .value')"

exec curl -fu "$auth" http://localhost:$port/modalities/ChRIS/store --data "{
  \"Resources\": $(curl -fsSu "$auth" http://localhost:$port/series),
  \"Synchronous\": false
}"
