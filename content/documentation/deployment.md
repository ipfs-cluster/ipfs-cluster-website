+++
title = "Deployment"
+++


# Deployment

This section is dedicated to the task of deploying an IPFS Cluster and running it in a stable fashion. It describes:

* Deployment methods
* Configuration tweaks for each environment
* `go-ipfs` tips
* Adding and removing peers
* Troubleshooting deployment issues

Make sure you are familiar with the [Configuration](/documentation/configuration) section first.

<div class="tipbox warning">All the IPFS Cluster peers in a cluster must be running the **same version** of `ipfs-cluster-service`.</div>

## Deployment methods

This subsection provides different strategies to deploy an IPFS Cluster.

### Deploying using Ansible

If you have some hosts and would like to run a stable deployment if IPFS Cluster on them, you can use these [Ansible roles](https://github.com/hsanjuan/ansible-ipfs-cluster). They provide:

* Roles to install `go-ipfs` and IPFS Cluster binary distributions.
* Templated configurations for both `ipfs-cluster-service` and `go-ipfs`
* systemd service files to manage the lifecycle

### Help completing this section

We would be very grateful if you have used different methods to deploy IPFS Cluster (docker, kubernetes, puppet etc.) and share your know-how. Let us know in the [website repository](https://github.com/ipfs/ipfs-cluster-website/issues).

## Running IPFS Cluster in production

This subsection provides useful information for running `go-ipfs` and `IPFS Cluster` in a stable production environment.

### `service.json` configuration tweaks

The configuration file contains a few options which should be tweaked according to your environment, capacity and requirements:


* When dealing with large amount of pins, increase the `cluster.state_sync_interval` and `cluster.ipfs_sync_interval`.
* Consider increasing the `cluster.monitor_ping_interval` and `monitor.monbasic.check_interval`. This dictactes how long cluster takes to realize a peer is not responding (and trigger repins). Repinning might be a very expensive in your cluster. Thus, you may want to set this a bit high (several minutes). You can use same value for both.
* Set `raft.wait_for_leader_timeout` to something that gives ample time for all your peers to be restarted and come online without . Usually `30s` or `1m`.
* If your network is very unstable you can try increasing `raft.commit_retries`, `raft.commit_retry_delay`. Note: more retries and higher delays imply slower failures.
* Raft options:
  * For high-latency clusters (like having peers around the world), you can try increasing `heartbeat_timeout`, `election_timeout`, `commit_timeout` and `leader_lease_timeout`, although defaults are quite big already. For low-latency clusters, these can all be decreased (at least by half).
  * For very large pinsets, increase `snapshot_interval`. If your cluster performs many operations, increase `snapshot_threshold`.
* Adjust the `api.restapi` network timeouts depending on your API usage. Note that usually there are client-side timeouts too.
* Adjust the `ipfs_connector.ipfshttp` network timeouts if you are using the ipfs proxy.
* Set the `pin_method` to `refs`, but make sure auto-GC is not enabled in `go-ipfs` (this is the default)
* If you are ingesting a large volume of pins, increase `pin_tracker.maptracker.max_pin_queue_size`. This is the number of things that can be queued for pinning at a given moment.
* If using `refs` for `pin_method`, increase `pin_tracker.maptracker.concurrent_pins`. The value depends on how many things you would like to have ipfs download at the same time. `3` to `15` should be ok.
* Increase `informer.disk.metric_ttl`. Depending on the size of your ipfs datastore. It is good to set it to `5m` and more for large repos. If using `-1` for replication factor, set to a very high number, since the informers are not used in that case.


### `go-ipfs` configuration tweaks

* Initialize ipfs using the `server` profile: `ipfs init --profile=server`
* For larger repos, enable the Badger datastore ([source](https://github.com/ipfs/go-ipfs/blob/master/docs/experimental-features.md#basic-usage-2)):

```
[BACKUP ~/.ipfs]
ipfs config profile apply badgerds
$ ipfs-ds-convert convert
```

* Do not enable automatic GC if using the `refs` pinning method
* Increase the `Swarm.ConnMgr.Highwater` (maximum number of connections) and reduce `GracePeriod` to `20s`.
* Increase `Datastore.BloomFilterSize` according to your repo size (in bytes).
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

Adding peers should always be performed by **bootstrapping** the new peers to one of the peers in the existing cluster. There are two ways to bootstrap a new peer:

* The first method is to fill in the `bootstrap` configuration key as explained in the [Configuration documentation](documentation/configuration/#using-bootstrap)
* The second method is by starting the new peer with:

```
ipfs-cluster-service --bootstrap <existing_cluster_peer_multiaddress>
```

The bootstrapped peer should not have pre-existing state data (`ipfs-cluster-service state clean` backs it up and removes it). Upon joining the cluster successfully:

* The new peer will receive the last known state from the Raft leader
* The new peer's configuration `peers` will be updated with the multiaddresses from all cluster peers
* The new peer's multiaddress(es) will be added to the `peers` configuration value of all other peers

<div class="tipbox warning">Adding peers only works on healthy clusters, with all their peers online. Remove any unhealthy peers before adding new ones.</div>

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

<div class="tipbox tip">The <a href="/documentation/configuration/#leave-on-shutdown">`leave_on_shutdown` option</a> triggers automatic removal on clean shutdowns.</div>

## Data persistence and backups

Backups are never a bad thing. This subsection explains what IPFS Cluster does to make sure your pinset is not lost in a disaster event, and what further measures you can take.

When we speak of backups, we are normally referring to the `~/.ipfs-cluster/ipfs-cluster-data` folder (*state folder*), which effectively contains the cluster's *pinset* and other consensus-specific information.

When a peer is removed from the cluster, or when the user runs `ipfs-cluster-service state clean`, the *state folder* is **not removed**. Instead, it is renamed to `ipfs-cluster-data.old.X`, with the newest copy being `ipfs-cluster-data.old.0`. Up to 5 copies of the state are kept around, the older ones being removed.

`raft` takes regular snapshots of the *pinset* (which means it is fully persisted to disk). This is also performed on a clean shutdown of the peers.

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

