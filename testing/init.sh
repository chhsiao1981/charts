#!/bin/bash -e

cat > chrisomatic.yml << EOF
version: 1.2

on:
  cube_url: "$(just get-url)"
  chris_superuser:
    username: "$(just get-su username)"
    password: "$(just get-su password)"

cube:
  compute_resource:
    - name: host
      url: http://example.org/api/v1/
      username: pfcon
      password: pfcon1234
      description: "Does not work"
      innetwork: true
  plugins:
    - pl-dircopy
    - pl-tsdircopy
    - pl-topologicalcopy
    - pl-mri10yr06mo01da_normal
EOF
