+++
title = "Cluster + OpenCensus"
aliases = [
    "/documentation/opencensus"
]
+++

# Running Cluster with OpenCensus Tracing and Metrics

This guide will show you how to:

* Configure and run Jaeger and Prometheus services locally
* Configure IPFS Cluster to send traces to Jaeger and metrics to Prometheus

Note that this guide is intended to show how to deploy and configure tracing and metrics with IPFS Cluster in a local dev environment only. Production deployment of either Jaeger or Prometheus is beyond the scope of what is being covered here.

## Prerequisites

We will be utilizing docker to run both Jaeger and Prometheus, so please have that installed before continuing.

## Jaeger

### Running

First, pull down the Jaeger all-in-one image:

```
$ docker pull jaegertracing/all-in-one:1.9
```

Once the image has been downloaded, run the image with the following configuration:

```
$ docker run -d --name jaeger \
  -e COLLECTOR_ZIPKIN_HTTP_PORT=9411 \
  -p 5775:5775/udp \
  -p 6831:6831/udp \
  -p 6832:6832/udp \
  -p 5778:5778 \
  -p 16686:16686 \
  -p 14268:14268 \
  -p 9411:9411 \
  jaegertracing/all-in-one:1.9
```

Of particular note are the following ports on the Jaeger container:
 - `6831` is default agent endpoint used by IPFS Cluster
 - `16686` exposes the web UI of the Jaeger service, where you can query and search collected traces


## Prometheus

### Configuration

To configure Prometheus, we create a `prometheus.yml` file, such as the following:

```yml
global:
  scrape_interval:     15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: ipfs-cluster-daemon
    scrape_interval:     2s
    static_configs:
      - targets: ['localhost:8888']
```

The target address specified matches the default address in the metrics configuration in IPFS Cluster, but feel to change it to something more suitable to your environment, just make sure to update your `~/.ipfs-cluster/service.json` to match.

### Running

First, pull the docker image down:

```
$ docker pull prom/prometheus
```

Then run the Prometheus container, making sure to mount the configuration file we just created:

```
$ docker run --network host -v /tmp/prometheus.yml:/etc/prometheus/prometheus.yml --name promy prom/prometheus
```

Note that to have Prometheus reach the metrics endpoint exposed by IPFS Cluster, it requires that the container be run on the host's network, this done via the `--network host` flag in the run command above.

## IPFS Cluster

### Configuration

Run `ipfs-cluster-service init` to create a new `~/.ipfs-cluster/service.json`.

In the `service.json` file there a section labelled `observations`, which has two subsections, one for metrics and one for tracing. Below is the default configuration values for those two sections.

```js
{
  "metrics": {
    "enable_stats": false,
    "prometheus_endpoint": "/ip4/0.0.0.0/tcp/8888",
    "reporting_interval": "2s"
  },
  "tracing": {
    "enable_tracing": false,
    "jaeger_agent_endpoint": "/ip4/0.0.0.0/udp/6831",
    "sampling_prob": 0.3,
    "service_name": "cluster-daemon"
  }
}
```

For local development tracing, it is advised to change the `observations.tracing.sampling_prob` to `1`, so that every action in the system is recorded and sent to Jaeger.

For the current guide nothing needs to be adjusted, as we can enable both tracing and metrics from CLI flags passed to the `ipfs-cluster-service daemon` command, though for production deployments it is probably simpler to update the `service.json` files to enable metrics and tracing all the time, then change any deployment scripts.

## Running

As mentioned we are going to start the daemon with the metrics and tracing flags.

```
$ ipfs-cluster-service daemon --stats --tracing
```

The metrics flag is labelled `--stats` to distinguish it from the IPFS Cluster peer metrics commands that already existed.

Once cluster has started, go to [http://localhost:9090/targets](http://localhost:9090/targets) to confirm that Prometheus has been able to beginning scraping metrics from IPFS Cluster.

To confirm that tracing is functioning correctly, we will add a file and pin to IPFS Cluster in one step by using the IPFS Cluster `add` command and then search for its trace in Jaeger.

```
$ echo 'test tracing file' > test.file
$ ipfs-cluster-ctl add test.file
```

Go to [https://localhost:16686](http://localhost:16686/search?operation=Recv.127.0.0.1%3A9094%3A%2Fadd%3APOST&service=cluster-daemon) and you should see a trace, it may be labelled `<trace-without-root-span>` due to an issue with how Jaeger creates/determines root spans, but all the information is still inside. If there is nothing there, give it sometime to flush the traces to the Jaeger Collector as it isn't instantaneous.

After having run a few commands to get some traces, it is a good time to go check out the [graph page of Prometheus](http://localhost:9090/graph?g0.range_input=1h&g0.expr=histogram_quantile(0.95%2C%20sum(rate(cluster_gorpc_libp2p_io_server_server_latency_bucket%5B5m%5D))%20by%20(le%2Cgorpc_server_method))&g0.tab=0), which is prefilled with a histogram of the request latencies of the [`gorpc`](https://github.com/libp2p/go-libp2p-gorpc) calls between IPFS Cluster components. There are plenty of other metrics configured for collection and they can be found in the drop-down next to the `Execute` button.

Hopefully, this tooling enables you to better understand how IPFS Cluster operates and performs.
