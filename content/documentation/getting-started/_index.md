+++
title = "Getting Started"
weight = 10
aliases = [
    "/documentation/quickstart"
]
+++

# Getting started

**TODO**

The Getting Started section provides a basic overview of how to install, and start an IPFS Cluster. It serves two purposes: one, to provide instructions on how to setup IPFS Cluster for **production**, and two, to provide instructions on how to set up IPFS Cluster for learning (evaluating it as a solution). It would not detail every single aspect but it should touch on all concepts that exist, with pointers to the gritty details.

Implications:

- We should rewrite our Getting Started from the perspective of running in production
  - What does the minimum viable production deployment look like?
  - This isn’t tuned to your specific use case, but it gives you a production deployment and points you to Guides with more information. How do I tune it properly? How do I tune it for large datasets with few peers? What about small datasets with lots of peers?
- We should make a separate page with information for someone who just wants to kick the tires -- for the technology discovery.

**/end TODO**

The IPFS Cluster software consists of two binary files:

* [ipfs-cluster-service](/documentation/reference/service) runs a Cluster peer (similar to `ipfs daemon`) using a configuration file and by storing some information on disk.
* [ipfs-cluster-ctl](/documentation/reference/ctl) is used to communicate with a Cluster peer and perform actions such as pinning IPFS CIDs to the Cluster.

The Cluster peer communicates with the IPFS daemon (which needs to be launched and running separately) using the HTTP API (`localhost:5001`).

Usually, `ipfs-cluster-ctl` is used on the same machine or server on which `ipfs-cluster-service` is running. For example, `ipfs-cluster-ctl pin add <hash>` will instruct the local Cluster peer to submit a pin to the Cluster. The different peers in the Cluster will then proceed to ask their local IPFS daemons to pin that content. The number of pins across the Cluster will depend on the replication factor set in the Cluster configuration file.

The following sub-sections explain how to install IPFS Cluster and launch your first peers.

{{% children %}}
