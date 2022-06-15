+++
title = "Roadmap"
weight = 80
aliases = [
    "/roadmap"
]
+++

# Roadmap

IPFS Cluster is an open source project in the IPFS ecosystem stewarded by Protocol Labs.

Users of the project can expect:

* Ongoing releases and bug fixes.
* New functionality, usually focused on unlocking additional scalability of the clusters.
* Support over the common channels and issue triage.
* Dependency upgrades, compatibility and features from the IPFS and libp2p downstreams.

The following represent "larger endaevors" that are in our radar:

* ***In progress***: Full and officially-vetted Kubernetes support.
* ***Upcoming***: Fully embedded IPFS peer in the IPFS Cluster daemon.
* Optimistic replication: allow cluster peers to decide what content they back rather than defining allocations.
* DAG Sharding support: distributing large DAGs across multiple peers. Ongoing effort but lacking go-ipfs support for depth-limited pins.
* Additional chunking/sharding/encoding strategies. FEC support.
* Cluster-controlled MFS.
* ***Done!*** Improve the metrics exporting system (i.e. Prometheus) with new metrics.
* ***Done!*** RPC streaming improvements (primarily affects speeding up adding content to many cluster nodes at once).
* ***Done!*** Exploring support for a more allocation strategies e.g. by geographic location or as a function of access patterns.
* ***Done!*** IPFS Pinning API support.
