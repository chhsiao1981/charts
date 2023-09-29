# ![logo](./logo_chris.png) FNNDSC Helm Charts

[![Version](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2FFNNDSC%2Fcharts%2Fmaster%2Fcharts%2Fchris%2FChart.yaml&query=%24.version&label=version)](https://fnndsc.github.io/charts)
[![MIT License](https://img.shields.io/github/license/fnndsc/charts)](https://github.com/FNNDSC/charts/blob/main/LICENSE)
[![ci](https://github.com/FNNDSC/charts/actions/workflows/ci.yml/badge.svg)](https://github.com/FNNDSC/charts/actions/workflows/ci.yml)

Production deployment of [_ChRIS_](https://chrisproject.org/) on [_Kubernetes_](https://kubernetes.io/)
using [Helm](https://helm.sh/).

_ChRIS_ is an open-source platform for medical compute. Learn more at https://chrisproject.org

Documentation: https://chrisproject.org/docs/deployment

## Development

If you already have Docker installed, the easiest way to obtain k8s is [KinD](https://kind.sigs.k8s.io/).
[Install `kind`](https://kind.sigs.k8s.io/docs/user/quick-start/) then run

```shell
kind create cluster --config=testing/kind-with-nodeport.yml
```

### Initial Secret Generation

On the initial installation of `chris-cube`, we need to generate some secrets.
Ideas on how to do this were taken from here: https://github.com/helm/helm-www/issues/1259

### Choices and Limitations

- Currently, only filesystem storage is supported. Object storage is not supported.
- We chose bitnami/postgresql for the database. See also: [bitnami/postgresql-ha](https://github.com/bitnami/charts/tree/main/bitnami/postgresql-ha), [Crunchy PGO](https://github.com/CrunchyData/postgres-operator)
