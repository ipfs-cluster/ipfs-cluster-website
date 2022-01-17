+++
title = "State of the clusters: January 2022"
date = 2022-01-17
publishdate = 2022-01-17
author = "@hsanjuan"
+++

## State of the clusters: January 2022

Today, we would like to provide a few details and figures on where we are with
regards to cluster scalability, particularly as ensuring IPFS storage
allocation and replication behind the [NFT.storage](https://nft.storage)
platform.

We have started 2022 with a
[new release (v0.14.4)](https://github.com/ipfs/ipfs-cluster/blob/master/CHANGELOG.md). [A few months ago](0.13.3_nft_storage/),
we were happy to report that we were tracking around 2 million pins.

Today, cluster is tracking over **25 million pins** for NFT.storage in a
single cluster, made of **9 peers** with around 85TB of storage each running
go-ipfs v0.12.0-rc1. On average, we are ingesting between 1 and 2 items per
second (normally add-requests that put the content directly on the cluster),
but we know we can take *many hundreds per second* when needed.

This numbers are not overly impressive when compared with, for example a
PostgreSQL instance for pinset tracking, but we understand cluster as a
distributed application with seamless pinset syncing which also supports
things like follower-clusters and scalability to hundreds of peers based on
its pubsub+crdt pinset distribution mechanisms.

In terms of configuration, we have set the cluster peer to let IPFS pin up to
**8 items in parallel**. This is what we found was a well-performing value
when going through pinning queues of several million items. Bitswap
performance, disk usage, network bandwidth all affect the right values. The
cluster-peers are configured using the *crdt* consensus mode, with
**replication factors set to 3**. Each node is tagged with a **datacenter**
tag, and the allocator is set to allocate per datacenter and free-space. Thus,
we get global distribution of every pin, which are then allocated to the peers
with most free space. We make use of the crdt-batching function, creating
commits every 300 items or 10 seconds (although we tune them as we need,
sometimes increasing the batch size or delay). For reference, one batch
(crdt-delta) can fit almost 4000 pins with 3 allocations (actual number
depends on the pin options and allocations).

The 20x pinset growth in hthe last few months has necessarily been accompanied
by several releases to get IPFS Cluster up to the task of handling multi-million setups:

* The cluster-peer datastore can be setup with LevelDB and Badger, and the latter
is GC'ed reguarlly so that it does not grow to take too much space per pin.
* We heavily sped up operations reading the full pinset (`pin ls` or
  `status`). For example, it is now very efficient to check all the pins in error
  or queued states because filtering has been improved. Listing the state has improved
  an order of magnitude.
* State export and import has been also improved to allow for cluster pinsets
  to be moved around (to new clusters), which facilitates maintenance, for
  example by setting new allocations for pins.

The next steps are to keep iterating towards supporting much larger
pinsets. The main improvement in the pipeline is to support streaming RPC
requests
([cluster components communicate via RPC](cluster_rpc_components/)). This
unlocks many improvements in speed and memory usage for any operations or
requests iterating over the full pinset.
