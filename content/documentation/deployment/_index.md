+++
title = "Production deployment"
weight = 10
aliases = [
]
+++

# Production deployment

This section is meant for administrators looking to setup IPFS and IPFS Cluster on a production environment. Administrators are expected to be familiar with IPFS and with the deployment of production applications (including reading the logs, being able to verify if ports are open, if connectivity exists between peers or if process is running).

Additionally, running IPFS Cluster in production requires:

* Basic understanding of the Cluster application architecture and how it interacts with IPFS
* Adjusting `ipfs` and `ipfs-cluster-service` configurations to the environment and the requirements of the cluster, as well as ensuring things have connectivity as needed (firewall ports etc.).
* Starting the `ipfs-cluster-service` daemons and verifying that they can connect and sync from each others.
* Optionally automating the deployment and lifecycle of cluster peers.

These topics are explained in the sections below:

{{% children %}}
