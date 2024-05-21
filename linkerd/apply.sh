#!/bin/bash

HERE="$(dirname "$(readlink -f "$0")")"

set -ex

kubectl apply -f "$HERE/pfdcm-profile.yml"
helm upgrade --install -n chris -f "$HERE/pfdcm-workaround-values.yaml" --version 0.1.0 pfdcm-linkerd-workaround fnndsc/linkerd-nodeport-workaround
