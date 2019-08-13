+++
title = "IPFS Cluster"
+++

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
