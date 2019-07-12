+++
title = "Main Component"
weight = 1
+++ 

# The Main Component

The main `cluster` section of the configuration file configures the core
component and contains the following keys:

|Key|Default|Description|
|:---|:-------|:-----------|
|`id`|`"<randomly generated>"`| The peer's libp2p-host peer ID (must match the `private_key`). |
|`peername`| `"<hostname>"` | A human name for this peer. |
|`private_key`|`"<randomly generated>"`|The peer's libp2p private key (must match the `id`). |
|`secret`|`"<randomly generated>"` | The Cluster secret (must be the same in all peers).|
|`leave_on_shutdown`| `false` | The peer will remove itself from the cluster peerset on shutdown. |
|`listen_multiaddress`| `"/ip4/0.0.0.0/tcp/9096"` | The peers Cluster-RPC listening endpoint. |
|`state_sync_interval`| `"10m0s"` | Interval between automatic triggers of [`StateSync`](https://godoc.org/github.com/ipfs/ipfs-cluster#Cluster.StateSync). |
|`ipfs_sync_interval`| `"2m10s"` | Interval between automatic triggers of [`SyncAllLocal`](https://godoc.org/github.com/ipfs/ipfs-cluster#Cluster.SyncAllLocal). |
|`replication_factor_min` | `-1` | Specifies the default minimum number of peers that should be pinning an item. -1 == all. |
|`replication_factor_max` | `-1` | Specifies the default maximum number of peers that should be pinning an item. -1 == all. |
|`monitor_ping_interval` | `"15s"` | Interval for sending a `ping` (used to detect downtimes). |
|`peer_watch_interval`| `"5s"` | Interval for checking the current cluster peerset and detect if this peer was removed from the cluster. |
|`disable_repinning` | `false` | Do not automatically re-pin all items allocated to an unhealthy peer. |

The `leave_on_shutdown` option allows a peer to remove itself from the
*peerset* when shutting down cleanly. This means that, for any subsequent
starts, the peer will need to be
[bootstrapped](/documentation/starting/#bootstrapping-a-peer) to the existing
Cluster in order to re-join it.
