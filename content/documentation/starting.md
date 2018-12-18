+++
title = "Starting the Cluster"
+++


# Starting the Cluster

Starting a IPFS Cluster peers for the first time is a simple process but it must be we well understood as it is one of the places where most mistakes happen.

<div class="tipbox tip"><code>ipfs-cluster-service daemon</code> starts a cluster peer, but we have to make sure the peer correctly participates and is seen by the rest of the Cluster.</div>

Most considerations when starting a cluster depend on the choice of *Consensus* component. Currently, the only available *Consensus* implementation is `raft`.

## Raft

`raft` implementation is very strict about the initialization and maintainance of the **peerset**. The *peerset* is the list of peers that make up a Cluster.

When using the `raft` component, there are two main methods when **starting the cluster peers for the first time**:

* Starting multiple peers with a fixed peerset
* Starting a single peer and bootstrapping the rest to it

Raft stores and maintains the *peerset* internally, so once the first start has been successful, any further starts are are simple as running `ipfs-cluster-service daemon`.

### Starting multiple peers with a fixed peerset

This is the recommended way to start a cluster **for the first time**. This is mostly useful when:

* Working with stable cluster peers, running in known locations
* Working with some [automated deployments](/documentation/deployment)
* You are able to trigger start for all peers in the cluster with ease

<div class="tipbox warning"> Important: Do not use this method when you need a new peer to join an already running Cluster. If the new peer is not part of the running Cluster's peerset, use the <code>--bootstrap</code> method to add it.</div>

#### Requirements

* `ipfs-cluster-service` and `ipfs` are installed in all your hosts.
* `ipfs` is running (or is started at the same time).
* The [`peerstore`](/documentation/configuration/#the-peerstore-file) file has been created in all peers, containing the multiaddress of at least one other peer.
* The [`init_peerset`](/documentation/configuration/#raft) configuration key lists all the peer-IDs in the cluster (not multiaddresses).
* The value of `init_peerset` should be the same in all peers.
* You can start the majority of the peers within `raft.wait_for_leader_timeout`. Otherwise startup will fail.

#### Procedure

Run the following in all your peers (preferably at once):

```
$ ipfs-cluster-service daemon
```

will start the cluster peer:

* `raft` will be initialized with the `init_peerset`.
* all peers will know how to talk to the others thanks to the addresses in the `peerstore` or using a DHT service for service discovery.
* Peers will elect a Raft Leader and then become `Ready`.
* upon error, you can always re-run `ipfs-cluster-service daemon`.


### Starting a single peer and bootstrapping the rest to it

A different, more flexible approach is to start a single peer and then *bootstrap* other peers to it. As they are bootstrapped, the Cluster will grow with the new peers. This bootstrapping needs to happen the first time the other peers are started for them to become part of the same cluster.

This is mostly useful when:

* You are building your cluster manually, or you are adding new peers to it
* You don't know the IPs or ports your peers will listen to (other than the first). Note that `/dns4/` and `/dns6` addresses in the `peerstore` file are supported.

<div class="tipbox tip">This method is demonstrated in the <a href="/documentation/quickstart">Quickstart guide</a>.</div>

#### Requirements

* `ipfs-cluster-service` and `ipfs` are installed in all your hosts.
* `ipfs` is running (or is started at the same time).
* No need for the `peerstore` file or the `init_peerset`.

#### Procedure

First start one of the peers with:

```
$ ipfs-cluster-service daemon
```

Then **bootstrap each of the other peers** as explained in the [section below](#bootstrapping-a-peer):

### Bootstrapping a peer

Bootstrapping is the means to safely add peers to a Cluster:

```
$ ipfs-cluster-service daemon --bootstrap <multiaddress of first peer>
```

This will bootstrap the peer to an existing one:

* Cleanup any pre-existing raft state.
* Request to be added to the *peerset*.
* Receive the peerset and the addresses for all other peers.
* The `peerstore` file will be created and gets populated with peers addresses for other peers.
* The Cluster state is received by the new peer.
* When the full state has been received, the new peer becomes `Ready`.

<div class="tipbox warning">Adding peers only works on healthy clusters, with most of their peers online.</div>

Note that once your peer has bootstrapped once to the cluster, you can just start it normally with `ipfs-cluster-service daemon` the next time.


### Restarting clusters and peers

Once your peers have been running restarts are as simple as running:

```
$ ipfs-cluster-service daemon
```

<div class="tipbox warning"> Important: Re-starting a peer with `--bootstrap` is not recommended unless it has been removed from the Cluster peerset.</div>

### Verifying a good start

The best way to verify your Cluster is up and running correctly is to:

* Run and examine the output `ipfs-cluster-ctl peers ls`: it should list all peers, and all peers should *see* the same number of other peers.
* Check the log outputs.


## Next steps: [Production deployments](/documentation/deployment)
