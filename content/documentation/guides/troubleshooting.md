+++
title = "Troubleshooting"
weight = 80
aliases = [
    "/documentation/troubleshooting"
]
+++


# Troubleshooting

This sections contain a few tips to identify and correct problems when running IPFS Cluster.

## IPFS Cluster fails to build

Please read the [Download section](/documentation/getting-started/installation). It has instructions on how to build the software (please follow them).

## Debug logging

By default, `ipfs-cluster-service` prints only `INFO`, `WARNING` and `ERROR` messages. Sometimes, it is useful to increase verbosity with the `--loglevel debug` flag. This will make ipfs-cluster and its components much more verbose. The `--debug` flag will make ipfs-cluster, its components and its most prominent dependencies (raft, libp2p-raft, libp2p-gorpc) verbose.

`ipfs-cluster-ctl` offers a `--debug` flag which will print information about the API endpoints used by the tool. `--enc json` allows to print raw `json` responses from the API.

Interpreting debug information can be tricky. For example:

```
18:21:50.343 ERROR   ipfshttp: error getting:Get http://127.0.0.1:5001/api/v0/repo/stat: dial tcp 127.0.0.1:5001: getsockopt: connection refused ipfshttp.go:695
```

The above line shows a message of `ERROR` severity, coming from the `ipfshttp` facility. This facility corresponds to the `ipfshttp` module which implements the IPFS Connector component. This information helps narrowing the context from which the error comes from. The error message indicates that the component failed to perform a GET request to the ipfs HTTP API. The log entry contains the file and line-number in which the error was logged.

Given all this context, we can figure out that very probably the ipfs daemon is not running, or not reachable.

When discovering a problem, it is always useful if you can provide some logs when asking for help.

## Peer not starting

When your peer is not starting:

* Check the logs and look for errors
* Are all the listen addresses free or are they used by a different process?
* Are other peers of the cluster reachable?
* Is the `cluster.secret` the same for all peers?
* Double-check that the [`peerstore`](/documentation/getting-started/setup#the-peerstore-file) file has the right content and that you've followed one of the methods in the [Starting the Cluster section](/documentation/getting-started/start).
* Double-check that the rest of the cluster is in a healthy state.
* In some cases, it may help to run `ipfs-cluster-service state clean` (specially if the reason for not starting is a mismatch between the raft state and the cluster peers). Assuming that the cluster is healthy, this will allow the non-starting peer to pull a clean state from the cluster Leader when bootstrapping.

## Peer stopped unexpectedly

When a peer stops unexpectedly:

* Make sure you simply haven't removed the peer from the cluster or triggered a shutdown
* Check the logs for any clues that the process died because of an internal fault
* Check your system logs to find if anything external killed the process
* Report any application panics, as they should not happen, along with the logs

## `ipfs-cluster-ctl status <cid>` does not report CID information for all peers

This is usually the result of a [desync between the *shared state* and the *local state*](/documentation/reference/pinset), or between the *local state* and the ipfs state. If the problem does not autocorrect itself after a couple of minutes (thanks to auto-syncing), try running `ipfs-cluster-ctl sync [cid]` for the problematic item. You can also restart your node.

## libp2p errors

Since cluster is built on top of libp2p, many errors that new users face come from libp2p and have confusing messages which are not obvious at first sight. This list compiles some of them:

* `dial attempt failed: misdial to <peer.ID XXXXXX> through ....`: this means that the multiaddress you are contacting has a different peer in it than expected.
* `dial attempt failed: connection refused`: the peer is not running or not listening on the expected address/protocol/port.
* `dial attempt failed: context deadline exceeded`: this means that the address is not reachable or that the wrong secret is being used.
* `dial backoff`: same as above.
* `dial attempt failed: incoming message was too large`: this probably means that your cluster peers are not sharing the same secret.
* `version not supported`: this means that your nodes are running different versions of `ipfs-cluster-service`.
