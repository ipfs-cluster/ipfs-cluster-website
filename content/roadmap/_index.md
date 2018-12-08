+++
title = "Roadmap"
weight = 10
+++

# Roadmap

This is the IPFS Cluster Roadmap for the next months. Note that this is a declaration of our best intentions but it is very difficult to make compromises. We will keep this page updated ([history here](https://github.com/ipfs/ipfs-cluster-website/commits/master/content/roadmap.md)).

## Short term (Q4 2018)

* DAG Sharding support (ongoing)
* Metrics and tracing available (ongoing)
* Collaborations with key partners test Cluster and describe user journeys (ongoing)
* Research and testing on adding and moving data with cluster (ongoing)
* Collaborative pinsets prototype: an alternative consensus layer (to replace Raft) (ongoing)
* Support path-pinning (ipns and path resolution) (ongoing)

## Mid term (6-8 months horizon)

* Good support for composite clusters
* Stable collaborations with different players interested in using ipfs-cluster/ipfs to store large datasets.
* Good sharding support for at least ~1TB datasets (package repositories).
* We have metrics to have an idea of how big a cluster can grow (peers, pinset, repository size), where degradation start, critical paths in the application performance.
* Collaborative archival efforts (between strangers)
* Kubernetes-IPFS tests running automatically

## Long term (~1 year+)

* IPFS Cluster and IPFS are used to ingest and store very large volumes of data in production
* Really strong testing and metric collection pipelines
* Additional chunking/sharding/encoding strategies. FEC support.
* Exploring support for a rich set of allocation strategies e.g. by geographic location or as a function of access patterns
