+++
title = "Overview"
+++

# IPFS Cluster Overview

IPFS Cluster is a software to orchestrate IPFS daemons running on different hosts.

An IPFS Cluster is formed by a number of *Peers*, each of them associated to one IPFS daemon. The peers share a *pinset* (also known as *shared state*) which lists the *CIDs* which are cluster-pinned and their properties (allocations, replication factor etc.).

Cluster peers communicate using [libp2p](https://libp2p.io), similarly to IPFS, but separately from it. Thus, every cluster peer needs its own Private Key (different from the one used by the IPFS daemon) and has its own *Peer ID*. All peers share an additional *secret* key which ensures they can only communicate with known parties.

While IPFS Cluster is used by Protocol Labs to maintain and replicate a vast pinset, it is still software in **early stages of development**, and may suffer from bugs, usability, stability and documentation issues.

## Current features

The latest stable release of IPFS Cluster includes the following features:

* Every IPFS Cluster peer can control the cluster, modify the pinset and perform any operations. The consensus layer (Raft) ensures that all peers share the exact same state and that modifications obtain consistent results, provides high availability and protection against network splits.
* Pin replication is controlled by a maximum and minimum replication factor.
* Automatic re-pinning on downtime events.
* Evenly-distributed pins according to repository space of each IPFS daemon.
* Comprehensive configuration options, allowing for high-latency clusters (world-wide peers).
* Painless migration process between stable versions (with state format upgrades when necessary).
* Pin-set exports and imports (i.e. useful when moving data to a new cluster)
* Clusters can grow (new peers can be added) and decrease (peers can be removed) without need of downtime.
* RESTful API and offical Go API client provided. HTTPS, basic authentication and libp2p endpoint natively supported.
* The IPFS-proxy endpoint allows to drop-in cluster in place of the ipfs API. Some requests (like pin/add) are transmuted into cluster-pin requests.
* Runs independently from IPFS, using the go-ipfs API (usually on tcp/5001) to control the IPFS daemon.
* Extensive, up to date documentation and guides, including documentation focused on production deployments of IPFS and IPFS Cluster.

## Current limitations

These are the currently observed main problems and things lacking in ipfs-cluster (from what people expect). Be sure to check our [Roadmap](/roadmap) to see how and when we are planning to address them:

* As of now, IPFS Cluster does not support **collaborative pinning** with random individuals subscribing to a pinset and thus contributing their disk space to store interesting data.
* Unclear about the scalability limits:
  * Tested with 10 cluster peers on a global setup:
    * Repository size of around 70 GB/each
    * ~2000 pins/peer
  * Tested with 5 cluster peers on a regional setup
    * 44 TB disk
    * ~2400 entries in pinset
* `ipfs repo stat` is very slow on large repositories and hammers the disk, meaning collecting free-space metrics is slow and expensive too ([PR with fix](https://github.com/ipfs/go-ipfs/pull/5010)).
* No peer autodiscovery. Peers must be specified in a `peerset` file or be added to a known cluster peer (bootstrapping).

## Next steps: [Download](/documentation/download)
