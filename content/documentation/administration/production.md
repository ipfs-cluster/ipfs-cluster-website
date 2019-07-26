+++
title = "Settings for production"
weight = 30
+++

# Settings for production environments

Administrators running IPFS Cluster and IPFS in a production environment should pay attention to a number of configuration options which may provide optimizations with regards to:

* Large pinsets
* Large number of peers
* Networks with very high or lower latencies

### `service.json` configuration tweaks

The configuration file contains a few options which should be tweaked according to your environment, capacity and requirements:


* `cluster` options:
  * When dealing with large amount of pins, you may further increase the `cluster.state_sync_interval` and `cluster.ipfs_sync_interval`. These operations will perform checks for every pin in the pinset and will trigger `ipfs pin ls --type=recursive` calls, which may be slow when the number of pinned items is huge.
  * Consider increasing the `cluster.monitor_ping_interval` and `monitor.*.check_interval`. This dictactes how long cluster takes to realize a peer is not responding (and potentially trigger re-pins). Re-pinning might be a very expensive in your cluster. Thus, you may want to set this a bit high (several minutes). You can use same value for both.
  * Under the same consideration, you might want to set `cluster.disable_repinning` to `true` if you don't wish repinnings to be triggered at all on peer downtime and want to handle things manually when content becomes underpinned. `replication_factor_max` and `replication_factor_min` allow some leeway: i.e. a 2/3 will allow one peer to be down without re-allocating the content assigned to it somewhere else.


* `raft` options (when running raft-based clusters):
  * Set `raft.wait_for_leader_timeout` to something that gives ample time for all your peers to be restarted and come online at once. Usually `30s` or `1m`.
  * If your network is very unstable, you can try increasing `raft.commit_retries`, `raft.commit_retry_delay`. Note: more retries and higher delays imply slower failures.
  * For high-latency clusters (like having peers around the world), you can try increasing `heartbeat_timeout`, `election_timeout`, `commit_timeout` and `leader_lease_timeout`, although defaults are quite big already. For low-latency clusters, these can all be decreased (at least by half).
  * For very large pinsets, increase `raft.snapshot_interval`. If your cluster performs many operations, increase `raft.snapshot_threshold`.


* `crdt` options (when running crdt-based clusters):
  * Reducing the `crdt.rebroadcast_interval` (default `1m`) to a few seconds should make new peers start downloading the state faster, and badly connected peers should have more options to receive bits of information, at the expense of increased pubsub chatter in the network.

* `restapi` options:
  * Adjust the `api.restapi` network timeouts depending on your API usage. This may protect against misuse of the API or DDoS attacks. Note that there are usually client-side timeouts that can be modified too.

* `ipfshttp` options:
  * Adjust the `ipfs_connector.ipfshttp` network timeouts if you are using the ipfs proxy in the same fashion.
  * Set the `pin_method` to `refs` (now the default), but make sure auto-GC is not enabled in `go-ipfs` (this is the default).

* `maptracker` options (when using the default `maptracker` pintracker):
  * If you are ingesting a large volume of pins, increase `pin_tracker.maptracker.max_pin_queue_size`. This is the number of things that can be queued for pinning at a given moment.
  * If using `refs` for `pin_method`, increase `pin_tracker.maptracker.concurrent_pins`. The value depends on how many things you would like to have ipfs download at the same time. `6` to `15` should be ok.


### `go-ipfs` configuration tweaks

* Initialize ipfs using the `server` profile: `ipfs init --profile=server` or `ipfs config profile apply server` if the configuration already exists.
* For very large repos, enable the Badger datastore ([source](https://github.com/ipfs/go-ipfs/blob/master/docs/experimental-features.md#basic-usage-2)):

```sh
[BACKUP ~/.ipfs]
$ ipfs config profile apply badgerds # or ipfs init --profile=server,badgerds
$ ipfs-ds-convert convert # Make sure you have enough disk space for the conversion.
$ ipfs-ds-convert cleanup # removes the backup data
```


* Do not enable automatic GC if using the `refs` pinning method
* Increase the `Swarm.ConnMgr.HighWater` (maximum number of connections) and reduce `GracePeriod` to `20s`. It can be as high as your machine would take (many thousands).
* Increase `Datastore.BloomFilterSize` according to your repo size (in bytes): `1048576` (1MB) is a good value (more info [here](https://github.com/ipfs/go-ipfs/blob/master/docs/config.md#datastore))
* Set `Datastore.StorageMax` to a value according to the disk you want to dedicate for the ipfs repo. This will affect how cluster allocates content.
* The `IPFS_FD_MAX` environment variable controls the FD `ulimit` value that `go-ipfs` sets for itself. Depending on your `Highwater` value, you may want to increase it to `8192` or more.
* Pay attention to [`AddrFilters`](https://github.com/ipfs/go-ipfs/blob/master/docs/config.md#swarm) and [`NoAnnounce`](https://github.com/ipfs/go-ipfs/blob/master/docs/config.md#addresses) options. They should be pre-filled to sensible values with the `server` configuration profile, but depending on the type of network you are running on, you may want to modify them.
