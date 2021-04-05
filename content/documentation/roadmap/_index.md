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

* Regular releases correcting bugs and adding simple features
* Support over the common channels and issue triage
* Dependency upgrades, compatibility and features from the IPFS and libp2p downstreams.

That said, we are at the moment not committing to larger, complex endaevors, in the short term, although we are aware and tracking the following areas and topics:

* DAG Sharding support: distributing large DAGs across multiple peers. Ongoing effort but lacking go-ipfs support for depth-limited pins.
* Optimistic replication: allow cluster peers to decide what content they back rather than defining allocations.
* Improve the metrics exporting system (i.e. Prometheus) with new metrics.
* RPC streaming improvements (primarily affects speeding up adding content to many cluster nodes at once).
* Exploring support for a more allocation strategies e.g. by geographic location or as a function of access patterns.
* Additional chunking/sharding/encoding strategies. FEC support.
* Cluster-controlled MFS.
* IPFS Pinning API support.
