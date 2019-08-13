+++
title = "Internals"
weight = 40
+++

# Internals

**TODO...**

To quote the Consul docs Internals section description:

This section covers some of the internals of Consul. Understanding the internals of Consul is necessary to successfully use it in production.

Please review the following documentation to understand how Consul works.

- Architecture
- Consensus Protocol
- Gossip Protocol
- Network Coordinates
- ...

Likewise, for Cluster, we have several subsystems that need to be understood at a certain level to be operated correctly in production. This is a separate subject from how to run it in production (which should be covered in Getting Started and Guides). This, instead, is about how Cluster fundamentally works.

Things like

- Consensus components
- Architecture

**/end TODO**


Each Cluster peer is made of multiple "components" for which there are sometimes different implementations available (most importantly the "consensus" one). Each peer and each component can be thoroughly configured depending on how they are going to be used, for example, by disabling some APIs or adjusting settings for production environments.

<center><img alt="A Cluster peer" title="A Cluster peer" src="/cluster/diagrams/png/peer.png" width="500px" /></center>

This section describes how to perform administration tasks on a multi-node IPFS Cluster. It provides insights into several topics, such as settings for running a Cluster in production, detailed configuration references, and cloud deployment automations.
