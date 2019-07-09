+++
title = "Pinning and Adding Content"
weight = 60
+++

## Pinning an item

`ipfs-cluster-ctl pin add <cid>` will tell IPFS Cluster to pin (or re-pin) a CID.

When using the Raft consensus implementation, this involves:

* Deciding which peers will be allocated the CID (that is, which cluster peers will ask ipfs to pin the CID). This depends on the replication factor (min and max) and the allocation strategy (more details below).
* Forwarding the pin request to the Raft Leader.
* Commiting the pin entry to the log.
* *At this point, a success/failure is returned to the user, but cluster has more things to do.*
* Receiving the log update and modifying the *shared state* accordingly.
* Updating the local state.
* If the peer has been allocated the content, then:
  * Queueing the pin request and setting the pin status to `PINNING`.
  * Triggering a pin operation
  * Waiting until it completes and setting the pin status to `PINNED`.

Errors in the first part of the process (before the entry is commited) will be returned to the user and the whole operation is aborted. Errors in the second part of the process will result in pins with an status of `PIN_ERROR`.

Deciding where a CID will be pinned (which IPFS daemon will store it - receive the allocation) is a complex process. In order to decide, all available peers (those reporting valid/non-expired metrics) are sorted by the `allocator` component, depending on the value of their metrics. These values are provided by the configured `informer`. If a CID is already allocated to some peers (in the case of a re-pinning operation), those allocations are kept.

New allocations are only provided when the allocation factor (healthy peers holding the CID) is below the `replication_factor_min` threshold. In those cases, the new allocations (along with the existing valid ones), will attempt to total as much as `replication_factor_max`. When the allocation factor of a CID is within the margins indicated by the replication factors, no action is taken. The value "-1" and `replication_factor_min` and `replication_factor_max` indicates a "replicate everywhere" mode, where every peer will pin the CID.

Default replication factors are specified in the configuration, but every Pin object carries them associated to its own entry in the *shared state*. Changing the replication factor of existing pins requires re-pinning them (it does not suffice to change the configuration). You can always check the details of a pin, including its replication factors, using `ipfs-cluster-ctl pin ls <cid>`. You can use `ipfs-cluster-ctl pin add <cid>` to re-pin at any time with different replication factors. But note that the new pin will only be commited if it differs from the existing one in the way specified in the paragraph above.

In order to check the status of a pin, use `ipfs-cluster-ctl status <cid>`. Retries for pins in error state can be triggered with `ipfs-cluster-ctl recover <cid>`.

The reason pins (and unpin) requests are queued is to not perform too many requests to ipfs (i.e. when ingesting many pins at once).


## Unpinning an item

`ipfs-cluster-ctl pin rm <cid>` will tell IPFS Cluster to unpin a CID.

The process is very similar to the "Pinning an item" described above. Removed pins are wiped from the shared and local states. When requesting the local `status` for a given CID, it will show as `UNPINNED`. Errors will be reflected as `UNPIN_ERROR` in the pin local status.

## Adding an item

`ipfs-cluster-ctl add <args>` will add content to cluster. This is supported from version `0.5.0`. Cluster uses the same libraries as go-ipfs to chunk and create the DAGs (including the unixfs). It also provides similar options for configuring how the process is performed.

Just like ipfs, the files to be added are uploaded using a multipart request to the `/add` API endpoint.

Cluster implements adding using an `adder` module. The adder module can make use of custom `ClusterDAGService`s as a way to intercept all blocks as they are stored and perform cluster operations with them. We provide two modules which are also implementations of `ipld.DAGService`:

* The `local` cluster DAG service is used to add content locally to multiple IPFS daemons in the Cluster.
* The `sharding` cluster DAG service is used to shard content (or DAGs) across multiple IPFS daemons in the Cluster. Unlike the local, a daemon will end up holding a partial DAG.

For example, the `local` DAGService is notified everytime an IPFS block is produced in the process of chunking and building the DAG. This module then performs an IPFSBlockPut broadcast call to multiple cluster peers (allocations) and sends the block to those peer's IPFS Connector component. After the importing process is finalized, it triggers a Cluster `Pin` request