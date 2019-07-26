+++
title = "Configuration reference"
weight = 20
+++

# Configuration reference

All IPFS Cluster configurations and persistent data can be found, by default, at the `~/.ipfs-cluster` folder. For more information about the persistent data in this folder, see the [Data, backups and recovery](/documentation/administration/backups) section.

<div class="tipbox tip"> <code>ipfs-cluster-service -c &lt;path&gt;</code> sets the location of the configuration folder. This is also controlled by the <code>IPFS_CLUSTER_PATH</code> environment variable.</div>

The `ipfs-cluster-service` program uses two main configuration files:

* `service.json`, containing the cluster peer configuration, usually identical in all cluster peers.
* `identity.json`, containing the unique identity used by each peer.


## `identity.json`

The `identity.json` file is auto-generated during `ipfs-cluster-service init`. It includes a base64-encoded private key and the public peer ID associated to it. This peer ID identifies the peer in the Cluster. You can see an example [here](/0.11.0_identity.json).

This file is not overwritten when re-running `ipfs-cluster-service -f init`. If you wish to generate a new one, you will need to delete it first.

#### Manual identity generation

When automating a deployment or creating configurations for several peers, it might be handy to generate peer IDs and private keys manually beforehand.

You can obtain a valid peer ID and its associated *private key* in the format expected by the configuration using [`ipfs-key`](https://github.com/whyrusleeping/ipfs-key) as follows:

```
ipfs-key -type ed25519 | base64 -w 0
```

## `service.json`

The `service.json` file holds all the configurable options for the cluster peer and its different components. The configuration file is divided in sections. Each section represents a component. Each item inside the section represents an implementation of that component and contains specific options. A default `service.json` file with sensible values is created when running `ipfs-cluster-service init`.

<div class="tipbox warning"> Important: The <code>cluster</code> section of the configuration stores a 32 byte hex-encoded <code>secret</code> which secures communication among all cluster peers. The <code>secret</code> must be shared by all cluster peers. Using an empty secret has security implications (see the <a href="/documentation/administration/security">Security</a> section).</div>

<div class="tipbox tip">If present, the `CLUSTER_SECRET` environment value is used when running `ipfs-cluster-service init` to set the cluster `secret` value.</div>

As an example, [this is a default `service.json` configuration file](/0.11.0_service.json).

The file looks like:

```js
{
  "cluster": {...},
  "consensus": {
    "crdt": {...},
    "raft": {...},
  },
  "api": {
    "ipfsproxy": {...},
    "restapi": {...}
  },
  "ipfs_connector": {
    "ipfshttp": {...}
  },
  "pin_tracker": {
    "maptracker": {...},
    "stateless": {...}
  },
  "monitor": {
    "pubsubmon": {...}
  },
  "informer": {
    "disk": {...},
    "numpin": {...}
  },
  "observations": {
    "metrics": {...},
    "tracing": {...}
  },
  "datastore": {
    "badger": {...}
  }
}
```

The different sections and subsections are documented in detail below.

### Using environment variables to overwrite configuration values

All the options in the configuration file can be can be overridden by setting
environment variables. i.e. `CLUSTER_SECRET` will overwrite the `secret`
value; `CLUSTER_LEAVEONSHUTDOWN` will overwrite the `leave_on_shutdown` value;
`CLUSTER_RESTAPI_CORSALLOWEDORIGINS` will overwrite the
`restapi.cors_allowed_origins` value.

In general the environment variable takes the form
`CLUSTER_<COMPONENTNAME>_KEYWITHOUTUNDERSCORES=value`. Environment variables will
be applied to the resultant configuration file when generating it with
`ipfs-cluster-service init`.

### The `cluster` main section

The main `cluster` section of the configuration file configures the core
component and contains the following keys:

|Key|Default|Description|
|:---|:-------|:-----------|
|`peername`| `"<hostname>"` | A human name for this peer. |
|`secret`|`"<randomly generated>"` | The Cluster secret (must be the same in all peers).|
|`leave_on_shutdown`| `false` | The peer will remove itself from the cluster peerset on shutdown. |
|`listen_multiaddress`| `"/ip4/0.0.0.0/tcp/9096"` | The peers Cluster-RPC listening endpoint. |
| `connection_manager {` | | A connection manager configuration objec. t|
| &nbsp;&nbsp;&nbsp;&nbsp;`high_water` | `400` | The maximum number of connections this peer will have. If it, connections will be closed until the `low_water` value is reached. |
| &nbsp;&nbsp;&nbsp;&nbsp;`low_water` | `100` | The libp2p host will try to keep at least this many connections to other peers. |
| &nbsp;&nbsp;&nbsp;&nbsp;`grace_period` | `"2m0s"` | New connections will not be dropped for at least this period. |
| `}` |||
|`state_sync_interval`| `"10m0s"` | Interval between automatic triggers of [`StateSync`](https://godoc.org/github.com/ipfs/ipfs-cluster#Cluster.StateSync). |
|`ipfs_sync_interval`| `"2m10s"` | Interval between automatic triggers of [`SyncAllLocal`](https://godoc.org/github.com/ipfs/ipfs-cluster#Cluster.SyncAllLocal). |
|`pin_recover_interval`| `"1h0m0s"` | Interval between automatic triggers of [`RecoverAllLocal`](https://godoc.org/github.com/ipfs/ipfs-cluster#Cluster.RecoverAllLocal). This will automatically re-try pin and unpin operations that failed. |
|`replication_factor_min` | `-1` | Specifies the default minimum number of peers that should be pinning an item. -1 == all. |
|`replication_factor_max` | `-1` | Specifies the default maximum number of peers that should be pinning an item. -1 == all. |
|`monitor_ping_interval` | `"15s"` | Interval for sending a `ping` (used to detect downtimes). |
|`peer_watch_interval`| `"5s"` | Interval for checking the current cluster peerset and detect if this peer was removed from the cluster (and shut-down). |
|`disable_repinning` | `true` | Do not automatically re-pin all items allocated to a peer that becomes unhealthy (down). |

The `leave_on_shutdown` option allows a peer to remove itself from the *peerset* when shutting down cleanly. It is most relevant
when using *raft*. This means that, for any subsequent starts, the peer will need to be [bootstrapped](/documentation/getting-started/start#starting-a-cluster-with-consensus-raft) in order to re-join the Cluster.

#### Manual secret generation

You can obtain a 32-bit hex encoded random string with:

```sh
export CLUSTER_SECRET=$(od  -vN 32 -An -tx1 /dev/urandom | tr -d ' \n')
```



### The `consensus` section

The `consensus` contains configuration objects for the different implementations of the consensus component.

#### > `crdt`

|Key|Default|Description|
|:---|:-------|:-----------|
|`cluster_name`| `"ipfs-cluster"` | An arbitrary name. It becomes the pubsub topic to which all peers in the cluster subscribe to, so it must be the same for all |
|`trusted_peers` | `[]` | The default set of trusted peers. See [Trust in CRDT Mode](/documentation/administration/consensus#trust-in-crdt-mode) for more information. |
|`peerset_metric` | `"ping"` | The name of the monitor metric to determine the current pinset. |
|`rebroadcast_interval` | `"1m0s"` | How often to republish the current heads when no other pubsub message has been seen. Reducing this will allow new peers to learn about the current state sooner. |

#### > `raft`

|Key|Default|Description|
|:---|:-------|:-----------|
|`init_peerset`| `[]` | An array of peer IDs specifying the initial peerset when no raft state exists. |
|`wait_for_leader_timeout` | `"15s"` | How long to wait for a Raft leader to be elected before throwing an error. |
|`network_timeout` | `"10s"` | How long before Raft protocol network operations timeout. |
|`commit_retries` | `1` | How many times to retry committing an entry to the Raft log on failure. |
|`commit_retry_delay` | `"200ms"` | How long to wait before commit retries. |
|`backups_rotate` | `6` | How many backup copies on the state to keep when it's cleaned up. |
|`heartbeat_timeout` | `"1s"` | See https://godoc.org/github.com/hashicorp/raft#Config . |
|`election_timeout` | `"1s"` |  See https://godoc.org/github.com/hashicorp/raft#Config . |
|`commit_timeout` | `"50ms"` |  See https://godoc.org/github.com/hashicorp/raft#Config . |
|`max_append_entries` | `64` |  See https://godoc.org/github.com/hashicorp/raft#Config . |
|`trailing_logs` | `10240` |  See https://godoc.org/github.com/hashicorp/raft#Config . |
|`snapshot_interval` | `"2m0s"` |  See https://godoc.org/github.com/hashicorp/raft#Config . |
|`snapshot_threshold` | `8192` |  See https://godoc.org/github.com/hashicorp/raft#Config . |
|`leader_lease_timeout` | `"500ms"` |  See https://godoc.org/github.com/hashicorp/raft#Config . |

Raft stores and maintains the peerset internally but the cluster configuration offers the option to manually provide the peerset for the first start of a peer using the `init_peerset` key in the `raft` section of the configuration. For example:

```
"init_peerset": [
  "QmPQD6NmQkpWPR1ioXdB3oDy8xJVYNGN9JcRVScLAqxkLk",
  "QmcDV6Tfrc4WTTGQEdatXkpyFLresZZSMD8DgrEhvZTtYY",
  "QmWXkDxTf17MBUs41caHVXWJaz1SSAD79FVLbBYMTQSesw",
  "QmWAeBjoGph92ktdDb5iciveKuAX3kQbFpr5wLWnyjtGjb"
]
```

This will allow you to start a Cluster from scratch with already fixed peerset.


### The `api` section

The `api` section contains configurations for the implementations of the API component, which are meant to provide endpoints for the interaction with Cluster. Removing any of these sections will disable the component. For example, removing the `ipfsproxy` section from the configuration will disable the proxy endpoint on the running peer.

#### > `ipfsproxy`

This component provides the IPFS Proxy Endpoint. This is an API which mimics the IPFS daemon. Some requests (pin, unpin, add) are hijacked and handled by Cluster. Others are simply forwarded to the IPFS daemon specified by `node_multiaddress`. The component is by default configured to mimic CORS headers configurations as present in the IPFS daemon. For
that it triggers accessory requests to them (like CORS preflights).

|Key|Default|Description|
|:---|:-------|:-----------|
|`node_multiaddress` | `"/ip4/127.0.0.1/tcp/5001"` | The listen addres of the IPFS daemon API. |
|`listen_multiaddress` | `"/ip4/127.0.0.1/tcp/9095"` | The proxy endpoint listening address. |
|`node_https` | `false` | Use HTTPS to talk to the IPFS API endpoint (experimental). |
|`read_timeout` | `"0s"` | Parameters for https://godoc.org/net/http#Server . Note setting this value might break adding to cluster, if the timeout is shorter than the time it takes to add something to the cluster. |
|`read_header_timeout` | `"30s"` | Parameters for https://godoc.org/net/http#Server . |
|`write_timeout` | `"0s"` | Parameters for https://godoc.org/net/http#Server . Note setting this value might break adding to cluster, if the timeout is shorter than the time it takes to add something to the cluster. |
|`idle_timeout` | `"30s"` | Parameters for https://godoc.org/net/http#Server . |
|`extract_headers_extra` | `[]` | If additional headers need to be extracted from the IPFS daemon and used in hijacked requests responses, they can be added here. |
|`extract_headers_path` | `"/api/v0/version"` | When extracting headers, a request to this path in the IPFS API is made. |
|`extract_headers_ttl` | `"5m"` | The extracted headers from `extract_headers_path` have a TTL. They will be remembered and only refreshed after the TTL. |


#### > `restapi`

This is the component which provides the REST API implementation to interact with Cluster.

|Key|Default|Description|
|:---|:-------|:-----------|
|`http_listen_multiaddress` | `"/ip4/127.0.0.1/tcp/9094"` | The API HTTP listen endpoint. Set empty to disable the HTTP endpoint. |
|`ssl_cert_file` | `""` | Path to an x509 certificate file. Enables SSL on the HTTP endpoint. Unless an absolute path, relative to config folder. |
|`ssl_key_file` | `""` | Path to a SSL private key file. Enables SSL on the HTTP endpoint. Unless an absolute path, relative to config folder. |
|`read_timeout` | `"0s"` | Parameters for https://godoc.org/net/http#Server . Note setting this value might break adding to cluster, if the timeout is shorter than the time it takes to add something to the cluster. |
|`read_header_timeout` | `"30s"` | Parameters for https://godoc.org/net/http#Server . |
|`write_timeout` | `"0s"` | Parameters for https://godoc.org/net/http#Server . Note setting this value might break adding to cluster, if the timeout is shorter than the time it takes to add something to the cluster. |
|`idle_timeout` | `"30s"` | Parameters for https://godoc.org/net/http#Server . |
|`libp2p_listen_multiaddress` | `""` | A listen multiaddress for the alternative libp2p host. See below. |
|`id` | `""` | A peer ID for the alternative libp2p host (must match `private_key`). See below. |
|`private_key` | `""` | A private key for the alternative libp2p host (must match `id`). See below. |
|`basic_auth_credentials` | `null` | An object mapping `"username"` to `"password"`. It enables Basic Authentication for the API. Should be used with SSL-enabled or libp2p-endpoints. |
|`headers` | `null` | A `key: [values]` map of headers the API endpoint should return with each response to `GET`, `POST`, `DELETE` requests. i.e. `"headers": {"header_name": [ "v1", "v2" ] }`. Do not place CORS headers here, as they are fully handled by the options below. |
|`cors_allowed_origins`| `["*"]` | CORS Configuration: values for `Access-Control-Allow-Origin`. |
|`cors_allowed_methods`| `["GET"]` | CORS Configuration: values for `Access-Control-Allow-Methods`. |
|`cors_allowed_headers`| `[]` | CORS Configuration: values for `Access-Control-Allow-Headers`. |
|`cors_exposed_headers`| `["Content-Type", "X-Stream-Output",` `"X-Chunked-Output", "X-Content-Length"]` | CORS Configuration: values for `Access-Control-Expose-Headers`. |
|`cors_allow_credentials`|  `true` | CORS Configuration: value for `Access-Control-Allow-Credentials`. |
|`cors_max_age`|  `"0s"` | CORS Configuration: value for `Access-Control-Max-Age`. |

The REST API component automatically, and additionally, exposes the HTTP API as a libp2p service on the main libp2p cluster Host (which listens on port `9096`). Exposing the HTTP API as a libp2p service allows users to benefit from the channel encryption provided by libp2p. Alternatively, the API supports specifying a fully separate libp2p Host by providing `id`, `private_key` and `libp2p_listen_multiaddress`. When using a separate Host, it is not necessary for an API consumer to know the cluster secret. Both the HTTP and the libp2p endpoints are supported by the [API Client](https://godoc.org/github.com/ipfs/ipfs-cluster/api/rest/client) and by [`ipfs-cluster-ctl`](/documentation/ipfs-cluster-ctl/).



### The `ipfs_connector` section

The `ipfs_connector` section contains configurations for the implementations of the IPFS Connector component, which are meant to provide a way for the Cluster peer to interact with an IPFS daemon.

#### > `ipfshttp`

This is the default and only IPFS Connector implementation. It provides a gateway to the IPFS daemon API and an IPFS HTTP Proxy.

|Key|Default|Description|
|:---|:-------|:-----------|
|`listen_multiaddress` | `"/ip4/127.0.0.1/tcp/9095"` | IPFS Proxy listen multiaddress. |
|`node_multiaddress` | `"/ip4/127.0.0.1/tcp/5001"` | The IPFS daemon HTTP API endpoint. This is the daemon that the peer uses to pin content. |
|`connect_swarms_delay` | `"30s"` | On start, the Cluster Peer will run `ipfs swarm connect` to the IPFS daemons of others peers. This sets the delay after starting up. |
|`pin_method` | `"refs"` | `refs` or `pin`. `refs` allows to fetch pins in parallel, but it's incompatible with automatic GC. `refs` only makes sense with `concurrent_pins` set to something > 1 in the `pin_tracker` section. `pin` only allows to fetch one thing at a time. |
|`ipfs_request_timeout` | `"5m0s"` | Specifies a timeout on general requests to the IPFS daemon for requets without a specific timeout option. |
|`pin_timeout` | `"24h0m0s"` | Specifies the timeout for `pin/add` which starts from the last block received for the item being pinned. Thus items which are being pinned slowly will not be cancelled even if they take more than 24h. |
|`unpin_timeout` | `"3h0m0s"` | Specifies the timeout for `pin/rm` requests to the IPFS daemon. |

### The `pin_tracker` section

The `pin_tracker` section contains configurations for the implementations of the Pin Tracker component, which are meant to ensure that the content in IPFS matches the allocations as decided by IPFS Cluster.

#### > `maptracker`

The `maptracker` implements a pintracker which keeps the local state in memory.

|Key|Default|Description|
|:---|:-------|:-----------|
|`max_pin_queue_size` | `50000` | How many pin or unpin requests can be queued waiting to be pinned before we error them directly. Re-queing will be attempted on the next "state sync" as defined by `state_sync_interval` |
|`concurrent_pins` | `10` | How many parallel pin or unpin requests we make to IPFS. Only makes sense with `pin_method` set to `refs` in the `ipfs_connector` section. |

#### > `stateless`

The `stateless` tracker implements a pintracker which relies on ipfs and the shared state, thus reducing
the memory usage in comparison to the `maptracker`.

|Key|Default|Description|
|:---|:-------|:-----------|
|`max_pin_queue_size` | `50000` | How many pin or unpin requests can be queued waiting to be pinned before we error them directly. Re-queing will be attempted on the next "state sync" as defined by `state_sync_interval` |
|`concurrent_pins` | `10` | How many parallel pin or unpin requests we make to IPFS. Only makes sense with `pin_method` set to `refs` in the `ipfs_connector` section. |

### The `monitor` section

The `monitor` section contains configurations for the implementations of the Peer Monitor component, which are meant to distribute and collects monitoring information (informer metrics, pings) to and from other peers, and trigger alerts.

#### > `pubsubmon`

The `pubsubmon` implementation collects and broadcasts metrics using libp2p's pubsub. This will provide a more efficient and scalable approach for metric distribution.

|Key|Default|Description|
|:---|:-------|:-----------|
|`check_interval` | `"15s"` | The interval between checks making sure that no metrics are expired for any peers in the peerset. If an expired metric is detected, an alert is triggered. This may trigger repinning of items. |


### The `informer` section

The `informer` section contains configuration for Informers. Informers fetch the metrics which are used to allocate content to the different peers.

#### > `disk`

The `disk` informer collects disk-related metrics at intervals.

|Key|Default|Description|
|:---|:-------|:-----------|
|`metric_ttl` | `"30s"` | Time-to-Live for metrics provided by this informer. This will trigger a new metric reading at TTL/2 intervals. |
|`metric_type` | `"freespace"` | `freespace` or `reposize`. The informer will report the free space in the ipfs daemon repository (`StorageMax-RepoSize`) or the `RepoSize`.

#### > `numpin`

The `numpin` informer uses the total number of pins as metric, which collects at intervals.

|Key|Default|Description|
|:---|:-------|:-----------|
|`metric_ttl` | `"30s"` | Time-to-Live for metrics provided by this informer. This will trigger a new metric reading at TTL/2 intervals. |


### The `observations` section

The `observations` section contains configuration for application distributed tracing and metrics collection.

#### > `metrics`

The `metrics` component configures the OpenCensus metrics endpoint for scraping of metrics by Prometheus.

|Key|Default|Description|
|:---|:-------|:-----------|
|`enable_stats` | `false` | Whether metrics should be enabled. |
|`prometheus_endpoint` | `/ip4/0.0.0.0/tcp/8888` | Publish collected metrics to endpoint for scraping by Prometheus. |
|`reporting_interval` | `"2s"` | How often to report on collected metrics. |

#### > `tracing`

The `tracing` component configures the Jaeger tracing client for use by OpenCensus.

|Key|Default|Description|
|:---|:-------|:-----------|
|`enable_tracing` | `false` | Whether tracing should be enabled. |
|`jaeger_agent_endpoint` | `/ip4/0.0.0.0/udp/6831` | Multiaddress to send traces to. |
|`sampling_prob` | `0.3` | How often to be sampling traces. |
|`service_name` | `cluster-daemon` | Service name that will be associated with cluster traces. |
