+++
title = "State of the clusters: March 2022"
date = 2022-03-22
publishdate = 2022-03-22
author = "@hsanjuan"
+++

## State of the clusters: March 2022

Two months have passed since our [last update](../state-of-the-clusters-jan-2022/)
on the "state of the clusters". In our previous post I mentioned we were
tracking 25 million pins on a 9-peer cluster.

Today that cluster (which stores content for
[NFT.storage](https://nft.storage)) has grown to **18 peers and 50 million
pins**. Our average usage rate keeps at around 4 new pins per second.

The new peers were added and were able to sync the cluster pinset in about 24
hours. This is a cluster with a crdt-DAG-depth 500k, which, given the multiple
branches, likely involved syncing millions of CRDT-dag blocks. Because the new
peers are empty and have more space that the older ones, they started storing
and taking the load, relieving others as intended (older ones have up to 70TB
of data pinned).

In the last version (v0.14.5), which we rolled out everywhere, we included
some changes to improve performance and CRDT-DAG syncing. We have also started
rebuilding older nodes with **LVM-striped, XFS and flatfs/next-to-last-3
datastore layout configuration for IPFS**. In our experience, XFS performs
better than Ext4 for folder with large number of files, which is essentially
what flatfs does. Next-to-last-3 is a sharding strategy that shards blocks
over folders with 3 letters (the default is 2). By having more shards, there
are less items on every folder, which is better for very large nodes.

The main issue now preventing unbounded scalability is that the huge pinset
causes RAM memory spikes whenever a cluster peer needs to check that the pins
that are supposed to on ipfs are actually there. This is because every item on
the pinset is loaded on memory to be able to iterate on them. At this point,
the memory spikes are very noticiable and steal memory which IPFS would gladly
use.

The next release of IPFS Cluster will address this and other issues through a
major shift on how things work internally, which will not only fix the memory
spikes, but also unlock lots of performance gains when adding content to
cluster peers. With these changes, IPFS Cluster will graduate to
version 1.0.0, having proven its reliability and scalability properties while
serving production infrastructure.
