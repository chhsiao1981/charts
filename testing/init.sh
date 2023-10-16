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
    - name: $(just get-value .pfcon.name)
  plugins:
    - pl-mri10yr06mo01da_normal
EOF
