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

The *default* configuration file looks as follows:

```js
{
  "cluster": {                         // main cluster component configuration
    "id": "QmZyXksFG3vmLdAnmkXreMVZvxc4sNi1u21VxbRdNa2S1b", // peer ID
    "private_key": "<base64 representation of the key>",
    "secret": "<32-bit hex encoded secret>",
    "peers": [],                       // List of peers' multiaddresses
    "bootstrap": [],                   // List of bootstrap peers' multiaddresses
    "leave_on_shutdown": false,        // Abandon cluster on shutdown
    "listen_multiaddress": "/ip4/0.0.0.0/tcp/9096", // Cluster RPC listen
    "state_sync_interval": "1m0s",     // Time between state syncs
    "ipfs_sync_interval": "2m10s",     // Time between ipfs-state syncs
    "replication_factor_min": -1,      // Replication factor minimum threshold. -1 == all
    "replication_factor_max": -1,      // Replication factor maximum threshold. -1 == all
    "monitor_ping_interval": "15s"     // Time between alive-pings. See monitoring section
    "peer_watch_interval": "5s",       // Time between checking & updating "peers" value
    "disable_repinning": false         // Do not attempt to re-allocate pins when a peer is down
  },
  "consensus": { // Consensus maintains the shared state (pinset) across the cluster
    "raft": {
      "wait_for_leader_timeout": "15s",// How long to wait for a leader when there is none
      "network_timeout": "10s",        // Network operation timeout
      "commit_retries": 1,             // How many retries before giving up on commit
      "commit_retry_delay": "200ms",   // How long to wait between commit retries
      "heartbeat_timeout": "1s",  // Here and below: Raft options.
      "election_timeout": "1s",   // See https://godoc.org/github.com/hashicorp/raft#Config
      "commit_timeout": "50ms",
      "max_append_entries": 64,
      "trailing_logs": 10240,
      "snapshot_interval": "2m0s",
      "snapshot_threshold": 8192,
      "leader_lease_timeout": "500ms"
    }
  },
  "api": { // API provides external endpoints to control the cluster
    "restapi": {
      "listen_multiaddress": "/ip4/127.0.0.1/tcp/9094", // API listen
      "ssl_cert_file": "path_to_cert", // Path to SSL public certificate.
                                       // Unless absolute, relative to config folder
      "ssl_key_file": "path_to_key",   // Path to SSL private key.
                                       //Unless absolute, relative to config folder
      "read_timeout": "30s",           // Here and below, timeouts for network operations
      "read_header_timeout": "5s",
      "write_timeout": "1m0s",
      "idle_timeout": "2m0s",
      "basic_auth_credentials": {      // Leave null to disable basic auth.
        "user": "pass"
      }
    }
  },
  "ipfs_connector": { // IPFS Connector interacts with the IPFS daemon
    "ipfshttp": {
      "proxy_listen_multiaddress": "/ip4/127.0.0.1/tcp/9095", // ipfs-proxy listen address
      "node_multiaddress": "/ip4/127.0.0.1/tcp/5001", // ipfs-node API location
      "connect_swarms_delay": "7s",    // delay to swarm-connect ipfs peers after boot
      "proxy_read_timeout": "10m0s",   // Here and below, timeouts for network operations
      "proxy_read_header_timeout": "5s",
      "proxy_write_timeout": "10m0s",
      "proxy_idle_timeout": "1m0s",
      "pin_method": "pin"              // Supports "pin" and "refs".
                                       // "refs" will fetch content before pinning.
                                       // Use refs when auto-GC is disabled on ipfs.
                                       // Increase maptracker.concurrent_pins to
                                       // take advantange of "refs" method concurrency.
    }
  },
  "pin_tracker": { // Pin tracker provides status tracking for the pinset
    "maptracker": {
      "pinning_timeout": "1h0m0s",     // If not pinned after this, mark as error
      "unpinning_timeout": "5m0s",     // If not unpinned after this, mark as error
      "max_pin_queue_size": 4096,      // How many pins to hold in the pinning queue
      "concurrent_pins": 1             // How many concurrent pin requests we can perform.
                                       // Only useful with ipfshttp.pin_method set to "refs"
    }
  }
  "monitor": { // Monitor gathers, maintains metrics and triggers alerts when they expire
    "monbasic": {
    "check_interval": "15s"            // How often to check for expired metrics and trigger
                                       // alerts if a peer is down.
    }
  },
  "informer": { // Informer provides the metrics that decide pin allocations
    "disk": {                          // Used when using the disk informer (default)
      "metric_ttl": "30s",             // Amount of time this metric is valid.
                                       // Will be polled at TTL/2.
      "metric_type": "freespace"       // or "reposize": type of metric
    },
    "numpin": {                        // Used when using the numpin informer
      "metric_ttl": "10s"              // Amount of time this metric is valid.
                                       // Will be polled at TTL/2.
    }
  }
}
```

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
