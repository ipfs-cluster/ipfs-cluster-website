+++
title = "Features"
weight = 15
+++

# Features

The latest stable release of IPFS Cluster includes the following features:

* Directly adding, replicating and pinning content to multiple IPFS peers at once.
* Fetching and pinning content in multiple IPFS peers.
* [Raft-based](/documentation/guides/consensus#raft) consensus layer with protection against network splits and automatic leader redirection: Every IPFS Cluster peer can control the cluster, modify the pinset and perform any operations.
* [CRDT-based](/documentation/guides/consensus#crdt) offers full flexibility and scales to hundreds of peers.
* Maximum and minimum replication factor for content pinned in IPFS Cluster.
* Automatic re-pinning on downtime events.
* Evenly-distributed pins according to repository free space of each IPFS daemon. Pin allocations can also be manually set.
* Name and any custom metadata can be attached to every Pinned item.
* Comprehensive configuration options, allowing for high-latency clusters (world-wide peers).
* Painless migration process between stable versions (with state format upgrades when necessary).
* Pin-set exports and imports (i.e. useful when moving data to a new cluster)
* Clusters can grow (new peers can be added) and decrease (peers can be removed) without need of downtime.
* DHT-routing for Cluster peers. DNS-multiaddresses support. mDNS discovery.
* RESTful API exposed both on HTTP and libp2p endpoints (http tunneled on libp2p). HTTPs and basic authentication supported, along with full CORS support.
* Go API client with full support of all API endpoints and modes.
* IPFS-proxy, and HTTP endpoint allows to drop-in IPFS Cluster in place of the IPFS API. Some requests are intercepted and trigger cluster operations (like pin/add). IPFS API headers are mimicked automatically.
* Runs independently from IPFS, using the go-ipfs API (usually on tcp/5001) to control the IPFS daemon.
* Metric exporting (Prometheus) and tracing (Jaeger).
* Ansible roles, Kustomize resources (for Kubernetes), Docker container and Docker-compose templates are available to facilitate deployment.
* Extensive, up to date documentation and guides, including documentation focused on production deployments of IPFS and IPFS Cluster.
