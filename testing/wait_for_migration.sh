#!/bin/bash
# Blocks until database migrations are complete.
# If migrations were previously successful, then script exits normally.
# If migrations fail, the script exits with failure.

SELECTOR='app.kubernetes.io/name=cube-server'

while getopts ":n:" opt; do
  case $opt in
  n   ) namespace="--namespace $OPTARG" ;;
  esac
done

if [ -v GITHUB_ACTION ]; then
  ERROR_PREFIX='::error ::'
else
  ERROR_PREFIX="$(tput setaf 1)ERROR$(tput sgr0): "
fi

function get_state () {
  kubectl get pod $namespace -l "$SELECTOR" --template \
    '{{ with (index .items 0).status.initContainerStatuses }}{{ range $k, $v := (index . 0).state }}{{$k}}{{end}}{{else}}empty{{end}}'
}

state=$(get_state)
until [ "$state" = 'terminated' ]; do
  sleep 1
  printf .
  state=$(get_state)
  if [ "$state" = 'running' ]; then
    kubectl logs $namespace -l "$SELECTOR" -c migratedb --follow
  fi
done
echo

reason=$(
  kubectl get pod $namespace -l "$SELECTOR" --template \
    '{{ (index (index .items 0).status.initContainerStatuses 0).state.terminated.reason }}'
)
if [ "$reason" != 'Completed' ]; then
  echo "${ERROR_PREFIX}expected initContainer to be terminated with reason 'Completed', is instead '$reason'"
  set -ex
  kubectl get pod $namespace -l "$SELECTOR" --template \
    '{{ (index (index .items 0).status.initContainerStatuses 0).state }}'
  exit 1
fi
