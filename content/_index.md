+++
title = "IPFS Cluster"
+++

[IPFS](https://ipfs.io) has given the users the power of content-addressed storage. The *permanent web* requires, however, a data redundancy and availability solution that does not compromise on the distributed nature of the IPFS Network.

<img alt="A typical IPFS Cluster" title="A typical IPFS Cluster" src="/cluster/diagrams/png/cluster.png" width="500px" style="float:right;" />

**IPFS Cluster** is a distributed application that works as a sidecar to IPFS peers, maintaining a global cluster pinset and intelligently allocating its items to the IPFS peers:

* An easy to run application: `ipfs-cluster-service` runs as an independent daemon, independent from IPFS and interacting with the IPFS daemon's API.
* Handle replication of millions pin to multiple IPFS daemons in a fire&forget fashion: pin lifetime tracked asynchronously, the Cluster peers take care of asking IPFS to pin things at a sustainable rate and retry pinning in case of failures.
* Fully featured API and CLI: `ipfs-cluster-ctl` provides a command-line client to the fully featured Cluster HTTP REST API.
* No central server: cluster peers form a distributed network and maintain a global, replicated and conflict-free list of pins.
* Baked-in permissions: a embedded permission  model supports standard peers (with permissions to change the cluster pinset) and follower peers (which store content as instructed but cannot modify the pinset).
* Name your pins: every pin supports custom replication factors, name and any other custom metadata.
* Multi-add: Ingest IPFS content to multiple daemons directly.
* CAR import support: import CAR-archived content with custom DAGs directly to the Cluster.
* A drop-in to any IPFS integration: each cluster peer provides an additional IPFS proxy API which performs cluster actions but behaves exactly like the IPFS daemon's API does.
* Integration-ready: Written in Go, Cluster peers can be programatically launched and controlled. The IPFS Cluster additionally provides Go and Javascript clients for its API.
* [libp2p](https://libp2p.io) powered: IPFS Cluster is built on libp2p, the battle-tested next generation p2p networking library powering IPFS, Filecoin and Ethereum V2.
