+++
title = "IPFS Cluster"
+++

**TODO: This needs a high-level explanation of what Cluster is, for both a CTO and our other users. We need to turn our Features list into marketing-speak, more like the libp2p homepage.**

## **IPFS Cluster is software built on top of <a href="https://ipfs.io/">IPFS</a> that automates data redundancy and availability**

...even on a network such as IPFS that supports peers dropping in and out at will.

IPFS Cluster can:

* Enable shared "pinsets" across multiple IPFS nodes
* Support production deployments of IPFS in datacenters
* Support large volumes of data on IPFS, where a full DAG does not fit in a single IPFS node
* Enable collaborative storage efforts to backup data on IPFS

## Gimme the details

<center><img alt="A typical IPFS Cluster" title="A typical IPFS Cluster" src="/cluster/diagrams/png/cluster.png" width="500px" /></center>

A Cluster is formed by a number of *Peers*, each of them associated to one IPFS daemon. The peers share a *global pinset* which stores the *CIDs* for content which is cluster-pinned and their properties (allocations, replication factor, etc). Cluster peers instruct IPFS daemons to fetch and pin that content.

Cluster peers communicate using [libp2p](https://libp2p.io) (cluster swarm), similar to IPFS, but separately from it. Thus, every cluster peer needs its own Private Key (different from the one used by the IPFS daemon) and has its own *Peer ID*.

## Features

The latest stable release of IPFS Cluster includes the following features:

* Directly adding, replicating and pinning content to multiple IPFS peers at once.
* Fetching and pinning content in multiple IPFS peers.
* [Raft-based](/documentation/guides/consensus#raft) consensus layer with protection against network splits and automatic leader redirection: Every IPFS Cluster peer can control the cluster, modify the pinset and perform any operations.
* [CRDT-based](/documentation/guides/consensus#crdt) offers full flexibility and scales to hundreds of peers.
* Maximum and minimum replication factor for content pinned in IPFS Cluster.
* Automatic re-pinning on downtime events.
* Evenly-distributed pins according to repository free space of each IPFS daemon. Pin allocations can also be manually set.
* Name and any custom metadata can be attached to every Pinned item.
* Comprehensive configuration options, allowing for high-latency clusters (world-wide peers).
* Painless migration process between stable versions (with state format upgrades when necessary).
* Pin-set exports and imports (i.e. useful when moving data to a new cluster)
* Clusters can grow (new peers can be added) and decrease (peers can be removed) without need of downtime.
* DHT-routing for Cluster peers. DNS-multiaddresses support. mDNS discovery.
* RESTful API exposed both on HTTP and libp2p endpoints (http tunneled on libp2p). HTTPs and basic authentication supported, along with full CORS support.
* Go API client with full support of all API endpoints and modes.
* IPFS-proxy, and HTTP endpoint allows to drop-in IPFS Cluster in place of the IPFS API. Some requests are intercepted and trigger cluster operations (like pin/add). IPFS API headers are mimicked automatically.
* Runs independently from IPFS, using the go-ipfs API (usually on tcp/5001) to control the IPFS daemon.
* Metric exporting (Prometheus) and tracing (Jaeger).
* Ansible roles, Kustomize resources (for Kubernetes), Docker container and Docker-compose templates are available to facilitate deployment.
* Extensive, up to date documentation and guides, including documentation focused on production deployments of IPFS and IPFS Cluster.

## Current limitations

These are the currently observed main problems and things lacking in IPFS Cluster (from what people expect). Be sure to check our [roadmap](/documentation/roadmap/) to see how and when we are planning to address them:

* Unclear about the scalability limits:
  * Tested with 10 cluster peers on a global setup:
    * Repository size of around 70 GB/each
    * ~2000 pins/peer
  * Tested with 5 cluster peers on a regional setup
    * 44 TB disk
    * ~7000 entries in pinset
* The `crdt` consensus option is new and needs to be tested and improved.
