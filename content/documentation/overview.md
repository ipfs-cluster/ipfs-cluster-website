+++
title = "Overview"
+++

# IPFS Cluster Overview

IPFS Cluster is a software to orchestrate IPFS daemons running on different hosts.

<center><img alt="A typical IPFS Cluster" title="A typical IPFS Cluster" src="/cluster/diagrams/png/cluster.png" width="500px" /></center>

An IPFS Cluster is formed by a number of *Peers*, each of them associated to one IPFS daemon. The peers share a *pinset* (also known as *shared state*) which lists the *CIDs* which are cluster-pinned and their properties (allocations, replication factor etc.).

Cluster peers communicate using [libp2p](https://libp2p.io) (cluster swarm), similarly to IPFS, but separately from it. Thus, every cluster peer needs its own Private Key (different from the one used by the IPFS daemon) and has its own *Peer ID*. All peers share an additional *secret* key which ensures they can only communicate with known parties.

IPFS Cluster is used by Protocol Labs to maintain and replicate a large pinset, via integrations like the [IRC IPFS Pinbot](https://github.com/ipfs/pinbot-irc).

## Current features

The latest stable release of IPFS Cluster includes the following features:

* Directly adding, replicating and pinning content to multiple IPFS peers at once, via Cluster.
* Fetching and pinning content in multiple IPFS peers via Cluster.
* Raft-based consensus layer with protection against network splits and automatic leader redirection: Every IPFS Cluster peer can control the cluster, modify the pinset and perform any operations.
* Maximum and minimum replication factor for content pinned in IPFS Cluster.
* Automatic re-pinning on downtime events.
* Evenly-distributed pins according to repository space of each IPFS daemon.
* Comprehensive configuration options, allowing for high-latency clusters (world-wide peers).
* Painless migration process between stable versions (with state format upgrades when necessary).
* Pin-set exports and imports (i.e. useful when moving data to a new cluster)
* Clusters can grow (new peers can be added) and decrease (peers can be removed) without need of downtime.
* DHT-routing for Cluster peers. DNS-multiaddresses support.
* RESTful API exposed both on HTTP and libp2p endpoints (http tunneled on libp2p). HTTPs and basic authentication supported.
* Go API client with full support of all API endpoints and modes.
* IPFS-proxy, and HTTP endpoint allows to drop-in IPFS Cluster in place of the ipfs API. Some requests are intercepted and trigger cluster operations (like pin/add).
* Runs independently from IPFS, using the go-ipfs API (usually on tcp/5001) to control the IPFS daemon.
* Extensive, up to date documentation and guides, including documentation focused on production deployments of IPFS and IPFS Cluster.

## Current limitations

These are the currently observed main problems and things lacking in IPFS Cluster (from what people expect). Be sure to check our [Roadmap](/roadmap) to see how and when we are planning to address them:

* As of now, IPFS Cluster does not support **collaborative pinning** with random individuals subscribing to a pinset and thus contributing their disk space to store interesting data.
* Unclear about the scalability limits:
  * Tested with 10 cluster peers on a global setup:
    * Repository size of around 70 GB/each
    * ~2000 pins/peer
  * Tested with 5 cluster peers on a regional setup
    * 44 TB disk
    * ~5000 entries in pinset
* No public bootstrappers. New peers need to bootstrap to an existing Cluster peer.

## Next steps: [Download](/download)
