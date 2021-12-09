+++
title = "ipfs-cluster-follow"
weight = 40
aliases = []
+++

# `ipfs-cluster-follow`

The `ipfs-cluster-follow` command line application is a user-friendly way of running follower peers to join collaborative IPFS Clusters. You can obtain more information about collaborative clusters in the [respective section](/documentation/collaborative).

`ipfs-cluster-follow` runs an optimized cluster peer for use with collaborative cluster. It focuses on simplicity and security for users running follower peers, removing most of the configuration hassles that running a peer has.

## Configuration

`ipfs-cluster-follow` normally uses configurations distributed through the local IPFS gateway as templates.

In this case, the `service.json` file for each configured cluster contains a single `source` key pointing to a URL, which is read when starting the peer.

This file can be replaced by a custom `service.json` file. Alternatively, every configuration value can be overridden with environment variables as explained in the [configuration reference](/documentation/reference/configuration#using-environment-variables-to-overwrite-configuration-values). The `IPFS_GATEWAY` environmental variable can be used to set the gateway location if it's not the default (`127.0.0.1:8080`).

If you need to expose the HTTP API on a TCP port rather than the default unix socket, set `CLUSTER_RESTAPI_HTTPLISTENMULTIADDRESS` accordingly.

## Using `ipfs-cluster-ctl` with `ipfs-cluster-follow`

`ipfs-cluster-follow` exposes an API endpoint using, by default, a unix socket, rather than listening on a local TCP port.

If you wish to talk to the peer using `ipfs-cluster-ctl`, you can run:

```sh
ipfs-cluster-ctl --host /unix//<home_path>/.ipfs-cluster-follow/<clusterName>/api-socket ...
```

## Usage

Usage information can be obtained by running:

```
$ ipfs-cluster-follow --help
```

## Finding collaborative clusters to join

Visit [collab.ipfscluster.io](https://collab.ipfscluster.io) for a list of collaborative clusters that you can join and more instructions.



`ipfs-cluster-ctl --host /ip4/<ip>/ipfs/<peerID> ...`

or

`ipfs-cluster-ctl --host /dnsaddr/mydomain.com ...` (setting a `_dnsaddr TXT dnsaddr=peer_multiaddress` field in your dns).

If the libp2p peer you're contacting is using a *cluster secret* (a private networks key), you will also need to provide `--secret <32 byte-hex-encoded key>` to the command.

We recommend that you alias the `ipfs-cluster-ctl` command in your shell to something shorter and with the right global options.

## Download

To download `ipfs-cluster-follow` check the [downloads page](/download).
