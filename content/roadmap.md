+++
title = "Roadmap"
+++

# Roadmap

This is the IPFS Cluster Roadmap for the next months. Note that this is a declaration of our best intentions but it is very difficult to make compromises. We will keep this page updated.

## Short term (Q3 2018)

* DAG Sharding support (ongoing)
* Key functionality extraction from go-ipfs / importers (ongoing)
* First metrics are exposed (ongoing)
* Live large-storage cluster operated and maintained by us (IPFS) consolidates all our pinsets. (ongoing)
* Discussions and collaborations started with players in the "large dataset" space.
* Research and testing on adding and moving data with cluster
* UX improvements (filters)

## Mid term (6-8 months horizon)

* Good support for composite clusters
* Stable collaborations with different players interested in using ipfs-cluster/ipfs to store large datasets.
* Good sharding support for at least ~1TB datasets (package repositories).
* We have metrics to have an idea of how big a cluster can grow (peers, pinset, repository size), where degradation start, critical paths in the application performance.
* Collaborative archival efforts (between strangers)
* Collaborative pinsets: new possibilities for the consensus layer
* Kubernetes-IPFS tests running automatically

## Long term (~1 year+)

* IPFS Cluster and IPFS are used to ingest and store very large volumes of data in production
* Really strong testing and metric collection pipelines
* Additional chunking/sharding/encoding strategies. FEC support.
* Exploring support for a rich set of allocation strategies e.g. by geographic location or as a function of access patterns
