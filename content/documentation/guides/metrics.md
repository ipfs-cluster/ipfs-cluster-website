+++
title = "Cluster pubsub metrics"
weight = 70
+++

# Cluster pubsub metrics

<div class="tipbox tip">This section is about metrics broadcasted between cluster peers. For Prometheus metrics for monitoring see <a href="../monitoring">the monitoring guide</a>.</div>

Cluster peers regularly broadcast (using gossipsub) metrics between each others. These metrics serve several purposes:

* They allow to detect when a peer has left the cluster (each metric has an expiration date and is expected to be renewed before it is reached). This can be used to trigger actions such as repinnings.
* In crdt-mode they serve to identify the current cluster peerset (list of peers with non expired metrics).
* They are used to communicate information such as peer names and free-space, which can be used, for example, to make pin allocation decisions.

The metrics are produced by ["informer" components](../../configuration/#the-informer-section). There are currently several types of metrics:

* `ping`: the lack of pings from a given cluster peer signifies that the peer is down and is used to trigger re-pinnings when enabled. The ping metric includes information about each peer, like its peer name, IPFS daemon ID and addresses etc. which are then re-used to fill-in fields in the pin status objects when requested.
* `freespace`: this metric informs how much free space IPFS has in its repository and is used to decide whether to allocate new pins to this peer or others.
* `tag:*`: "tag" metric provide values coming from the tag informer. For example, peer may broadcast a metric `tag:group` with value `server`. The values are used by the balanced allocator to distribute pins across different values of a single tag.
* `pinqueue`: this metric carries the number of items queued to pin and can also be used to avoid pinning on peers with long pinning queues.

Administrators can inspect the latest metrics received by a peer with the following commands:

```sh
ipfs-cluster-ctl health metrics # lists available metrics
ipfs-cluster-ctl health metrics ping
ipfs-cluster-ctl health metrics freespace
...
```

Note that:

* The Time-To-Live associated to `freespace` and other informer-metrics is controlled with the `metric_ttl` options for the different informers (the `disk` informer is used by default). Increasing it reduces the number of time a peer sends metrics to the network.
* The Time-To-Live associated to `ping` metrics is controlled by the `cluster.monitor_ping_interval` option.
* The `pubsubmon.check_interval` option controls how often a peer checks for expired metrics from other peers.
* You can read all the details in the [Configuration reference](../../reference/configuration).
