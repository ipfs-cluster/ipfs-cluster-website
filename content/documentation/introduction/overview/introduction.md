+++
title = "Introduction"
weight = 100
+++

# IPFS Cluster Overview

IPFS Cluster is a software to orchestrate IPFS daemons running on different hosts.

<center><img alt="A typical IPFS Cluster" title="A typical IPFS Cluster" src="/cluster/diagrams/png/cluster.png" width="500px" /></center>

An IPFS Cluster is formed by a number of *Peers*, each of them associated to one IPFS daemon. The peers share a *pinset* (also known as *shared state*) which lists the *CIDs* which are cluster-pinned and their properties (allocations, replication factor etc.).

Cluster peers communicate using [libp2p](https://libp2p.io) (cluster swarm), similarly to IPFS, but separately from it. Thus, every cluster peer needs its own Private Key (different from the one used by the IPFS daemon) and has its own *Peer ID*. All peers share an additional *secret* key which ensures they can only communicate with known parties.

IPFS Cluster is used by Protocol Labs to maintain and replicate a large pinset, via integrations like the [IRC IPFS Pinbot](https://github.com/ipfs/pinbot-irc).

