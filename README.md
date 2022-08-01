# Seldon local development
Setting up Seldon local development on kind

## Prerequisites
- Install [docker](https://docs.docker.com/engine/install/)
- Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl)
- Install [istioctl](https://istio.io/latest/docs/setup/getting-started/#download)
- Install helm v3 `brew install helm`
- Install kind `brew install kind`

## Get started
- `make init, installing `kind cluster`, `cert-manager`, `istio`, `seldon-core`
- `make iris`, installing iris prediction
- `make test`, port-forward a service and sending a request to iris prediction endpoint

## See it to believe it
[![asciicast](https://asciinema.org/a/J5Ies2TySyE2uWmB8uqW8Q2hZ.svg)](https://asciinema.org/a/J5Ies2TySyE2uWmB8uqW8Q2hZ)
