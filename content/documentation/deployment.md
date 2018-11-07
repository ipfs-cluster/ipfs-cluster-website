+++
title = "Production deployments"
+++


# Production deployments

This section is dedicated to the task of deploying an IPFS Cluster and running it in a stable fashion. It describes:

* [Deployment methods](#deployment-methods)
* [Running in production: Configuration tweaks for each environment](#running-ipfs-cluster-in-production)
* [Adding and removing peers](#modifying-the-peerset-adding-and-removing-peers)
* [Monitoring and automatic re-pinning](#monitoring-and-automatic-re-pinning)
* [Data persistence and backups](#data-persistence-and-backups)

Make sure you are familiar with the [Configuration](/documentation/configuration) section first.

<div class="tipbox warning">All the IPFS Cluster peers in a cluster must be running the **minor.major** of `ipfs-cluster-service`: any peer in `0.6.x` will work together, but `0.6.x` will not work with `0.7.x` peers.</div>

## Deployment methods

This subsection provides different resources to automate the deployment of an IPFS Cluster:

* [Ansible roles](https://github.com/hsanjuan/ansible-ipfs-cluster)
* [Docker containers and Docker compose](/documentation/deployment/docker)
* Kubernetes and EKS (TODO)


### Help completing this section

We would be very grateful if you have used different methods to deploy IPFS Cluster (docker, kubernetes, puppet etc.) and share your know-how. Let us know in the [website repository](https://github.com/ipfs/ipfs-cluster-website/issues).

## Running IPFS Cluster in production

This subsection provides useful information for running `go-ipfs` and `IPFS Cluster` in a stable production environment.

### `service.json` configuration tweaks

The configuration file contains a few options which should be tweaked according to your environment, capacity and requirements:


* When dealing with large amount of pins, you may further increase the `cluster.state_sync_interval` and `cluster.ipfs_sync_interval` if sync operations become expensive.
* Consider increasing the `cluster.monitor_ping_interval` and `monitor.*.check_interval`. This dictactes how long cluster takes to realize a peer is not responding (and trigger re-pins). Re-pinning might be a very expensive in your cluster. Thus, you may want to set this a bit high (several minutes). You can use same value for both.
* Under the same consideration, you might want to set `cluster.disable_repinning` to true if you don't wish repinnings to be triggered at all on peer downtime.
* Set `raft.wait_for_leader_timeout` to something that gives ample time for all your peers to be restarted and come online without . Usually `30s` or `1m`.
* If your network is very unstable you can try increasing `raft.commit_retries`, `raft.commit_retry_delay`. Note: more retries and higher delays imply slower failures.
* Raft options:
  * For high-latency clusters (like having peers around the world), you can try increasing `heartbeat_timeout`, `election_timeout`, `commit_timeout` and `leader_lease_timeout`, although defaults are quite big already. For low-latency clusters, these can all be decreased (at least by half).
  * For very large pinsets, increase `snapshot_interval`. If your cluster performs many operations, increase `snapshot_threshold`.
* Adjust the `api.restapi` network timeouts depending on your API usage. This may protect against misuse of the API or DDoS attacks. Note that there are usually client-side timeouts that can be modified too.
* Adjust the `ipfs_connector.ipfshttp` network timeouts if you are using the ipfs proxy in the same fashion.
* Set the `pin_method` to `refs` (now the default), but make sure auto-GC is not enabled in `go-ipfs` (this is the default)
* If you are ingesting a large volume of pins, increase `pin_tracker.maptracker.max_pin_queue_size`. This is the number of things that can be queued for pinning at a given moment.
* If using `refs` for `pin_method`, increase `pin_tracker.maptracker.concurrent_pins`. The value depends on how many things you would like to have ipfs download at the same time. `3` to `15` should be ok.
* You may increase `informer.disk.metric_ttl`, although starting at `go-ipfs` 0.4.17, it should be possible to obtain updated disk metrics quickly and efficiently.

### `go-ipfs` configuration tweaks

* Initialize ipfs using the `server` profile: `ipfs init --profile=server` or `ipfs config profile apply server` if the configuration already exists.
* For very large repos, enable the Badger datastore ([source](https://github.com/ipfs/go-ipfs/blob/master/docs/experimental-features.md#basic-usage-2)):

```
[BACKUP ~/.ipfs]
$ ipfs config profile apply badgerds # or ipfs init --profile=server,badgerds
$ ipfs-ds-convert convert # Make sure you have enough disk space for the conversion.
$ ipfs-ds-convert cleanup # removes the backup data
```

Make sure you have enough space for the conversion.

* Do not enable automatic GC if using the `refs` pinning method
* Increase the `Swarm.ConnMgr.HighWater` (maximum number of connections) and reduce `GracePeriod` to `20s`.
* Increase `Datastore.BloomFilterSize` according to your repo size (in bytes): `1048576` (1MB) is a good value (more info [here](https://github.com/ipfs/go-ipfs/blob/master/docs/config.md#datastore))
* Set `Datastore.StorageMax` to a value according to the disk you want to dedicate for the ipfs repo.
* The `IPFS_FD_MAX` environment variable controls the FD `ulimit` value that `go-ipfs` sets for itself. Depending on your `Highwater` value, you may want to increase it to `4096`.

### Automatically upgrade on restart

For easy and quick upgrades, make sure your system starts and restarts IPFS Cluster and `go-ipfs` peers as follows:

```
ipfs-cluster-service daemon --ugprade
```

```
ipfs daemon --migrate
```

### Systemd service files

* [`ipfs-cluster.service`](https://raw.githubusercontent.com/hsanjuan/ansible-ipfs-cluster/master/roles/ipfs-cluster/files/etc/systemd/system/ipfs-cluster.service)
* [`ipfs.service`](https://raw.githubusercontent.com/hsanjuan/ansible-ipfs-cluster/master/roles/ipfs/files/etc/systemd/system/ipfs.service)

## Modifying the peerset: adding and removing peers

This subsection explains how to modify the cluster's peerset. The peerset is maintained by the `consensus` implementation, so instructions are specific to the implementation used. Right now, only the `raft` implementation is available.

### Raft consensus

Raft is our default consensus implementation. It provides high availability, protection against network splits and fast state convergence. It is appropiate for small sized clusters (what small means is to be determined, but probably < 20 peers) running in trusted environments.

The downside is that Raft requires strict procedures when updating the cluster *peerset* in order to assure consistency and correct operations of the consensus. In fact, updating the *peerset* is a commit operation in Raft, meaning that it always needs a functioning leader (and thus, the majority of peers in the *peerset* need to be online for it to take effect).

#### Adding peers

Adding peers should always be performed by **bootstrapping** as explained [here](/documentation/starting/#bootstrapping-a-peer).

#### Removing peers

Removing a peer is a final operation for that peer. That means, that peer cannot (should not) be started again unless its Raft state is cleaned up (`ipfs-cluster-service state clean`).

Removing peers can be done using `ipfs-cluster-ctl` which calls the `DELETE /peers/<id>` API endpoint:

```
ipfs-cluster-ctl peers rm <peerID>
```

A *peer ID* looks like `QmQHKLBXfS7hf8o2acj7FGADoJDLat3UazucbHrgxqisim`. Removing a peer has the following effects:

* The removed peer will shut itself down cleanly and clean its state (a backup is left). The `peers` configuration value will be cleared to avoid accidental restarts to mess with the existing cluster.
* The removed peer will be automatically erased from the `peers` configuration value for the rest of peers.
* `peers rm` also works with offline peers. **Offline peers should not be restarted after being removed**.

<div class="tipbox tip">The <a href="/documentation/configuration/#the-cluster-main-section">`leave_on_shutdown` option</a> triggers automatic removal on clean shutdowns.</div>

## Monitoring and automatic re-pinning

IPFS Cluster includes a monitoring component which gathers metrics and triggers alerts when a metric is no longer renewed. There are currently two types of metrics:

* `informer` metrics are used to decide on allocations when a pin request arrives. Different "informers" can be configured. The default is the [`disk` informer](/documentation/configuration/#disk), which extracts `repo stat` information from IPFS and sends a freespace metric.
* a `ping` metric is used to regularly signal that a peer is alive.

Every metric carries a Time-To-Live associated with it. This TTL can be configued in the `informer` configuration section. The `ping` metric TTL is determined by the [`cluster.monitoring_ping_interval`](/documentation/configuration/#the-cluster-main-section), and is equal to 2x its value.

Every IPFS Cluster peer broadcasts metrics regularly to all other peers. This happens TTL/2 intervals for the informer metrics and in `cluster.monitoring_ping_interval` for the ping metric.

When a metric for an existing cluster peer stops arriving and previous metrics have outlived their Time-To-Live, the monitoring component triggers an alert for that metric. `monbasic.check_interval` determines how often the monitoring component checks for expired TTLs and sends these alerts. If you wish to detect expired metrics more quickly, decrease this interval. Otherwise, increase it.

The IPFS Cluster peer will react to ping metrics alerts by searching for pins allocated to the alerting peer and triggering re-pinning requests for them, unless the `cluster.disable_repinning` option is `true`. These re-pinning requests may result in re-allocations if the the CID's allocation factor crosses the `replication_factor_min` boundary. Otherwise, the current allocations are maintained.

The monitoring and failover system in cluster is very basic and requires improvements. Failover is likely to not work properly when several nodes go offline at once (specially if the current Leader is affected). Manual re-pinning can be triggered with `ipfs-cluster-ctl pin <cid>`. `ipfs-cluster-ctl pin ls <CID>` can be used to inspect the current list of peers allocated to a CID.

## Data persistence and backups

Backups are never a bad thing. This subsection explains what IPFS Cluster does to make sure your pinset is not lost in a disaster event, and what further measures you can take.

When we speak of backups, we are normally referring to the `~/.ipfs-cluster/raft` folder (*state folder*), which effectively contains the cluster's *pinset* and other consensus-specific information.

When a peer is removed from the cluster, or when the user runs `ipfs-cluster-service state clean`, the *state folder* is **not removed**. Instead, it is renamed to `raft.old.X`, with the newest copy being `raft.old.0`. The number of copies kept around is configurable ([`raft.backups_rotate`](/documentation/configuration/#raft)).

On the other side, `raft` additionally takes regular snapshots of the *pinset* (which means it is fully persisted to disk). This is also performed on a clean shutdown of the peers.

When the peer is not running, the last persisted state can be manually exported with:

```
ipfs-cluster-service state export
```

This will output the *pinset*, which can be in turn re-imported to a peer with:

```
ipfs-cluster-service state import
```

`export` and `import` can be used to salvage a state in the case of a disaster event, when peers in the cluster are offline, or not enough peers can be started to reach a quorum (when using `raft`). In this case, we recommend importing the state on a new, clean, single-peer, cluster, and bootstrapping the rest of the cluster to it manually.


## Next steps: [Troubleshooting](/documentation/troubleshooting)
