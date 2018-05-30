+++
title = "ipfs-cluster-service"
+++


# ipfs-cluster-service


`ipfs-cluster-service` is the application that runs the IPFS Cluster peer.

## Usage

Usage, version information and a description can be obtained with:

```
$ ipfs-cluster-service --help
```

## Initialization

Before running `ipfs-cluster-service` for the first time, initialize a [configuration](/documentation/configuration) file with:

```
$ ipfs-cluster-service init
```

`init` will randomly generate a `secret` (unless specified by the `CLUSTER_SECRET` environment variable or running with `--custom-secret`, which will prompt it interactively).

**All peers in a cluster must share the same cluster secret**. Using an empty secret may compromise the security of your cluster.

You can specify a different configuration folder with the `--config` flag.

Please check the [Configuration section](/documentation/configuration) for more details about the IPFS Cluster configuration.

## Running the peer

You can start the peer by running `ipfs-cluster-service daemon`. Make sure to read the [Starting the Cluster](/documentation/starting) section for instructions on how to start a full cluster correctly, specially during the first boot.

## State tools

The `ipfs-cluster-service state` subcommands offers access to utilities to `export`, `import`, `cleanup`, `upgrade` and check the `version` of the cluster state. For more information see the [Upgrades section](/documentation/upgrades).

## Debugging

`ipfs-cluster-service` offers two debugging options:

* `--debug` enables debug logging from the `ipfs-cluster`, `go-libp2p-raft` and `go-libp2p-rpc` layers. This will be a very verbose log output, but at the same time it is the most informative.
* `--loglevel` sets the log level (`[error, warning, info, debug]`) for the `ipfs-cluster` only, allowing to get an overview of the what cluster is doing. The default log-level is `info`.


## Next steps: [`ipfs-cluster-ctl`](/documentation/ipfs-cluster-ctl)
