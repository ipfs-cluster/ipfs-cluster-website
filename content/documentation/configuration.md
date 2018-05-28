+++
title = "Configuration"
+++


# Configuration

All IPFS Cluster configurations and persistent data can be found, by default, at the `~/.ipfs-cluster` folder. This section will describe the configuration of peers and clients. For more information about the persistent data in this folder, see the [Upgrades](/documentation/upgrades) section.


## ipfs-cluster-service

IPFS Cluster peers are run with the `ipfs-cluster-service` command. This subsection describes the configuration file used by this command, which dictates the clusters behaviour.

### The `service.json` configuration file

<div class="tipbox tip"> `ipfs-cluster-service -c <path>` sets the location of the configuration folder. This is also controlled by the `IPFS_CLUSTER_PATH` environment variable.</div>

The ipfs-cluster configuration file is usually found at `~/.ipfs-cluster/service.json`. It holds all the configurable options for cluster and its different components. The configuration file is divided in sections. Each section represents a component. Each item inside the section represents an implementation of that component and contains specific options.

The `cluster` section of the configuration stores a `secret`: a 32 byte (hex-encoded).

<div class="tipbox warning"> Important: The `secret` must be shared by all cluster peers.</div>

Using an empty key has security implications (see [Security](documentation/security)). **Different peers must share the same secret key to be able to talk to each other**.

<div class="tipbox tip">Usually, configurations for all cluster peers are identical with the exception of the `id` and `private_key` values.</div>

#### The *default* configuration file

Here you can access a [default `service.json` configuration file](/0.4.0_service.json).

#### The `cluster` main section

The main `cluster` section of the configuration file configures the core component and contains the following keys:

|Key|Default|Description|
|:---|:-------|:-----------|
|`id`|`"<randomly generated>"`| The peer's libp2p-host peer ID (must match the `private_key`). |
|`peername`| `"<hostname>"` | A human name for this peer. |
|`private_key`|`"<randomly generated>"`|The peer's libp2p private key (must match the `id`). |
|`secret`|`"<randomly generated>"` | The Cluster secret (must be the same in all peers).|
|[`leave_on_shutudown`](#leave-on-shutdown)| `false` | The peer will remove itself from the cluster peerset on shutdown. |
|`listen_multiaddress`| `"/ip4/0.0.0.0/tcp/9096"` | The peers Cluster-RPC listening endpoint. |
|`state_sync_interval`| `"1m0s"` | Interval between automatic triggers of [`StateSync`](https://godoc.org/github.com/ipfs/ipfs-cluster#Cluster.StateSync). |
|`ipfs_sync_interval`| `"2m10s"` | Interval between automatic triggers of [`SyncAllLocal`](https://godoc.org/github.com/ipfs/ipfs-cluster#Cluster.SyncAllLocal). |
|`replication_factor_min` | `-1` | Specifies the default minimum number of peers that should be pinning an item. -1 == all. |
|`replication_factor_max` | `-1` | Specifies the default maximum number of peers that should be pinning an item. -1 == all. |
|`monitor_ping_interval` | `"15s"` | Interval for sending a `ping` (used to detect downtimes). |
|`peer_watch_interval`| `"5s"` | Interval for checking the current cluster peerset, and storing it in the `peerset` file. |
|`disable_repinning` | `false` | Do not automatically re-pin all items allocated to an unhealthy peer. |

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

#### The `api` section

The `api` section contains configurations for the implementations of the API component, which are meant to provide endpoints for the interaction with Cluster.

##### > `restapi`

This is the default and only API implementation available. It provides a REST API to interact with Cluster.

|Key|Default|Description|
|:---|:-------|:-----------|
|`http_listen_multiaddress` | `"/ip4/127.0.0.1/tcp/9094"` | The API HTTP listen endpoint. Set empty to disable the HTTP endpoint. |
|`ssl_cert_file` | `""` | Path to an x509 certificate file. Enables SSL on the HTTP endpoint. Unless an absolute path, relative to config folder. |
|`ssl_key_file` | `""` | Path to a SSL private key file. Enables SSL on the HTTP endpoint. Unless an absolute path, relative to config folder. |
|`read_timeout` | `"30s"` | Parameters for https://godoc.org/net/http#Server . |
|`read_header_timeout` | `"30s"` | Parameters for https://godoc.org/net/http#Server . |
|`write_timeout` | `"30s"` | Parameters for https://godoc.org/net/http#Server . |
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
|`node_multiaddress` | `"/ip4/127.0.0.1/tcp/9095"` | The IPFS daemon HTTP API endpoint. This is the daemon that the peer uses to pin content. |
|`connect_swarms_delay` | `"30s"` | On start, the Cluster Peer will run `ipfs swarm connect` to the IPFS daemons of others peers. This sets the delay after starting up. |
|`proxy_read_timeout` | `"30s"` | Parameters for https://godoc.org/net/http#Server . |
|`proxy_read_header_timeout` | `"30s"` | Parameters for https://godoc.org/net/http#Server . |
|`proxy_write_timeout` | `"30s"` | Parameters for https://godoc.org/net/http#Server . |
|`proxy_idle_timeout` | `"30s"` | Parameters for https://godoc.org/net/http#Server . |
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
|`max_pin_queue_size` | `4096` | How many pin or unpin requests can be queued waiting to be pinned before we error them directly. |
|`concurrent_pins` | `10` | How many parallel pin or unpin requests we make to IPFS. Only makes sense with `pin_method` set to `refs` in the `ipfs_connector` section. |

#### The `monitor` section

The `monitor` section contains configurations for the implementations of the Peer Monitor component, which are meant to distribute and collects monitoring information (informer metrics, pings) to and from other peers, and trigger alerts.

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

### Initializing a default configuration

If you wish to generate a default configuration, with a randomly generated *id/private key* and *cluster secret* just run:

```
ipfs-cluster-service init
```

The configuration folder will be created if it doesn't exist and a default valid `service.json` file will be placed in it.

You can launch a single-peer cluster using this file, but launching a multi-peer cluster will require that all peers **share the same secret**.

<div class="tipbox tip">If present, the `CLUSTER_SECRET` environment value is used when running `ipfs-cluster-service init` to set the cluster `secret` value.</div>


#### Manually generating a cluster secret

You can obtain a 32-bit hex encoded random string with:

```
export CLUSTER_SECRET=$(od  -vN 32 -An -tx1 /dev/urandom | tr -d ' \n')
```

#### Manually generating a private key and peer ID

You can manually obtain a valid peer ID and its associated *private key* in the format expected by the configuration using [`ipfs-key`](https://github.com/whyrusleeping/ipfs-key) as follows:

```
ipfs-key | base64 -w 0
```

### Configuring the cluster peerset

The *peerset* is the list of peers that make the cluster. For some consensus implementations (`raft`), it is very important to build and maintain the *peerset*, so it can only be modified orderly. This subsection explains how the peerset is defined in the cluster configuration.

#### Raft consensus

When using the `raft` consensus implementation (our default and only one), it is necessary that each peer knows about the *location* and *peer IDs* of the rest of the cluster peers. There are two ways to achieve this:

* Provide multiaddresses for all peers in the configurations for each peer
* Bootstrap to a known peer which is up and running.

The two options are explained below.

<div class="tipbox tip">If both `peers` and `bootstrap` are empty in your configuration, the peer will be launched in *single peer mode*.</div>

#### Using `peers`

In this method, you provide multiaddresses for all the cluster peers in the `peers` configuration key:

* Each entry is a valid peer multiaddress like `/ip4/192.168.1.103/tcp/9096/ipfs/QmQHKLBXfS7hf8o2acj7FGADoJDLat3UazucbHrgxqisim`
* You need to know all your cluster peer IDs and locations in advance
* The majority of cluster peers need to be started within `raft.wait_for_leader_timeout` or boot will fail
* Configuration for all peers must have addresses for all other peers
* Multiple multiaddresses for the same peer are allowed
* The peer's own multiaddresses are allowed, but will be removed after a successful start.
* If `peers` is not empty, `bootstrap` will be ignored
* The entries in `peers` is automatically updated when:
  * The cluster has correctly started (new alternative multiaddresses for peers may be added)
  * Adding or removing cluster peers will add or remove their multiaddresses

Thus, you will want to fill in your `peers` configuration value when:

* Working with stable cluster peers, running in known locations
* Working with an automated deployment tools
* You are able to trigger start/stop/restarts for all peers in the cluster with ease

<div class="tipbox tip">Except for `private_key` and `id`, you can re-use the same configuration for all your cluster peers. This is very useful on automated deployments.</div>

Once the peers have booted for the first time, the current *peerset* will be maintaned by the consensus component and can only be updated by:

* adding new peers, using the bootstrap method
* removing new peers, using the `ipfs-cluster-ctl peers rm` method

<div class="tipbox warning">Do not manually modify the `peers` (by adding or removing peers) key after the cluster has been sucessfully started for the first time. This will result startup errors.</div>

#### Using `bootstrap`

This method consists in leaving the `peers` key empty and providing one or several `bootstrap` peers instead:

* Usually one bootstrap address should be enough.
* Each entry is a valid peer multiaddress like `/ip4/192.168.1.103/tcp/9096/ipfs/QmQHKLBXfS7hf8o2acj7FGADoJDLat3UazucbHrgxqisim`
* Bootstrap will be attempted in order to each of the provided address
* A successful bootstrap will autofill the `peers` key. Next start will thus use the `peers` method. All existing cluster peers will be updated accordingly.
* Bootstrap can only be performed with a clean cluster state (`ipfs-cluster-service state clean` does it)
* Bootstrap can only be performed when all the existing cluster-peers are running

<div class="tipbox warning">Avoid bootstrapping to different cluster peers at the same time.</div>

You will want to use `bootstrap` when:

* You are building your cluster manually, starting one single-cluster peer first and boostrapping each node consecutively to it
* You don't know the IPs or ports your peers will listen to (other than the first)

<div class="tipbox warning">Do not manually modify the `peers` (by adding or removing peers) key after the peer has been sucessfully bootstrapped. This will result in startup errors.</div>

#### `leave_on_shutdown`

The `cluster.leave_on_shutdown` option allows a peer to remove itself from the *peerset* when shutting down cleanly:

* The state will be cleaned up automatically when the peer is cleanly shutdown.
* All known peers will be set as `bootstrap` values and `peers` will be emptied. Thus, the peer can be started and it will attempt to re-join the cluster it left by bootstrapping to one of the previous peers.


### Configuration tweaks for running in production

Please check the [Deployment section](/documentation/deployment/#service-json-configuration-tweaks) for some more tips on what values to adapt for real-world clusters.

## ipfs-cluster-ctl

Currently, there is no configuration file for `ipfs-cluster-ctl`, but we are [working on it](https://github.com/ipfs/ipfs-cluster/issues/367).


## Next steps: [Deployment](/documentation/deployment)
