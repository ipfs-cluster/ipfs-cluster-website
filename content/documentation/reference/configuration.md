+++
title = "Configuration"
weight = 5
+++

# Configuration reference

All IPFS Cluster configurations and persistent data can be found, by default, at the `~/.ipfs-cluster` folder. For more information about the persistent data in this folder, see the [Data, backups and recovery](/documentation/guides/backups) section.

<div class="tipbox tip"> <code>ipfs-cluster-service -c &lt;path&gt;</code> sets the location of the configuration folder. This is also controlled by the <code>IPFS_CLUSTER_PATH</code> environment variable.</div>

The `ipfs-cluster-service` program uses two main configuration files:

* `service.json`, containing the cluster peer configuration, usually identical in all cluster peers.
* `identity.json`, containing the unique identity used by each peer.


## `identity.json`

The `identity.json` file is auto-generated during `ipfs-cluster-service init`. It includes a base64-encoded private key and the public peer ID associated to it. This peer ID identifies the peer in the Cluster. You can see an example [here](/0.14.2_identity.json).

This file is not overwritten when re-running `ipfs-cluster-service -f init`. If you wish to generate a new one, you will need to delete it first.

The identity fields can be overwritten using the `CLUSTER_ID` and `CLUSTER_PRIVATEKEY` environment values.

#### Manual identity generation

When automating a deployment or creating configurations for several peers, it might be handy to generate peer IDs and private keys manually beforehand.

You can obtain a valid peer ID and its associated *private key* in the format expected by the configuration using [`ipfs-key`](https://github.com/whyrusleeping/ipfs-key) as follows:

```
ipfs-key -type ed25519 | base64 -w 0
```

## `service.json`

The `service.json` file holds all the configurable options for the cluster peer and its different components. The configuration file is divided in sections. Each section represents a component. Each item inside the section represents an implementation of that component and contains specific options. A default `service.json` file with sensible values is created when running `ipfs-cluster-service init`.

<div class="tipbox warning"> Important: The <code>cluster</code> section of the configuration stores a 32 byte hex-encoded <code>secret</code> which secures communication among all cluster peers. The <code>secret</code> must be shared by all cluster peers. Using an empty secret has security implications (see the <a href="/documentation/guides/security">Security</a> section).</div>

<div class="tipbox tip">If present, the `CLUSTER_SECRET` environment value is used when running `ipfs-cluster-service init` to set the cluster `secret` value.</div>

As an example, [this is a default `service.json` configuration file](/1.0.6_service.json).

The file looks like:

```js
{
  "source": "url" // a single source field may appear for remote configurations
  "cluster": {...},
  "consensus": {  // either crdt or raft
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
    "stateless": {...}
  },
  "monitor": {
    "pubsubmon": {...}
  },
  "allocator": {
    "balanced": {...}
  },
  "informer": {
    "disk": {...},
	"tags": {...},
	"pinqueue": {...},
  },
  "observations": {
    "metrics": {...},
    "tracing": {...}
  },
  "datastore": {  // either pebble, badger3, badger or leveldb
    "pebble": {...},
	"badger3": {...},
	"badger": {...},
    "leveldb": {...},
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

### Remote configurations

Since version 0.11.0, the `service.json` may be initialized with a single `source` field containing a URL that points to a standard `service.json` file. This configuration is read on every start of the peer.

A remote `service.json` can be used to point all peers the same configuration file stored in the same location. It is also possible to use an URL pointing to an file provided through IPFS.

### The `cluster` main section

The main `cluster` section of the configuration file configures the core
component.

The `replication_factor_min` and `replication_factor_max` control the pinning defaults when these options, which can be set on a per-pin basis, are left unset. Cluster always tries to allocate up to `replication_factor_max` peers to every item. However, if it is not possible to reach that number, pin operations will succeed as long as `replication_factor_min` can be fulfilled. Once the allocations are set, Cluster does not automatically change them (i.e. to increase them). However, a new Pin operation for the same CID will try again to fulfill `replication_factor_max` while respecting the already existing allocations.

The `leave_on_shutdown` option allows a peer to remove itself from the *peerset* when shutting down cleanly. It is most relevant when using *raft*. This means that, for any subsequent starts, the peer will need to be [bootstrapped](/documentation/deployment/bootstrap/#bootstrapping-the-cluster-in-raft-mode) in order to re-join the Cluster.

|Key|Default|Description|
|:---|:-------|:-----------|
|`peername`| `"<hostname>"` | A human name for this peer. |
|`secret`|`"<randomly generated>"` | The Cluster secret (must be the same in all peers).|
|`leave_on_shutdown`| `false` | The peer will remove itself from the cluster peerset on shutdown. |
|`listen_multiaddress`| `["/ip4/0.0.0.0/tcp/9096",` `"/ip4/0.0.0.0/udp/9096/quic"]` | The peers Cluster-RPC listening endpoints. |
| `connection_manager {` | | A connection manager configuration object.|
| &nbsp;&nbsp;&nbsp;&nbsp;`high_water` | `400` | The maximum number of connections this peer will have. If it, connections will be closed until the `low_water` value is reached. |
| &nbsp;&nbsp;&nbsp;&nbsp;`low_water` | `100` | The libp2p host will try to keep at least this many connections to other peers. |
| &nbsp;&nbsp;&nbsp;&nbsp;`grace_period` | `"2m0s"` | New connections will not be dropped for at least this period. |
| `}` |||
|`dial_peer_timeout` | `"3s"` | How long to wait when dialing a cluster peer before giving up. |
|`state_sync_interval`| `"10m0s"` | Interval between automatic triggers of [`StateSync`](https://godoc.org/github.com/ipfs-cluster/ipfs-cluster#Cluster.StateSync). |
|`pin_recover_interval`| `"1h0m0s"` | Interval between automatic triggers of [`RecoverAllLocal`](https://godoc.org/github.com/ipfs-cluster/ipfs-cluster#Cluster.RecoverAllLocal). This will automatically re-try pin and unpin operations that failed. |
|`replication_factor_min` | `-1` | Specifies the default minimum number of peers that should be pinning an item. -1 == all. |
|`replication_factor_max` | `-1` | Specifies the default maximum number of peers that should be pinning an item. -1 == all. |
|`monitor_ping_interval` | `"15s"` | Interval for sending a `ping` (used to detect downtimes). |
|`peer_watch_interval`| `"5s"` | Interval for checking the current cluster peerset and detect if this peer was removed from the cluster (and shut-down). |
|`mdns_interval` | `"10s"` | Setting it to `"0"` disables mDNS. Setting to a larger value enables mDNS but no longer controls anything. |
|`enable_relay_hop` | `true` | Let the cluster peer acts as relay for other peers that are not reachable directly. |
|`pin_only_on_trusted_peers` | `false` | The cluster peer will only allocate pins to trusted peers (as configured) |
|`disable_repinning` | `true` | Do not automatically re-pin all items allocated to a peer that becomes unhealthy (down). |
|`follower_mode` | `false` | Peers in follower mode provide useful error messages when trying to perform actions like pinning. |
|`peer_addresses` | `[]` | Full peer multiadresses for peers to connect to on boot (similar to manually added entries to the `peerstore` file. |
|`pin_only_on_trusted_peers` | `false` | Limits the possible allocations given to a pin to those in the `trusted_peers` list |



#### Manual secret generation

You can obtain a 32-bit hex encoded random string with:

```sh
export CLUSTER_SECRET=$(od  -vN 32 -An -tx1 /dev/urandom | tr -d ' \n')
```



### The `consensus` section

The `consensus` contains **a single configuration object for the chosen implementations of the consensus component** (either `crdt` or `raft`, but not both).

#### `crdt`

Including the CRDT section enables cluster to use a [crdt-based distributed key value store](/documentation/guides/consensus) for the cluster state (pinset).

Batched commits are enabled in this section by setting `batching.max_batch_size` and `batching.max_batch_age` to a value greater than 0 (the default). These two settings control when a batch is committed, either by reaching a maximum number of pin/unpin operations, or by reaching a maximum age.

An additional `batching.max_queue_size` option provides the ability to perform backpressure on Pin/Unpin requests. When more than `max_queue_size` pin/unpins are waiting to be included in a batch, the operations will fail. If this
happens, it is means cluster cannot commit batches as fast as pins are arriving. Thus, `max_queue_size` should be increase (to accommodate bursts), or the `max_batch_size` increased (to perform less commits and hopefully handle the requests faster).

Note that the underlying CRDT library will auto-commit when batch deltas reach 1MB of size.

|Key|Default|Description|
|:---|:-------|:-----------|
|`cluster_name`| `"ipfs-cluster"` | An arbitrary name. It becomes the pubsub topic to which all peers in the cluster subscribe to, so it must be the same for all. |
|`trusted_peers` | `[]` | The default set of trusted peers. See [Trust in CRDT Mode](/documentation/guides/consensus#the-trusted-peers-in-crdt-mode) for more information. Can be set to `[ "*" ]` to trust all peers. |
| `batching {` | | Batching settings when submitting pins to the CRDT layer. Both `max_batch_size` and `max_batch_age` need to be greater than 0 for batching to be enabled. |
| &nbsp;&nbsp;&nbsp;&nbsp;`max_batch_size` | `0` | The maximum number of pin/unpin operations to include in a batch before committing it. |
| &nbsp;&nbsp;&nbsp;&nbsp;`max_batch_age` | `"0s"` | The maximum time an uncommitted batch waits before it is committed. |
| &nbsp;&nbsp;&nbsp;&nbsp;`max_queue_size` | `1000` | The maximum number of pin/unpin operations that are waiting to be included in a batch. |
| `}` |||
|`peerset_metric` | `"ping"` | The name of the monitor metric to determine the current pinset. |
|`rebroadcast_interval` | `"1m0s"` | How often to republish the current heads when no other pubsub message has been seen. Reducing this will allow new peers to learn about the current state sooner. |
|`repair_interval` | `"1h0m0s"` | How often to check if the crdt-datastore is marked as dirty, and trigger a re-processing of the DAG in that case. |

#### `raft`

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

#### `ipfsproxy`

This component provides the IPFS Proxy Endpoint. This is an API which mimics the IPFS daemon. Some requests (pin, unpin, add) are hijacked and handled by Cluster. Others are simply forwarded to the IPFS daemon specified by `node_multiaddress`. The component is by default configured to mimic CORS headers configurations as present in the IPFS daemon. For
that it triggers accessory requests to them (like CORS preflights).

|Key|Default|Description|
|:---|:-------|:-----------|
|`node_multiaddress` | `"/ip4/127.0.0.1/tcp/5001"` | The listen address of the IPFS daemon API. |
|`listen_multiaddress` | `"/ip4/127.0.0.1/tcp/9095"` | The proxy endpoint listening address. |
|`log_file` | `""` | A file to write request log files (Apache Combined Format). Otherwise they are written to the Cluster log under the `ipfsproxylog` facility. |
|`node_https` | `false` | Use HTTPS to talk to the IPFS API endpoint (experimental). |
|`read_timeout` | `"0s"` | Parameters for https://godoc.org/net/http#Server . Note setting this value might break adding to cluster, if the timeout is shorter than the time it takes to add something to the cluster. |
|`read_header_timeout` | `"30s"` | Parameters for https://godoc.org/net/http#Server . |
|`write_timeout` | `"0s"` | Parameters for https://godoc.org/net/http#Server . Note setting this value might break adding to cluster, if the timeout is shorter than the time it takes to add something to the cluster. |
|`idle_timeout` | `"30s"` | Parameters for https://godoc.org/net/http#Server . |
|`extract_headers_extra` | `[]` | If additional headers need to be extracted from the IPFS daemon and used in hijacked requests responses, they can be added here. |
|`extract_headers_path` | `"/api/v0/version"` | When extracting headers, a request to this path in the IPFS API is made. |
|`extract_headers_ttl` | `"5m"` | The extracted headers from `extract_headers_path` have a TTL. They will be remembered and only refreshed after the TTL. |


#### `restapi`

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
|`http_log_file` | `""` | A file to write API log files (Apache Combined Format). Otherwise they are written to the Cluster log under the `restapilog` facility. |
|`cors_allowed_origins`| `["*"]` | CORS Configuration: values for `Access-Control-Allow-Origin`. |
|`cors_allowed_methods`| `["GET"]` | CORS Configuration: values for `Access-Control-Allow-Methods`. |
|`cors_allowed_headers`| `[]` | CORS Configuration: values for `Access-Control-Allow-Headers`. |
|`cors_exposed_headers`| `["Content-Type",` `"X-Stream-Output",` `"X-Chunked-Output",` `"X-Content-Length"]` | CORS Configuration: values for `Access-Control-Expose-Headers`. |
|`cors_allow_credentials`|  `true` | CORS Configuration: value for `Access-Control-Allow-Credentials`. |
|`cors_max_age`|  `"0s"` | CORS Configuration: value for `Access-Control-Max-Age`. |

The REST API component automatically, and additionally, can expose the HTTP API as a libp2p service on the main libp2p cluster Host (which listens on port `9096`) (this happens by default on Raft clusters). Exposing the HTTP API as a libp2p service allows users to benefit from the channel encryption provided by libp2p. Alternatively, the API supports specifying a fully separate libp2p Host by providing `id`, `private_key` and `libp2p_listen_multiaddress`. When using a separate Host, it is not necessary for an API consumer to know the cluster secret. Both the HTTP and the libp2p endpoints are supported by the [API Client](https://godoc.org/github.com/ipfs-cluster/ipfs-cluster/api/rest/client) and by [`ipfs-cluster-ctl`](/documentation/ipfs-cluster-ctl/).


#### `pinsvcapi`

This is the component which provides the Pinning Services API implementation to interact with Cluster. It shares most of the code with the `restapi`, thus it has the same options.

|Key|Default|Description|
|:---|:-------|:-----------|
|`http_listen_multiaddress` | `"/ip4/127.0.0.1/tcp/9094"` | The Pinning SVC API HTTP listen endpoint. Set empty to disable the HTTP endpoint. |
|`ssl_cert_file` | `""` | Path to an x509 certificate file. Enables SSL on the HTTP endpoint. Unless an absolute path, relative to config folder. |
|`ssl_key_file` | `""` | Path to a SSL private key file. Enables SSL on the HTTP endpoint. Unless an absolute path, relative to config folder. |
|`read_timeout` | `"0s"` | Parameters for https://godoc.org/net/http#Server . Note setting this value might break adding to cluster, if the timeout is shorter than the time it takes to add something to the cluster. |
|`read_header_timeout` | `"30s"` | Parameters for https://godoc.org/net/http#Server . |
|`write_timeout` | `"0s"` | Parameters for https://godoc.org/net/http#Server . Note setting this value might break adding to cluster, if the timeout is shorter than the time it takes to add something to the cluster. |
|`idle_timeout` | `"30s"` | Parameters for https://godoc.org/net/http#Server . |
|`libp2p_listen_multiaddress` | `""` | A listen multiaddress for the alternative libp2p host. See notes in `restapi`. |
|`id` | `""` | A peer ID for the alternative libp2p host (must match `private_key`). See notes in `restapi`. |
|`private_key` | `""` | A private key for the alternative libp2p host (must match `id`). See notes in `restapi`. |
|`basic_auth_credentials` | `null` | An object mapping `"username"` to `"password"`. It enables Basic Authentication for the API. Should be used with SSL-enabled or libp2p-endpoints. |
|`headers` | `null` | A `key: [values]` map of headers the API endpoint should return with each response to `GET`, `POST`, `DELETE` requests. i.e. `"headers": {"header_name": [ "v1", "v2" ] }`. Do not place CORS headers here, as they are fully handled by the options below. |
|`http_log_file` | `""` | A file to write API log files (Apache Combined Format). Otherwise they are written to the Cluster log under the `restapilog` facility. |
|`cors_allowed_origins`| `["*"]` | CORS Configuration: values for `Access-Control-Allow-Origin`. |
|`cors_allowed_methods`| `["GET"]` | CORS Configuration: values for `Access-Control-Allow-Methods`. |
|`cors_allowed_headers`| `[]` | CORS Configuration: values for `Access-Control-Allow-Headers`. |
|`cors_exposed_headers`| `["Content-Type",` `"X-Stream-Output",` `"X-Chunked-Output",` `"X-Content-Length"]` | CORS Configuration: values for `Access-Control-Expose-Headers`. |
|`cors_allow_credentials`|  `true` | CORS Configuration: value for `Access-Control-Allow-Credentials`. |
|`cors_max_age`|  `"0s"` | CORS Configuration: value for `Access-Control-Max-Age`. |


### The `ipfs_connector` section

The `ipfs_connector` section contains configurations for the implementations of the IPFS Connector component, which are meant to provide a way for the Cluster peer to interact with an IPFS daemon.

#### `ipfshttp`

This is the default and only IPFS Connector implementation. It provides a gateway to the IPFS daemon API and an IPFS HTTP Proxy.

|Key|Default|Description|
|:---|:-------|:-----------|
|`listen_multiaddress` | `"/ip4/127.0.0.1/tcp/9095"` | IPFS Proxy listen multiaddress. |
|`node_multiaddress` | `"/ip4/127.0.0.1/tcp/5001"` | The IPFS daemon HTTP API endpoint. This is the daemon that the peer uses to pin content. |
|`connect_swarms_delay` | `"30s"` | On start, the Cluster Peer will run `ipfs swarm connect` to the IPFS daemons of others peers. This sets the delay after starting up. |
|`ipfs_request_timeout` | `"5m0s"` | Specifies a timeout on general requests to the IPFS daemon for requests without a specific timeout option. |
|`repogc_timeout` | `"24h"` | Specifies a timeout on `/repo/gc` operations. |
|`pin_timeout` | `"2m0s"` | Specifies the timeout for `pin/add` which starts from the last block received for the item being pinned. Thus items which are being pinned slowly will not be cancelled even if they take more than 24h. |
|`unpin_timeout` | `"3h0m0s"` | Specifies the timeout for `pin/rm` requests to the IPFS daemon. |
|`unpin_disable` | `false` | Prevents the connector from unpinning anything (even if the Cluster does). |
|`informer_trigger_interval` | `0` | Force a broadcast of all peer metrics after the number of pin requests indicated by this value. |

### The `pin_tracker` section

The `pin_tracker` section contains configurations for the implementations of the Pin Tracker component, which are meant to ensure that the content in IPFS matches the allocations as decided by IPFS Cluster.


#### `stateless`

The `stateless` tracker implements a pintracker which relies on ipfs and the shared state, only keeping track in-memory of ongoing operations.

|Key|Default|Description|
|:---|:-------|:-----------|
|`max_pin_queue_size` | `1000000` | How many pin or unpin requests can be queued waiting to be pinned before we error them directly. Re-queing will be attempted on the next "state sync" as defined by `state_sync_interval` |
|`concurrent_pins` | `10` | How many parallel pin or unpin requests we make to IPFS. |
|`priority_pin_max_age`| `"24h0m0s"` | If a pin becomes this old and has failed to pin, retries will be deprioritized in the face of newer pin requests. |
|`priority_pin_max_retries` | `5` | If a pin has surpassed this number of pinning attempts, retries will be deprioritized in the face of newer pin requests. |

### The `monitor` section

The `monitor` section contains configurations for the implementations of the Peer Monitor component, which are meant to distribute and collects monitoring information (informer metrics, pings) to and from other peers, and trigger alerts.

#### `pubsubmon`

The `pubsubmon` implementation collects and broadcasts metrics using libp2p's pubsub. This will provide a more efficient and scalable approach for metric distribution.

|Key|Default|Description|
|:---|:-------|:-----------|
|`check_interval` | `"15s"` | The interval between checks making sure that no metrics are expired for any peers in the peerset. If an expired metric is detected, an alert is triggered. This may trigger repinning of items. |


### The `informer` section

The `informer` section contains configuration for Informers. Informers fetch the metrics which are used to allocate content to the different peers.

#### `disk`

The `disk` informer collects disk-related metrics at intervals.

|Key|Default|Description|
|:---|:-------|:-----------|
|`metric_ttl` | `"30s"` | Time-to-Live for metrics provided by this informer. This will trigger a new metric reading at TTL/2 intervals. |
|`metric_type` | `"freespace"` | `freespace` or `reposize`. The informer will report the free space in the ipfs daemon repository (`StorageMax-RepoSize`) or the `RepoSize`.

#### `tags`

The `tags` informer issues metrics based on user-provided tags. These "metrics" are just used to inform other peers of the tags associated to each peer. These tags are useful for the balanced allocator below, as they can be part of the `allocate_by` option. One metric is issued for every defined tag.

|Key|Default|Description|
|:---|:-------|:-----------|
|`metric_ttl` | `"30s"` | Time-to-Live for metrics provided by this informer. This will trigger a new metric reading at TTL/2 intervals. |
|`tags` | `{"group": "default"}` | A simple "tag_name: tag_value" object to specify the tags associated to this peer. |

#### `pinqueue`

The `pinqueue` informer collects the number of pins in the pintracker's pinning queue. It can be part of the `allocate_by` option in the balanced allocator to deprioritize pinning on peers with big queues. The `weight_bucket_size` option specifies by what amount the actual number of queued items should be divided. i.e If two peers have 53 and 58 items queued and `weight_bucket_size` is 1, then the peer with 58 items queued will be deprioritized by the allocator over the peer with 53 items. However if `weight_bucket_size` is 10, both peers will have the same weight (5), and thus prioritization will depend on other metrics (i.e. freespace).

|Key|Default|Description|
|:---|:-------|:-----------|
|`metric_ttl` | `"30s"` | Time-to-Live for metrics provided by this informer. This will trigger a new metric reading at TTL/2 intervals. |
|`weight_bucket_size` | `100000` | The allocator will use the actual pin queue size divided by this value when comparing `pinqueue` metrics. |


#### `numpin`

The `numpin` informer uses the total number of pins as metric, which collects at intervals.

|Key|Default|Description|
|:---|:-------|:-----------|
|`metric_ttl` | `"30s"` | Time-to-Live for metrics provided by this informer. This will trigger a new metric reading at TTL/2 intervals. |


### The `allocator` section

The `allocator` is used to configure allocators. Allocators control how pins are assigned to peers in the cluster.

#### `balanced`

The `balanced` allocator selects which peers to allocate pins to (when
replication factor is larger than 0) by using the different metrics received
from the peers to group and create a balanced distribution of every pin among
those groups.

For example: Allocate by `["tag:group", "freespace"]`, means that the
allocator will divide all the peers based on the value of tag-metric "group"
that they have first. Then it will order the peers in each group by their
"freespace" metric value. When deciding which peers should a pin be allocated
to, it will select the peer with most free-space from the group with most
overall free-space. Then it will forcefully select the peer with most
free-space from a second group (if it exists), as it is trying to balance
allocations among existing groups.

This can be extended to subgroups: Assuming a cluster made of 6 peers, 2 per
region (per a "region" tag), and one per availability zone (per an "az" tag),
configuring the allocator with `["tag:region", "tag:az", "freespace"]` will
ensure that a pin with replication factor = 3 lands in the 3 different
regions, in availability zone with most available aggregated space and in the
peer in that zone with most available space.


|Key|Default|Description|
|:---|:-------|:-----------|
|`allocate_by` | `["tag:group", "freespace"]` | Specifies by which informer metrics each pin should be allocated.


### The `observations` section

The `observations` section contains configuration for application distributed tracing and metrics collection.

#### `metrics`

The `metrics` component configures the OpenCensus metrics endpoint for scraping of metrics by Prometheus.

|Key|Default|Description|
|:---|:-------|:-----------|
|`enable_stats` | `false` | Whether metrics should be enabled. |
|`prometheus_endpoint` | `/ip4/127.0.0.1/tcp/8888` | Publish collected metrics to endpoint for scraping by Prometheus. |
|`reporting_interval` | `"2s"` | How often to report on collected metrics. |

The cluster peer exports the following cluster-specific metric, along with standard Go metrics:

|Name|Description|
|:---|:----------|
|`pins`| Total number of cluster pins|
|`pins_pin_queued`|Current number of pins queued for pinning|
|`pins_pinning`|Current number of pins currently pinning|
|`pins_pin_error`|Current number of pins in pin_error state|
|`pins_ipfs_pins`|Current number of pins in the local IPFS daemon|
|`pins_pin_add`|Total number of pin requests made to IPFS|
|`pins_pin_add_errors`|Total number of errors in pin requests made to IPFS|
|`blocks_put`|Total number of block/put requests made to IPFS (i.e. when adding via cluster)|
|`blocks_added_size`|Total size added to IPFS in bytes (when adding via cluster)|
|`blocks_added`|Total number of blocks written to IPFS (when adding via cluster)|
|`blocks_put_errors`|Total number of block/put requests errors|
|`informer_disk`|The metric value weight issued by the disk informer (usually corresponds to free-space in bytes)|

#### `tracing`

The `tracing` component configures the Jaeger tracing client for use by OpenCensus.

|Key|Default|Description|
|:---|:-------|:-----------|
|`enable_tracing` | `false` | Whether tracing should be enabled. |
|`jaeger_agent_endpoint` | `/ip4/0.0.0.0/udp/6831` | Multiaddress to send traces to. |
|`sampling_prob` | `0.3` | How often to be sampling traces. |
|`service_name` | `cluster-daemon` | Service name that will be associated with cluster traces. |

### The `datastore` section

The `datastore` section contains configuration for the storage backend. It can contain either a `pebble`, `badger3`, `badger` or a `leveldb` section.

#### `pebble`

The `pebble` is the default datastore backend. It uses [Pebble from CockroachDB](https://github.com/cockroachdb/pebble). Pebble is best suited to most scenarios due to its conservative memory usage, short ready-time upon restarts and efficient disk footprint.

|Key|Default|Description|
|:---|:-------|:-----------|
|`pebble_options` | `{...}` | Some [Pebble specific options](https://pkg.go.dev/github.com/cockroachdb/pebble#Options) initialized to their defaults, including per level configuration. |

#### `badger3`

The `badger3` component configures the [BadgerDB](https://github.com/dgraph-io/badger) backend based on version 3. Badger3 can be very fast but configuration tuning is more difficult than Pebble, and very large repositories will need several minutes to be ready on start.

|Key|Default|Description|
|:---|:-------|:-----------|
|`gc_discard_ratio` | `0.2` | See [RunValueLogGC](https://github.com/dgraph-io/badger/blob/725913b83470967abd97e850331d7ebe4926fa79/db.go#L1290-L1316) documentation. |
|`gc_interval` | `"15m0s"` | How often to run Badger GC cycles. A cycle is made of several rounds, which repeat until no space can be freed. Setting this to `"0s"` disables GC cycles. |
|`gc_sleep` | `"10s"` | How long to wait between GC rounds in the same GC cycle. Setting this to `"0s"` causes a single round to be run instead. |
|`badger3_options` | `{...}` | Some [BadgerDBv3 specific options](https://pkg.go.dev/github.com/dgraph-io/badger/v3#Options) initialized to optimized defaults. |


#### `badger`

The `badger` component configures the BadgerDB backend based on version 1.6.2. We recommend new setups to use Pebble or Badger3. Badger is old, unmaintained and suffers from a number of issues, including large disk-space footprint.

|Key|Default|Description|
|:---|:-------|:-----------|
|`gc_discard_ratio` | `0.2` | See [RunValueLogGC](https://github.com/dgraph-io/badger/blob/725913b83470967abd97e850331d7ebe4926fa79/db.go#L1290-L1316) documentation. |
|`gc_interval` | `"15m0s"` | How often to run Badger GC cycles. A cycle is made of several rounds, which repeat until no space can be freed. Setting this to `"0s"` disables GC cycles. |
|`gc_sleep` | `"10s"` | How long to wait between GC rounds in the same GC cycle. Setting this to `"0s"` causes a single round to be run instead. |
|`badger_options` | `{...}` | Some [BadgerDB specific options](https://godoc.org/github.com/dgraph-io/badger#Options) initialized to optimized defaults (per IPFS recommendations, see below). Setting `table_loading_mode` and `value_log_loading_mode` to `0` should help in memory constrained platforms (Raspberry Pis etc. with <1GB RAM) |

The adjustments performed on top of the default badger options by default can be seen [in the badger configuration initialization code](https://github.com/ipfs-cluster/ipfs-cluster/blob/master/datastore/badger/config.go#L38-L49).

#### `leveldb`

The `leveldb` component configures the LevelDB backend which is used to store things when the CRDT consensus is enabled. We discourage using leveldb.

|Key|Default|Description|
|:---|:-------|:-----------|
|`leveldb_options` | `{...}` | Some [LevelDB specific options](https://pkg.go.dev/github.com/syndtr/goleveldb@v1.0.0/leveldb/opt#Options) initialized to their defaults. |
