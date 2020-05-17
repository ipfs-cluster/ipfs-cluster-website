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

Please read the [Download page](/download). It has instructions on how to build the software (please follow them).

## Debug logging

When discovering a problem, it is always useful to try to figure out the issue and potentially provide some relevant logs when asking for help.

### ipfs-cluster-service

By default, `ipfs-cluster-service` prints only `INFO`, `WARNING` and `ERROR` messages. You can increase the logging level in several ways:

* The `--debug` flag will set the `DEBUG` log level in ALL logging subsystems. This produces a lot of information and may even slow down your peer significantly. Do not use by default!
* The `--loglevel` allows fine-grain control of what components should log and what levels they should use. `--loglevel debug` makes all cluster-relevant components print `DEBUG` messages. This can be limited by component too: `--loglevel error,restapi:debug,pintracker:debug` will set the default log level to `ERROr`, while setting `DEBUG` on the `restapi` and the `pintracker` components.

Interpreting debug information can be tricky. Take this example:

```
2020-05-17T00:51:52.953+0200    ERROR   ipfshttp        ipfshttp/ipfshttp.go:722        Post "http://127.0.0.1:5001/api/v0/repo/stat?size-only=true": dial tcp 127.0.0.1:5001: connect: connection refused
```

The above line shows a message of `ERROR` severity, coming from the `ipfshttp` facility. It was logged in `ipfshttp/ipfshttp.go:722` (filename and line number) . This facility corresponds to the `ipfshttp` module which implements the IPFS Connector component. This information helps narrowing the context from which the error comes from. The error message indicates that the component failed to perform a GET request to the IPFS API.

Given all this context, we can figure out that very probably the ipfs daemon is not running, or not reachable.

When debugging, you can find out which component is producing the errors and then  use `--loglevel <component>:debug` to get more information about what that component is doing.

### ipfs-cluster-ctl

`ipfs-cluster-ctl` offers a `--debug` flag which will print information about the API endpoints used by the tool. `--enc json` allows to print raw `json` responses from the API.

### ipfs-cluster-follow

`ipfs-cluster-follow` does not include a way to increase verbosity. You can however run `ipfs-cluster-service -c <folder> daemon` where the `<folder>` is the `Config folder` as shown by `ipfs-cluster-follow <clusterName> info`. You can then increase verbosity as shown above. Only do this for debugging when necessary!

## Peer not starting

When your peer is not starting:

* Check the logs and look for errors
* Are all the listen addresses free or are they used by a different process?
* Are other peers of the cluster reachable?
* Is the `cluster.secret` the same for all peers?
* Double-check that the [`peerstore`](/documentation/deployment/setup#the-peerstore-file) file has the right content and that you've followed one of the methods in the [Bootstrapping the Cluster section](/documentation/deployment/bootstrap).
* Double-check that the rest of the cluster is in a healthy state.
* In some cases, it may help to run `ipfs-cluster-service state clean` (specially if the reason for not starting is a mismatch between the raft state and the cluster peers). Assuming that the cluster is healthy, this will allow the non-starting peer to pull a clean state from the cluster Leader when bootstrapping.

## Peer stopped unexpectedly

When a peer stops unexpectedly:

* Make sure you simply haven't removed the peer from the cluster or triggered a shutdown
* Check the logs for any clues that the process died because of an internal fault
* Check your system logs to find if anything external killed the process
* Report any application panics, as they should not happen, along with the logs

## `ipfs-cluster-ctl status <cid>` does not report CID information for all peers

This is usually the result of a [desync between the *shared state* and the *local state*](/documentation/guides/pinning), or between the *local state* and the ipfs state. If the problem does not autocorrect itself after a couple of minutes (thanks to auto-syncing), try running `ipfs-cluster-ctl sync [cid]` for the problematic item. You can also restart your node.

## libp2p errors

Since cluster is built on top of libp2p, many errors that new users face come from libp2p and have confusing messages which are not obvious at first sight. This list compiles some of them:

* `dial attempt failed: misdial to <peer.ID XXXXXX> through ....`: this means that the multiaddress you are contacting has a different peer in it than expected.
* `dial attempt failed: connection refused`: the peer is not running or not listening on the expected address/protocol/port.
* `dial attempt failed: context deadline exceeded`: this means that the address is not reachable or that the wrong secret is being used.
* `dial backoff`: same as above.
* `dial attempt failed: incoming message was too large`: this probably means that your cluster peers are not sharing the same secret.
* `version not supported`: this means that your nodes are running on incompatible versions.
