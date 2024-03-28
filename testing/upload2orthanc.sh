#!/bin/bash
# Purpose: upload a directory of DICOMs to Orthanc.

if ! [ -d "$1" ]; then
  echo "Must give a directory of DICOM files."
  exit 1
fi

port=$(kubectl get service -n kk -l app.kubernetes.io/name=orthanc -o jsonpath='{.items[0].spec.ports[0].nodePort}')
cpus=$(kubectl get pod -n kk -l app.kubernetes.io/name=orthanc -o jsonpath='{.items[0].spec.containers[0].resources.requests.cpu}')
auth="$(helm get values -n kk cacao -o json | jq -r '.orthanc.config.registeredUsers | to_entries | .[0] | .key + ":" + .value')"

find -L "$1" -type f -name '*.dcm' \
  | parallel --bar -j $cpus "curl -u '$auth' -sSfX POST http://localhost:$port/instances -H Expect: -H 'Content-Type: application/dicom' -T {} -o /dev/null"
