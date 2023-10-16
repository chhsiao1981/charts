#!/bin/bash -e
# get logs within the last hour from OpenObserve for a pod given its app.kubernetes.io/name label

now="$(($(date +%s)*1000000))"
hour=3600000000

set -x
xh -a 'dev@babymri.org:chris1234' POST http://localhost:32020/api/default/_search type==logs \
    'query[start_time]':="$((now-hour))" \
    'query[end_time]':="$now" \
    'query[from]':=0 \
    'query[size]':=1000000 \
    'query[sql]'="select * from \"k8s\" WHERE kubernetes_pod_labels_app_kubernetes_io_name='$1'" \
    | jq -r '.hits[] | .kubernetes_container_name + "\t" + .message' \
    | tac
