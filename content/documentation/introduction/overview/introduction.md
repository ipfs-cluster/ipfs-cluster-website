+++
title = "Introduction"
weight = 100
+++

# IPFS Cluster Overview

IPFS Cluster is called "IPFS Enterprise" because Cluster is built to deal with scaling of IPFS. Cluster offers the features such as pin replicaiton and tracking. 
Cluster is a tool to store and backup your content. IPFS Cluster also has monitors and logs your pinset. 




### Why Cluster is important

#### Makes Content _Redundant_ 
{{< youtube 5q4Zl4JQh3Y >}} 

Pinning is when you make a piece of content persistent. It's great if you have content that lasts but what if something happens to your pin? Your content will be gone. 😢 If you're are using Cluster this is less likely to happen because Cluster makes your content _redundant_. That means that your content is located in more than one place. Let's say that you have your content in nodes A, B, C. If something tragic happens to node A, rest assure that content still lives in node B and C.

#### Other Features Include

* Pin Monitoring and logging- Cluster allows you to see the health of your peers

* New peers can be added and removed

* Import and export data into new clusters


## Basic Cluster Concepts

![](https://res.cloudinary.com/blockchain-side-hustle/image/upload/v1564150703/IPFS_cluster_A_standard_ipfs_cluster_ezvd05.png)



#### Cluster Glossary

CID (Content Identifier): A single identifer that contains a cryptographic has and a "codec", which holds information about how to interpret that data. [You can learn more about a CID here](https://proto.school/#/data-structures/04). 

Cluster Swarm: A module that allows peers to [interact with other peers](https://docs.libp2p.io/reference/glossary/#swarm).

DAG (Directed Acryclic Graph): [A DAG is a specific type of Merkle tree](https://proto.school/#/data-structures/05) where different branches in the tree can point at other branches in the tree in a single forward direction, as illustrated by the image above.

Pinset: Shared state of peers




## How is IPFS Cluster and IPFS Different?

{{< youtube 5q4Zl4JQh3Y>}}


IPFS Cluster are configured seperately from IPFS and runs its own p2p network. IPFS Cluster runs next to an IPFS node, it is not part of the IPFS node. Cluster and IPFS share the same command line API where you can add content and remove content. Other than that, IPFS Cluster and IPFS have _seperate components and architecture_. Many of Cluster components directly utilize [libp2p](https://libp2p.io/).


IPFS Cluster provides resiliency and data still sticks around even if a pin no longer exists.

IPFS can also be slow and has a lot of latency. With IPFS Cluster you can don't just have one pin but many pins that have the same content (or redundancy). The more pins you have hosted in different places, the higher the chances are that the content you are looking for is geographically close by. 




<!-- Inspiration taken from: 
https://www.consul.io/intro/index.html -->





<!-- ## IPFS Cluster Overview

IPFS Cluster is a software to orchestrate IPFS daemons running on different hosts.

<center><img alt="A typical IPFS Cluster" title="A typical IPFS Cluster" src="/cluster/diagrams/png/cluster.png" width="500px" /></center>

An IPFS Cluster is formed by a number of *Peers*, each of them associated to one IPFS daemon. The peers share a *pinset* (also known as *shared state*) which lists the *CIDs* which are cluster-pinned and their properties (allocations, replication factor etc.).

Cluster peers communicate using [libp2p](https://libp2p.io) (cluster swarm), similarly to IPFS, but separately from it. Thus, every cluster peer needs its own Private Key (different from the one used by the IPFS daemon) and has its own *Peer ID*. All peers share an additional *secret* key which ensures they can only communicate with known parties.

IPFS Cluster is used by Protocol Labs to maintain and replicate a large pinset, via integrations like the [IRC IPFS Pinbot](https://github.com/ipfs/pinbot-irc). -->
