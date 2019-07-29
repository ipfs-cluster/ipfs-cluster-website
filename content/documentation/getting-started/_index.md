+++
title = "Getting Started"
weight = 15
aliases = [
    "/documentation/overview"
]
+++

# Getting started

The IPFS Cluster software consists of two binary files:

* [ipfs-cluster-service](/documentation/usage/service) runs a Cluster peer (similar to `ipfs daemon`) using a configuration file and storing some information on disk.
* [ipfs-cluster-ctl](/documentation/usage/ctl) is used to communicate with a Cluster peer and perform actions like pinning IPFS CIDs to the Cluster.

The Cluster peer communicates with the IPFS daemon (which needs to be launched and running separately) using the HTTP API (`localhost:5001`).

Usually, `ipfs-cluster-ctl` is used in the same machine or server on which `ipfs-cluster-service` is running. For example, `ipfs-cluster-ctl pin add <hash>` will instruct the local Cluster peer to submit a pin to the cluster. The different peers in the Cluster will then proceed to ask their local IPFS daemons to pin that content, depending on the replication factor associated to it.

The following sub-sections will explain in the most succint way how to install IPFS Cluster and launch your first peers.

{{% children %}}
