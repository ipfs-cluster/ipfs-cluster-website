+++
title = "Cluster metrics"
weight = 70
+++

# Cluster metrics

Cluster peers run a "monitor" component which is in charge of:

* Distributing arbitrary metrics from the current peer to all the others. Metrics have an associated expiry date.
* Detecting peer-health events and triggering actions
* In crdt-mode, the peerset is defined as the list of peers for which we have received a valid metric.

The metrics are produced by an "informer" component and broadcasted using libp2p's GossipSub. There are currently two types of metrics:

* `ping`: the lack of pings from a given cluster peer signifies that the peer is down and is used to trigger re-pinnings when enabled.
* `freespace`: informs how much free space IPFS has in its repository and is used to decide whether to allocate new pins to this peer or others.

Administrators can inspect the latest metrics received by a peer with the following commands:

```sh
ipfs-cluster-ctl health metrics # lists available metrics
ipfs-cluster-ctl health metrics ping
ipfs-cluster-ctl health metrics freespace
```

Note that:

* The Time-To-Live associated to `freespace` and other informer-metrics is controlled with the `metric_ttl` options for the different informers (the `disk` informer is used by default). Increasing it reduces the number of time a peer sends metrics to the network.
* The Time-To-Live associated to `ping` metrics is controlled by the `cluster.monitor_ping_interval` option.
* The `pubsubmon.check_interval` option controls how often a peer checks for expired metrics from other peers.
* You can read all the details in the [Configuration reference](/documentation/reference/configuration).
