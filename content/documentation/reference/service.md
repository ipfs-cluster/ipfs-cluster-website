+++
title = "ipfs-cluster-service"
weight = 40
aliases = [
    "/documentation/ipfs-cluster-service"
]
+++

# `ipfs-cluster-service`

The `ipfs-cluster-service` is a command line application that runs a full cluster peer:

* [`ipfs-cluster-service init` initializes configuration and identity](/documentation/getting-started/setup).
* [`ipfs-cluster-service daemon` launches a cluster peer](/documentation/getting-started/start).
* [`ipfs-cluster-service state` allows to export, import, and cleanup the persistent state](/documentation/administration/backups).

The `ipfs-cluster-service` provides its own help by running `ipfs-cluster-service --help` or `ipfs-cluster-service <command> --help`.

## Debugging

`ipfs-cluster-service` offers two debugging options:

* `--debug` enables debug logging from the `ipfs-cluster`, `go-libp2p-raft` and `go-libp2p-rpc` layers. This will be a very verbose log output, but at the same time it is the most informative.
* `--loglevel` sets the log level (`[error, warning, info, debug]`) for the `ipfs-cluster` only, allowing to get an overview of the what cluster is doing. The default log-level is `info`.

By default, logs are coloured. To disable log colours set the `IPFS_LOGGING_FMT` environment variable to `nocolor`.

## Download

To download `ipfs-cluster-service` check the [downloads page](/documentation/installation).
