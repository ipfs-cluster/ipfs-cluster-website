+++
title = "Start the Cluster"
weight = 30
aliases = [
    "/documentation/starting"
]
+++

# Starting the Cluster

If you are here it means that you have successfully installed `ipfs-cluster-service` (to run a cluster peer) and `ipfs-cluster-ctl` (to interact with it) in one or several machines (using the same `secret` in the configuration for all of them). Congrats! These machines need to be running an IPFS daemon (`ipfs daemon`) as well, which must be started before starting the Cluster peers.

To start a single peer with the chosen consensus component, run:

```
ipfs-cluster-service daemon --consensus <crdt/raft>
```

**BUT**, unlike the IPFS daemon, which by default connects to the public IPFS network and can discover other peers in it by first connecting to a well known list of available bootstrappers, a Cluster peer runs on a private network and does not have any public peer to bootstrap to.

Thus, when starting IPFS Cluster peers **for the first time**, it is important to provide information so that they can discover the other peers and join the Cluster. Once a peer has successfully started once, it can be subsequently re-started with the command above. During shutdown, each peer's `peerstore` file will be updated to remember known addresses for other peers.

As we will see below, the **first start** has slightly different requirements depending on whether you will be running a [CRDT-based](/documentation/administration/consensus#crdt) or a [Raft-based](/documentation/administration/consensus#raft) Cluster. You can read more about the differences between the two in the [CRDT vs Raft](/documentation/administration/consensus#crdt-vs-raft-comparison) table.

<div class="tipbox warning">All peers in a Cluster must run in the same mode, either CRDT or Raft.</div>


## Starting a cluster with `--consensus crdt`

This is the easiest option to start a cluster because the only requirement a crdt-based peer has to become part of a Cluster is to contact at least one other peer. This can be achieved in several ways:

* Pre-filling the `peerstore` file with addresses for other peers ([as we saw in the previous section](/documentation/getting-started/setup/#the-peerstore-file)).
* Running with the `--bootstrap <peer-multiaddress1,peer-multiaddress2>` flag. Note that using this flag will automatically *trust* the given peers. For more information about trust, read the [CRDT section](/documentation/administration/consensus#crdt).
* In local networks with mDNS discovery support, peers will autodiscover each other and no additional measures are necessary.

<div class="tipbox warning">By default, crdt peers trust no other peers, and will ignore any pins submitted by other peers. Thus, you will need to set the <code>trusted_peers</code> configuration option appropriately in your peers. <a href="/documentation/administration/security#the-trusted-peers-in-crdt-mode">More information here</a>.</div>

_Example 1._ Starting the *first* peer in a CRDT-based Cluster:

```sh
ipfs-cluster-service daemon --consensus crdt
```

_Example 2._ Starting more peers in a CRDT-based cluster by customizing the peerstore. The given multiaddress corresponds to the first peer:

```sh
echo "/dns4/cluster1.domain/tcp/9096/ipfs/QmcQ5XvrSQ4DouNkQyQtEoLczbMr6D9bSenGy6WQUCQUBt" >> ~/.ipfs-cluster/peerstore
ipfs-cluster-service daemon --consensus crdt
```

_Example 3._ Starting more peers in a CRDT-based cluster using the `--bootstrap` flag. The given multiaddress corresponds to the first peer:

```sh
ipfs-cluster-service daemon --consensus crdt --bootstrap /dns4/cluster1.domain/tcp/9096/ipfs/QmcQ5XvrSQ4DouNkQyQtEoLczbMr6D9bSenGy6WQUCQUBt
```

## Starting a Cluster with `--consensus raft`

In Raft Clusters, the first start of a peer must not only contact a different peer, but also complete the task of becoming a member of the Raft Cluster. **Therefore the first start of a peer must always use the `--bootstrap` flag**:

_Example 1._ Starting the *first* peer in a Raft-based Cluster:

```sh
ipfs-cluster-service daemon --consensus raft
```

_Example 2._ Starting more peers in a Raft-based cluster. The given multiaddress corresponds to the first peer:

```sh
ipfs-cluster-service daemon --consensus raft --bootstrap /dns4/cluster1.domain/tcp/9096/ipfs/QmcQ5XvrSQ4DouNkQyQtEoLczbMr6D9bSenGy6WQUCQUBt
```

_Example 3._ Subsequent starts when the peer already successfully joined a Raft cluster before:

```sh
ipfs-cluster-service daemon --consensus raft
```

## Checking that it works

After starting your Cluster peers (especially the first time you are doing so), you should check that things are working correctly:

Check for errors in the logs. A successful peer start will print the "READY" message:

```text
INFO    cluster: ** IPFS Cluster is READY **
```

Run `ipfs-cluster-ctl id` to verify the details of your local Cluster peer. You should be able to see information for the Cluster peer and for the IPFS daemon it is connected to:

```sh
$ ipfs-cluster-ctl id
QmYY1ggjoew5eFrvkenTR3F4uWqtkBkmgfJk8g9Qqcwy51 | peername | Sees 3 other peers
  > Addresses:
    - /ip4/127.0.0.1/tcp/9096/ipfs/QmYY1ggjoew5eFrvkenTR3F4uWqtkBkmgfJk8g9Qqcwy51
    - /ip4/192.168.1.10/tcp/9096/ipfs/QmYY1ggjoew5eFrvkenTR3F4uWqtkBkmgfJk8g9Qqcwy51
  > IPFS: QmPFJcZfhFCmz1rAoew214h9d7Nv4aseqtCg5sm4fMdeYq
    - /ip4/127.0.0.1/tcp/4001/ipfs/QmPFJcZfhFCmz1rAoew214h9d7Nv4aseqtCg5sm4fMdeYq
    - /ip4/127.0.0.1/tcp/4002/ws/ipfs/QmPFJcZfhFCmz1rAoew214h9d7Nv4aseqtCg5sm4fMdeYq
    - /ip6/::1/tcp/4001/ipfs/QmPFJcZfhFCmz1rAoew214h9d7Nv4aseqtCg5sm4fMdeYq
    - /ip6/::1/tcp/4002/ws/ipfs/QmPFJcZfhFCmz1rAoew214h9d7Nv4aseqtCg5sm4fMdeYq
```

* CRDT Cluster peers may take a few minutes to discover additional peers in the Cluster (depending on how they were bootstrapped), even after the READY message.
* Raft Cluster peers will fail to start after a few seconds if they have not successfully joined or re-joined the Raft Cluster. The READY message indicates that the peer is fine, even though it may show errors when contacting other peers that are down.
