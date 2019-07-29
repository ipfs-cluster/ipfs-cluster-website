+++
title = "Cluster administration"
weight = 20
+++

# Cluster Administration

Each Cluster peer is made of multiple "components" for which there are sometimes different implementations available (most importantly the "consensus" one). Each peer and each component can be throughoutly configured depending on how they are going to be used, for example by disabling some APIs or adjusting settings for production environments.

<center><img alt="A Cluster peer" title="A Cluster peer" src="/cluster/diagrams/png/peer.png" width="500px" /></center>

This section is for those in charge of administering a full IPFS Cluster with multiple nodes provides insights into several topics such settings for running in production, detailed configuration references and cloud deployment automations:

{{% children %}}