+++
title = "Configuration"
+++


# Configuration

All IPFS Cluster configurations and persistent data can be found, by default, at the `~/.ipfs-cluster` folder. This section will describe the configuration of peers and clients. For more information about the persistent data in this folder, see the [Upgrades](/documentation/upgrades) section.

## ipfs-cluster-service

IPFS Cluster peers are run with the `ipfs-cluster-service` command. This subsection describes the configuration file used by this command (`service.json`), which dictates the clusters behaviour, along with the `peerstore` file, which stores the peers multiaddresses.

<center><img alt="A Cluster peer" title="A Cluster peer" src="/cluster/diagrams/png/peer.png" width="500px" /></center>

### The `service.json` configuration file

<div class="tipbox tip"> <code>ipfs-cluster-service -c &lt;path&gt;</code> sets the location of the configuration folder. This is also controlled by the <code>IPFS_CLUSTER_PATH</code> environment variable.</div>

The ipfs-cluster configuration file is usually found at `~/.ipfs-cluster/service.json`. It holds all the configurable options for cluster and its different components. The configuration file is divided in sections. Each section represents a component. Each item inside the section represents an implementation of that component and contains specific options.

<div class="tipbox warning"> Important: The <code>cluster</code> section of the configuration stores a 32 byte hex-encoded <code>secret</code> which secures communication among all cluster peers. The <code>secret</code> must be shared by all cluster peers. Using an empty secret has security implications (see <a href="/documentation/security">Security</a>).</div>

<div class="tipbox tip">Usually, configurations for all cluster peers are identical with the exception of the <code>id</code> and <code>private_key</code> values.</div>

### Initializing a *default* configuration file

If you wish to generate a default configuration, with a randomly generated *id/private key* and *cluster secret* just run:

```
ipfs-cluster-service init
```

The configuration folder will be created if it doesn't exist and a default valid `service.json` file will be placed in it.

You can launch a single-peer cluster using this file, but launching a multi-peer cluster will require that all peers **share the same secret**.

<div class="tipbox tip">If present, the `CLUSTER_SECRET` environment value is used when running `ipfs-cluster-service init` to set the cluster `secret` value.</div>

As an example, [this is a default `service.json` configuration file](/0.4.0_service.json).

The file looks like:

```js
{
  "cluster": {...},
  "consensus": {
    "raft": {...},
  },
  "api": {
    "restapi": {...}
  },
  "ipfs_connector": {
    "ipfshttp": {...}
  },
  "pin_tracker": {
    "maptracker": {...}
  },
  "monitor": {
    "monbasic": {...},
    "pubsubmon": {...}
  },
  "informer": {
    "disk": {...},
    "numpin": {...}
  }
}
```

The different sections and subsections are documented in detail below.


#### The `cluster` main section

The main `cluster` section of the configuration file configures the core component and contains the following keys:

|Key|Default|Description|
|:---|:-------|:-----------|
|`id`|`"<randomly generated>"`| The peer's libp2p-host peer ID (must match the `private_key`). |
|`peername`| `"<hostname>"` | A human name for this peer. |
|`private_key`|`"<randomly generated>"`|The peer's libp2p private key (must match the `id`). |
|`secret`|`"<randomly generated>"` | The Cluster secret (must be the same in all peers).|
|`leave-on-shutdown`| `false` | The peer will remove itself from the cluster peerset on shutdown. |
|`listen_multiaddress`| `"/ip4/0.0.0.0/tcp/9096"` | The peers Cluster-RPC listening endpoint. |
|`state_sync_interval`| `"10m0s"` | Interval between automatic triggers of [`StateSync`](https://godoc.org/github.com/ipfs/ipfs-cluster#Cluster.StateSync). |
|`ipfs_sync_interval`| `"2m10s"` | Interval between automatic triggers of [`SyncAllLocal`](https://godoc.org/github.com/ipfs/ipfs-cluster#Cluster.SyncAllLocal). |
|`replication_factor_min` | `-1` | Specifies the default minimum number of peers that should be pinning an item. -1 == all. |
|`replication_factor_max` | `-1` | Specifies the default maximum number of peers that should be pinning an item. -1 == all. |
|`monitor_ping_interval` | `"15s"` | Interval for sending a `ping` (used to detect downtimes). |
|`peer_watch_interval`| `"5s"` | Interval for checking the current cluster peerset and detect if this peer was removed from the cluster. |
|`disable_repinning` | `false` | Do not automatically re-pin all items allocated to an unhealthy peer. |

The `leave_on_shutdown` option allows a peer to remove itself from the *peerset* when shutting down cleanly. This means that, for any subsequent starts, the peer will need to be [bootstrapped](/documentation/starting/#bootstrapping-a-peer) to the existing Cluster in order to re-join it.

##### Manually generating a cluster secret

You can obtain a 32-bit hex encoded random string with:

```
export CLUSTER_SECRET=$(od  -vN 32 -An -tx1 /dev/urandom | tr -d ' \n')
```

##### Manually generating a private key and peer ID

When automating a deployment or creating configurations for several peers, it might be handy to generate peer IDs and private keys manually.

You can obtain a valid peer ID and its associated *private key* in the format expected by the configuration using [`ipfs-key`](https://github.com/whyrusleeping/ipfs-key) as follows:

```
ipfs-key | base64 -w 0
```


#### The `consensus` section

The `consensus` contains configuration objects for the different implementations of the consensus component.

##### > `raft`

This is the default (and only) consensus implementation available.

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

This will allow you to start a Cluster from scratch with already fixed peerset. See the [Starting multiple peers with a fixed peerset](/documentation/starting/#starting-multiple-peers-with-a-fixed-peerset) section.

#### The `api` section

The `api` section contains configurations for the implementations of the API component, which are meant to provide endpoints for the interaction with Cluster.

##### > `restapi`

This is the default and only API implementation available. It provides a REST API to interact with Cluster.

|Key|Default|Description|
|:---|:-------|:-----------|
|`http_listen_multiaddress` | `"/ip4/127.0.0.1/tcp/9094"` | The API HTTP listen endpoint. Set empty to disable the HTTP endpoint. |
|`ssl_cert_file` | `""` | Path to an x509 certificate file. Enables SSL on the HTTP endpoint. Unless an absolute path, relative to config folder. |
|`ssl_key_file` | `""` | Path to a SSL private key file. Enables SSL on the HTTP endpoint. Unless an absolute path, relative to config folder. |
|`read_timeout` | `"0s"` | Parameters for https://godoc.org/net/http#Server . Note setting this value might break adding to cluster, if the timeout is shorter than the time it takes to add something to the cluster. |
|`read_header_timeout` | `"30s"` | Parameters for https://godoc.org/net/http#Server . |
|`write_timeout` | `"00s"` | Parameters for https://godoc.org/net/http#Server . Note setting this value might break adding to cluster, if the timeout is shorter than the time it takes to add something to the cluster. |
|`idle_timeout` | `"30s"` | Parameters for https://godoc.org/net/http#Server . |
|`libp2p_listen_multiaddress` | `""` | A listen multiaddress for the alternative libp2p host. See below. |
|`id` | `""` | A peer ID for the alternative libp2p host (must match `private_key`). See below. |
|`private_key` | `""` | A private key for the alternative libp2p host (must match `id`). See below. |
|`basic_auth_credentials` | `null` | An object mapping `"username"` to `"password"`. It enables Basic Authentication for the API. Should be used with SSL-enabled or libp2p-endpoints. |

The REST API component automatically, and additionally, exposes the HTTP API as a libp2p service on the main libp2p cluster Host (which listens on port `9096`). Exposing the HTTP API as a libp2p service allows users to benefit from the channel encryption provided by libp2p. Alternatively, the API supports specifying a fully separate libp2p Host by providing `id`, `private_key` and `libp2p_listen_multiaddress`. When using a separate Host, it is not necessary for an API consumer to know the cluster secret. Both the HTTP and the libp2p endpoints are supported by the [API Client](https://godoc.org/github.com/ipfs/ipfs-cluster/api/rest/client) and by [`ipfs-cluster-ctl`](/documentation/ipfs-cluster-ctl/).

#### The `ipfs_connector` section

The `ipfs_connector` section contains configurations for the implementations of the IPFS Connector component, which are meant to provide a way for the Cluster peer to interact with an IPFS daemon.

##### > `ipfshttp`

This is the default and only IPFS Connector implementation. It provides a gateway to the IPFS daemon API and an IPFS HTTP Proxy.

|Key|Default|Description|
|:---|:-------|:-----------|
|`proxy_listen_multiaddress` | `"/ip4/127.0.0.1/tcp/9095"` | IPFS Proxy listen multiaddress. |
|`node_multiaddress` | `"/ip4/127.0.0.1/tcp/5001"` | The IPFS daemon HTTP API endpoint. This is the daemon that the peer uses to pin content. |
|`connect_swarms_delay` | `"30s"` | On start, the Cluster Peer will run `ipfs swarm connect` to the IPFS daemons of others peers. This sets the delay after starting up. |
|`proxy_read_timeout` | `"0s"` | Parameters for https://godoc.org/net/http#Server . |
|`proxy_read_header_timeout` | `"5s"` | Parameters for https://godoc.org/net/http#Server . |
|`proxy_write_timeout` | `"0s"` | Parameters for https://godoc.org/net/http#Server . |
|`proxy_idle_timeout` | `"1m"` | Parameters for https://godoc.org/net/http#Server . |
|`pin_method` | `"refs"` | `refs` or `pin`. `refs` allows to fetch pins in parallel, but it's incompatible with automatic GC. `refs` only makes sense with `concurrent_pins` set to something > 1 in the `pin_tracker` section. `pin` only allows to fetch one thing at a time. |
|`ipfs_request_timeout` | `"5m0s"` | Specifies a timeout on general requests to the IPFS daemon. |
|`pin_timeout` | `"24h0m0s"` | Specifies the timeout for `pin/add` requests to the IPFS daemon. |
|`unpin_timeout` | `"3h0m0s"` | Specifies the timeout for `pin/rm` requests to the IPFS daemon. |

#### The `pin_tracker` section

The `pin_tracker` section contains configurations for the implementations of the Pin Tracker component, which are meant to ensure that the content in IPFS matches the allocations as decided by IPFS Cluster.

##### > `maptracker`

The `maptracker` implements a pintracker which keeps the local state in memory.

|Key|Default|Description|
|:---|:-------|:-----------|
|`max_pin_queue_size` | `50000` | How many pin or unpin requests can be queued waiting to be pinned before we error them directly. |
|`concurrent_pins` | `10` | How many parallel pin or unpin requests we make to IPFS. Only makes sense with `pin_method` set to `refs` in the `ipfs_connector` section. |

##### > `stateless`

The `stateless` tracker implements a pintracker which relies on ipfs and the shared state, thus reducing
the memory usage in comparison to the `maptracker`.

|Key|Default|Description|
|:---|:-------|:-----------|
|`max_pin_queue_size` | `50000` | How many pin or unpin requests can be queued waiting to be pinned before we error them directly. |
|`concurrent_pins` | `10` | How many parallel pin or unpin requests we make to IPFS. Only makes sense with `pin_method` set to `refs` in the `ipfs_connector` section. |

#### The `monitor` section

The `monitor` section contains configurations for the implementations of the Peer Monitor component, which are meant to distribute and collects monitoring information (informer metrics, pings) to and from other peers, and trigger alerts. See the [monitoring and automatic re-pinning section](/documentation/deployment/#monitoring-and-automatic-re-pinning) for more information.

##### > `monbasic`

The `monbasic` implementation collects and broadcasts metrics to all peers using Cluster's internal RPC endpoints.

|Key|Default|Description|
|:---|:-------|:-----------|
|`check_interval` | `"15s"` | The interval between checks making sure that no metrics are expired for any peers in the peerset. If an expired metric is detected, an alert is triggered. This may trigger repinning of items. |


##### > `pubsubmon`

The `pubsubmon` implementation collects and broadcasts metrics using libp2p's pubsub. This will provide a more efficient and scalable approach for metric distribution.

|Key|Default|Description|
|:---|:-------|:-----------|
|`check_interval` | `"15s"` | The interval between checks making sure that no metrics are expired for any peers in the peerset. If an expired metric is detected, an alert is triggered. This may trigger repinning of items. |


#### The `informer` section

The `informer` section contains configuration for Informers. Informers fetch the metrics which are used to allocate content to the different peers.

##### > `disk`

The `disk` informer collects disk-related metrics at intervals.

|Key|Default|Description|
|:---|:-------|:-----------|
|`metric_ttl` | `"30s"` | Time-to-Live for metrics provided by this informer. This will trigger a new metric reading at TTL/2 intervals. |
|`metric_type` | `"freespace"` | `freespace` or `reposize`. The informer will report the free space in the ipfs daemon repository (`StorageMax-RepoSize`) or the `RepoSize`.

##### > `numpin`

The `numpin` informer uses the total number of pins as metric, which collects at intervals.

|Key|Default|Description|
|:---|:-------|:-----------|
|`metric_ttl` | `"30s"` | Time-to-Live for metrics provided by this informer. This will trigger a new metric reading at TTL/2 intervals. |



###  The `peerstore` file

The IPFS daemon uses a fixed list of bootstrap servers to connect and eventually discover other peers. Since IPFS Cluster does not rely on externally-provided services for discovery, it does maintain its own peerset (a list of peers multiaddresses) in a `peerstore` file (usually found at `~/.ipfs-cluster/peerstore`).

The `peerstore` file is a list of multiaddresses for peers (1 per line). For example:

```
/dns4/cluster001/tcp/9096/ipfs/QmPQD6NmQkpWPR1ioXdB3oDy8xJVYNGN9JcRVScLAqxkLk
/dns4/cluster002/tcp/9096/ipfs/QmcDV6Tfrc4WTTGQEdatXkpyFLresZZSMD8DgrEhvZTtYY
/dns4/cluster003/tcp/9096/ipfs/QmWXkDxTf17MBUs41caHVXWJaz1SSAD79FVLbBYMTQSesw
/ip4/192.168.1.10/tcp/9096/ipfs/QmWAeBjoGph92ktdDb5iciveKuAX3kQbFpr5wLWnyjtGjb
```

**Unless your peer is [bootstrapping to an existing (and running) cluster peer](/documentation/starting/#bootstrapping-a-peer), you should create and fill-in this file with at least one of the other peers' multiaddresses**. Once the peer knows how to reach another member of the Cluster, it will be able to discover the rest of peers as necessary. You can include several multiaddresses for the same peer.

Your peer will update the `peerstore` on shutdown, automatically including new multiaddresses so that they are persisted for the next boot.

Note that, when a `/dns4/`/`/dns6/` multiaddress is known for a peer, other non-dns addresses are for that peer will not be stored.


## ipfs-cluster-ctl

Currently, there is no configuration file for `ipfs-cluster-ctl`, but we are [working on it](https://github.com/ipfs/ipfs-cluster/issues/367).


## Next steps: [Starting the Cluster](/documentation/starting)
