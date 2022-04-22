+++
title = "Consensus components"
weight = 20
+++

# Consensus components

IPFS Cluster peers can be started using different choices for the implementations of some components. The most important one is the "consensus" one. The "consensus component" is in charge of:

* Managing the global cluster pinset by receiving modifications from other peers and publishing them.
* Managing the persistent storage of pinset-related data on disk.
* Achieving strong eventual consistency between all peers: all peers should converge to the same pinset.
* Managing the Cluster peerset: performing the necessary operation to add or remove peers from the Cluster.
* Setting peer trust: defining which peers are trusted to perform actions and access local RPC endpoints.

IPFS Cluster offers two "consensus component" options and the users are forced to make a choice when initializing a cluster peer by providing either `--consensus crdt` or `--consensus raft` to the `init` command.

For offline cluster pinset management check the [Data, backups and recovery section](/documentation/guides/backups).

## CRDT

`crdt` is the default implementation of the Cluster's "consensus component" based on an ipfs-powered distributed key-value store. It:

* Publishes updates to the pinset via libp2p-pubsub (GossipSub), locates and exchange data via [ipfs-lite](https://github.com/ipfs/ipfs-lite) (dht+bitswap).
* Stores all persistent data on a local BadgerDB datastore in the `.ipfs-cluster/badger` folder.
* Uses Merkle-CRDTs to obtain eventual consistency using [go-ds-crdt](https://github.com/ipfs/go-ds-crdt). These are append-only, immutable Merkle-DAGs. They cannot be compacted on normal conditions and new peers must discover and traverse them from the root, which might be a slow operation if the DAG is very deep.
* Does not need to perform any peerset management. Every peer for which we received "pings" via pubsub is considered a member of the Cluster until their last metric expires.
* Trusts peers as defined in the `trusted_peers` configuration option: only those peers can modify the pinset in the local peer and can access "trusted" RPC endpoints.
* Can optionally batch many pin/unpin operations on a single update, thus allowing scaling pin ingestion capabilities.


## Raft

`raft` is an implementation of the Cluster's "consensus component" based on Raft consensus. It:

* Publishes updates by connecting and sending them directly to every Cluster peer.
* Stores all persistent data on a local BoltDB store and on regular snapshots in the `.ipfs-cluster/raft` folder.
* Uses Raft-consensus implementation ([`hashicorp/raft`](https://github.com/hashicorp/raft) with a libp2p network transport) to obtain eventual consistency and protection of network partitions. Peerset views can be outdated in Raft, but they can never diverge in ways that need reconciliation. Raft-clusters elect a leader which is in charge of committing every entry to the log. For it to be valid, more than half of the peers in the cluster must acknowledge each operation. The append-only log can be consolidated and compacted into a snapshot which can be sent to new peers.
* Performs peerset management by making peerset changes (adding and removing peers) a commit operation in the Raft log, thus subjected to the limitations of them: an elected leader and more than half of the peers online.
* Trusts all peers. Any peer can request joining a Raft-based cluster and any peer can access RPC endpoints of others (as long as they know the Cluster `secret`).

## Choosing a consensus component

Choose CRDT when:

* You expect your cluster to work well with peers easily coming and going
* You plan to have follower peers without permissions to modify the pinset
* You do not have a fixed peer(s) for bootstrapping or you need to take advantage of mDNS autodiscovery
* The cluster needs to accommodate regular and heavy bursts of pinning/unpinning operations (batching support helps).

Choose Raft when:

* Your cluster peerset is stable (always the same peers, always running) and not updated frequently
* You need to stay on the safest side (Raft consensus is older, way more tested implementation)
* You cannot tolerate temporary partitions that result in divergent states
* You don't need any of the things CRDT mode provides

## CRDT vs Raft comparison

|CRDT | Raft|
|:----|:----|
|GossipSub broadcast | Explicit connection to everyone + acknowledgments|
|Trusted-peer support| All peers trusted|
|"Follower peers" and "Publisher peers" support | All peers are publishers |
|Peers can come and go freely| >50% must be online at all times or nothing works. Errors logged when someone is not online. |
|State size always grow|State size reduced after deletions|
|Cluster state Compaction only possible by taken a full cluster offline | Automatic compaction of the state|
|Potentially slow first-sync|Faster first-sync by sending full snapshot|
|Works with very large number of peers | Works with a small number of peers|
|Based on IPFS-tech (bitswap, dht, pubsub) | Based on hashicorp-tech (raft)|
|Strong Eventual Consistency: Pinsets can diverge until they are consolidated | Consensus: Pinsets can be outdated but never diverge |
|Fast pin ingestion with batching support|Slow pin ingestion|
|Pin committed != Pin arrived to most peers | Pin committed == pin arrived to most peers|
|Maximum tested size: 60M pins | 100k pins|
