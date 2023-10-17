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

Optionally, to use [_chrisomatic_](https://github.com/FNNDSC/chrisomatic):

```shell
just chrisomatic
```

Then, graceful tear down:

```shell
just down
just unkind
```

### Observability

Optionally, logs can be collected using [Vector](https://vector.dev/)
and visualized using [OpenObserve](https://openobserve.ai/).
To run the observability stack and open the dashboard, run

```shell
just observe
```

Log in with the email `dev@babymri.org` password `chris1234`.

Alternatively, you can get logs from the command-line using the `just olog [POD_NAME_LABEL]` command.
Examples:

```shell
just olog pfcon

just olog chris-heart
```

## How It Works

Two releases of Vector are made:

- "Agent" mode which runs on every node to collect logs and host metrics
- "Stateless-Aggregator" which scrapes Kubelet `/metrics/cadvisor`

These logs and metrics are shipped to OpenObserve.
