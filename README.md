# ![logo](./logo_chris.png) khris-helm

[![Version](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2FFNNDSC%2Fkhris-helm%2Fmaster%2Fcharts%2Fchris-cube%2FChart.yaml&query=%24.version&label=version)](https://fnndsc.github.io/khris-helm)
[![MIT License](https://img.shields.io/github/license/fnndsc/khris-helm)](https://github.com/FNNDSC/khris-helm/blob/main/LICENSE)
[![ci](https://github.com/FNNDSC/khris-helm/actions/workflows/ci.yml/badge.svg)](https://github.com/FNNDSC/khris-helm/actions/workflows/ci.yml)

Production deployment of [_ChRIS_](https://chrisproject.org/) on [_Kubernetes_](https://kubernetes.io/)
using [Helm](https://helm.sh/).

_ChRIS_ is an open-source platform for medical compute. Learn more at https://chrisproject.org

## What's in the box?

This repository provides `chris-cube`, a chart which deploys the _ChRIS_ backend a.k.a. "CUBE."

### Batteries Not Included

`chris-cube` is one part of a software platform. In descending order of importance, one should also deploy/use:

- [pfcon](https://github.com/FNNDSC/pfcon) and [pman](https://github.com/FNNDSC/pman), which provide compute to _CUBE_ (kustomize and/or Helm repo coming soon!).
- [ChRIS\_ui](https://github.com/FNNDSC/ChRIS_ui), a web-app graphical user interface for _ChRIS_
- [`chrisomatic`](https://github.com/FNNDSC/chrisomatic), a command-line tool for provisioning _CUBE_

### Limitations

Currently, `chris-cube` only supports single-replicas, file storage using a volume instead of object storage,
and deployment of Postgres using [`docker.io/library/postgres`](https://hub.docker.com/_/postgres). `chris-cube`
is not HA nor does it have a back-up solution ootb. See the [Roadmap](#roadmap) section.

## Installation

You'll need a Kubernetes (k8s) cluster and a [storage class](https://kubernetes.io/docs/concepts/storage/storage-classes/).

On the client, install `helm`: https://helm.sh/docs/intro/install/

Once Helm has been set up correctly, add the repo as follows:

```shell
helm repo add fnndsc https://fnndsc.github.io/charts
```

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages.  You can then run `helm search repo fnndsc-khris` to see the charts.

To install the `chris-cube` chart, download a copy of [values.yaml](./charts/chris-cube/values.yaml)
and modify its values to suit your needs. Then run

```shell
helm install -n cube -f my-values.yaml my-cube-instance fnndsc/chris-cube
```

To uninstall the chart:

```shell
helm delete -n cube my-cube-instance
```

### NFS Server Workarounds

A NFS-based storage class (for instance, using [nfs-subdir-external-provisioner](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner))
could require that all (stateful) containers run as a user with a specific UID. This can be achieved by specifying a value for `securityContext`.

Currently, the image `docker.io/fnndsc/cube` needs to be rebuilt in order for it to work with a custom UID.

```shell
docker build -t internal.registry/fnndsc/cube:latest --build-arg UID=123456 https://github.com/FNNDSC/ChRIS_ultron_backEnd.git
docker push internal.registry/fnndsc/cube:latest
```

Alternatively, using OpenShift BuildConfigs:

```shell
oc new-build https://github.com/FNNDSC/ChRIS_ultron_backEnd --build-arg=UID=1001090000 --name=cube
```

`values.yaml` should have the corresponding values set:

```yaml
image: internal.registry/fnndsc/cube:latest

securityContext:
  runAsUser: 123456
  runAsGroup: 789
```

## Development

If you already have Docker installed, the easiest way to obtain k8s is [KinD](https://kind.sigs.k8s.io/).
[Install `kind`](https://kind.sigs.k8s.io/docs/user/quick-start/) then run

```shell
kind create cluster --config=testing/kind-with-nodeport.yml
```

### Initial Secret Generation

On the initial installation of `chris-cube`, we need to generate some secrets.
Ideas on how to do this were taken from here: https://github.com/helm/helm-www/issues/1259

### Roadmap

- [ ] CUBE image should support arbitrary UIDs: https://github.com/FNNDSC/ChRIS_ultron_backEnd/issues/514
- [ ] Support [Crunchy Postgres Operator (PGO)](https://github.com/CrunchyData/postgres-operator/)
- [ ] Support object storage for _ChRIS_ files storage, e.g. [OpenStack Swift](https://wiki.openstack.org/wiki/Swift), [NooBaa](https://www.noobaa.io/)

With PGO and object storage support, we won't need to request PVCs directly.
