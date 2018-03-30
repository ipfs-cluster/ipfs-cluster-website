+++
title = "Roadmap"
+++

# Roadmap

**THIS IS A DRAFT**

This is the IPFS Cluster Roadmap for the next months. Note that this is a declaration of our best intentions but it is very difficult to make compromises. We will keep this page updated.

## Short term (Q2 2018)

* Project website (ongoing)
* Key functionality extraction from go-ipfs / importers (ongoing)
* Sharding support prototype (ongoing)
* Improve UX to handle larger files / concurrent pin operations (several fronts, some ongoing)
* Efficient repository disk usage in IPFS (ongoing)
* Reference guide to setup, manage and operate a production cluster.
* First metrics are exposed.
* Live large-storage cluster operated and maintained by us (IPFS) consolidates all our pinsets. (ongoing)
* Discussions and collaborations started with players in the "large dataset" space.

## Mid term (6-8 months horizon)

* Stable collaborations with different players interested in using ipfs-cluster/ipfs to store large datasets.
* Good sharding support for at least ~1TB datasets (package repositories).
* We have metrics to have an idea of how big a cluster can grow (peers, pinset, repository size), where degradation start, critical paths in the application performance.
* Collaborative archival efforts (between strangers)

## Long term (~1 year+)

* ipfs-cluster+ipfs are used to ingest and store very large volumes of data in production
* Really strong testing and metric collection pipelines
* Additional chunking/sharding/encoding strategies. FEC support.
* Exploring new possibilities for the consensus layer
* Exploring how cluster can support 
* Exploring support for a rich set of allocation strategies e.g. by geographic location or as a function of access patterns
* Good support for composite clusters
