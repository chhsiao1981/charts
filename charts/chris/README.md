# ![logo](./logo_chris.png) _ChRIS_ Helm Chart

[![Version](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2FFNNDSC%2Fcharts%2Fmaster%2Fcharts%2Fchris%2FChart.yaml&query=%24.version&label=version)](https://fnndsc.github.io/charts)
[![MIT License](https://img.shields.io/github/license/fnndsc/charts)](https://github.com/FNNDSC/charts/blob/main/LICENSE)
[![ci](https://github.com/FNNDSC/charts/actions/workflows/ci.yml/badge.svg)](https://github.com/FNNDSC/charts/actions/workflows/ci.yml)

Production deployment of [_ChRIS_](https://chrisproject.org/) on [_Kubernetes_](https://kubernetes.io/)
using [Helm](https://helm.sh/).

Documentation: https://chrisproject.org/docs/deployment

## Architecture

The [_ChRIS_ backend](https://github.com/FNNDSC/ChRIS_ultron_backEnd) is a Python Django application.
It depends on a Postgres database, RabbitMQ, and several ancillary services (celery workers).
Postgres and RabbitMQ are created via subcharts packaged by Bitnami. The ancillary services are defined as Deployments.

### `heart.yml`

The most important resources are defined in `templates/heart.yml`, which includes:

- The [celery beat](https://docs.celeryq.dev/en/stable/userguide/periodic-tasks.html) scheduler
- A `gunicorn` web server for the HTTP API, referred to in code and documentation as the "private server"
- initContainers to wait for the database to be ready, run database migrations, and "provisioning" steps such as creating [creating an admin user](#admin-user-creation)

Every _ChRIS_ backend service depends on the conditions of the initContainers defined in `heart.yml`,
hence the "private server" is used to notify other deployments that they are ready to start.

The celery beat process, database migrations, and provisioning _must not_ be replicated. Hence, `replicas: 1` is set.
This is the difference between the "private server" and the other `gunicorn` deployment defined in `templates/server.yml`.
The (not private) "server" from `templates/server.yml` is "scalable" and intended for ingress.

## Notes on Development

### Initial Secret Generation

On the initial installation of `chris`, we need to generate some secrets.
Ideas on how to do this were taken from here: https://github.com/helm/helm-www/issues/1259

### Choices and Limitations

- Currently, only filesystem storage is supported. Object storage is not supported.
- We chose bitnami/postgresql for the database. See also: [bitnami/postgresql-ha](https://github.com/bitnami/charts/tree/main/bitnami/postgresql-ha), [Crunchy PGO](https://github.com/CrunchyData/postgres-operator)
