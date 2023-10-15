# ![logo](./logo_chris.png) FNNDSC Helm Charts

[![Version](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2FFNNDSC%2Fcharts%2Fmaster%2Fcharts%2Fchris%2FChart.yaml&query=%24.version&label=version)](https://fnndsc.github.io/charts)
[![MIT License](https://img.shields.io/github/license/fnndsc/charts)](https://github.com/FNNDSC/charts/blob/main/LICENSE)
[![ci](https://github.com/FNNDSC/charts/actions/workflows/ci.yml/badge.svg)](https://github.com/FNNDSC/charts/actions/workflows/ci.yml)

Helm charts for the [FNNDSC](https://fnndsc.org) and the [_ChRIS_ Project](https://chrisproject.org).
_ChRIS_ is an open-source platform for medical compute.
The most important chart of this repository is [chris](./charts/chris), see its [README](./charts/chris/README.md) for more information.

## Development

If you already have Docker installed, the easiest way to obtain k8s is [KinD](https://kind.sigs.k8s.io/).
KinD installation instructions are here: https://kind.sigs.k8s.io/docs/user/quick-start/

Development scripts are defined in `testing/justfile`, which uses the [just](https://github.com/casey/just) syntax.
You should install `just`: https://github.com/casey/just#installation

Then you can run things like:

```shell
cd testing

just kind
just up
just wait
just test
```

Then, graceful tear down:

```shell
just down
just unkind
```
