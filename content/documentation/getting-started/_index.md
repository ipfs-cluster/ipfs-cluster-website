+++
title = "Getting Started"
weight = 15
aliases = [
    "/documentation/quickstart"
]
+++

# Getting started

The IPFS Cluster software consists of two binary files:

* [ipfs-cluster-service](/documentation/reference/service) runs a Cluster peer (similar to `ipfs daemon`) using a configuration file and by storing some information on disk.
* [ipfs-cluster-ctl](/documentation/reference/ctl) is used to communicate with a Cluster peer and perform actions such as pinning IPFS CIDs to the Cluster.

The Cluster peer communicates with the IPFS daemon (which needs to be launched and running separately) using the HTTP API (`localhost:5001`).

Usually, `ipfs-cluster-ctl` is used on the same machine or server on which `ipfs-cluster-service` is running. For example, `ipfs-cluster-ctl pin add <hash>` will instruct the local Cluster peer to submit a pin to the Cluster. The different peers in the Cluster will then proceed to ask their local IPFS daemons to pin that content. The number of pins across the Cluster will depend on the replication factor set in the Cluster configuration file.

The following sub-sections explain how to install IPFS Cluster and launch your first peers.

{{% children %}}
