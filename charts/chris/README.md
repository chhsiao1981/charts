# ![logo](./logo_chris.png) _ChRIS_ Helm Chart

[![Version](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2FFNNDSC%2Fcharts%2Fmaster%2Fcharts%2Fchris%2FChart.yaml&query=%24.version&label=version)](https://fnndsc.github.io/charts)
[![MIT License](https://img.shields.io/github/license/fnndsc/charts)](https://github.com/FNNDSC/charts/blob/main/LICENSE)
[![ci](https://github.com/FNNDSC/charts/actions/workflows/ci.yml/badge.svg)](https://github.com/FNNDSC/charts/actions/workflows/ci.yml)

Production deployment of [_ChRIS_](https://chrisproject.org/) on [_Kubernetes_](https://kubernetes.io/)
using [Helm](https://helm.sh/).

Documentation: https://chrisproject.org/docs/deployment

## Architecture

The [_ChRIS_ backend](https://github.com/FNNDSC/ChRIS_ultron_backEnd) is a Python Django application. It depends on a Postgres database, RabbitMQ, and several ancillary services (celery workers).
Postgres and RabbitMQ are created via subcharts packaged by Bitnami. The ancillary services are defined as Deployments.

The most important service is defined in `templates/server.yml`. This is the gunicorn web server which serves the HTTP API.
`templates/server.yml` defines `initContainers` to wait for the database to be ready and then run database migrations.
It also does some provisioning tasks such as [creating an admin user](#admin-user-creation).
The ancillary services also depend on the database migrations to be complete, so they all use `initContainers` which wait
for the server to be ready.

## Notes on Development

### Initial Secret Generation

On the initial installation of `chris`, we need to generate some secrets.
Ideas on how to do this were taken from here: https://github.com/helm/helm-www/issues/1259

### Choices and Limitations

- Currently, only filesystem storage is supported. Object storage is not supported.
- We chose bitnami/postgresql for the database. See also: [bitnami/postgresql-ha](https://github.com/bitnami/charts/tree/main/bitnami/postgresql-ha), [Crunchy PGO](https://github.com/CrunchyData/postgres-operator)
