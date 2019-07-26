+++
title = "Docs"
weight = 10
aliases = [
    "/developer/",
    "/guides/"
]
+++

# Documentation

Welcome to the IPFS Cluster documentation section.

<div class="tipbox tip">Updated to version <a href="https://github.com/ipfs/ipfs-cluster/blob/master/CHANGELOG.md">0.11.0 (see the Changelog)</a>.</div>

## What is IPFS Cluster?

IPFS Cluster is a software to orchestrate IPFS daemons running on different hosts and using a shared pinset for all of them.

<center><img alt="A typical IPFS Cluster" title="A typical IPFS Cluster" src="/cluster/diagrams/png/cluster.png" width="500px" /></center>

A Cluster is formed by a number of *Peers*, each of them associated to one IPFS daemon. The peers share a *global pinset* which stores the *CIDs* for content which is cluster-pinned and their properties (allocations, replication factor etc.). Cluster peers instruct IPFS daemons to fetch and pin that content.

Cluster peers communicate using [libp2p](https://libp2p.io) (cluster swarm), similarly to IPFS, but separately from it. Thus, every cluster peer needs its own Private Key (different from the one used by the IPFS daemon) and has its own *Peer ID*.

The different sections of the documention will explain how to setup, start and operate a Cluster:

{{% children %}}


## Documentation bugs

Please open issues and submit PRs to this website in the [ipfs-cluster-website repository](https://github.com/ipfs/ipfs-cluster-website/issues).
