+++
title = "Monitoring, tracing and metrics"
weight = 65
+++

# Monitoring, tracing, and metrics

IPFS Cluster peers monitor each others by regularly publishing metrics to the Cluster swarm via PubSub, but also offer a Prometheus endpoint and Jaeger tracing:

* [The monitor component](#the-monitor-component)
* [Tracing and metrics](#tracing-and-metrics)

## The monitor component

Cluster peers run a "monitor" component which is in charge of:

* Distributing arbitrary metrics from the current peer to all the others. Metrics have an associated expiry date.
* Detecting peer-health events and triggering actions
* In `crdt`, the peerset is defined as the list of peers for which we have received a valid metric.

The metrics are produced by an "informer" component. In practice, the metrics are sent using libp2p GossipSub (`pubsubmon`) and there are two types:

* `ping`: the lack of pings from a given cluster peer signifies that the peer is down and is used to trigger re-pinnings when enabled.
* `freespace`: informs how much free space IPFS has in its repository and is used to decide whether to allocate new pins to this peer or others.

Administrators can inspect the latest metrics received by a peer with the following commands:

```sh
ipfs-cluster-ctl health metrics ping
ipfs-cluster-ctl health metrics freespace
```

Note that:

* The Time-To-Live associated to `freespace` and other informer-metrics is controlled with the `metric_ttl` options for the different informers (the `disk` informer is used by default). Increasing it reduces the number of time a peer sends metrics to the network.
* The Time-To-Live associated to `ping` metrics is controlled by the `cluster.monitor_ping_interval` option.
* The `pubsubmon.check_interval` option controls how often a peer checks for expired metrics from other peers.
* You can read all the details in the [Configuration reference](/documentation/reference/configuration).


## Tracing and metrics

IPFS Cluster supports exposing a Prometheus endpoint for metric-scraping as well as submitting trace information to Jaeger.

These are configured in the `observations` section of the configuration and can be enabled from there or by starting a cluster peer with:

```sh
ipfs-cluster-service daemon --stats --tracing
```

For information on how to configure local services to see Jaeger and Prometheus traces see the [Running Cluster with OpenCensus Tracing and Metrics](/documentation/guides/opencensus) guide.
