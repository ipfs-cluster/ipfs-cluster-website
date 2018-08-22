+++
title = "Internals"
+++

# Internals

This sections provides insights into the IPFS cluster internals. It explains how cluster works on the inside, what happens when a pin request is received and how the project code is organized.

## The consensus algoritm

IPFS Cluster was designed with the idea that it should eventually support different consensus algorithm implementations. The consensus layer takes care of two things:

* Maintaining a consistent view of the `pinset`, which we refer to as the `shared state`, across all cluster peers. This involves controlling how updates to the state are performed, making sure that all participating peers share exactly the same pinset.
* Maintaining a consistent view of the `peerset`, that is, which peers are part of the cluster. In some consensus implementations, having a clearly defined `peerset` and updating it with consistency guarantees is as importance as keeping the rest of the shared state.

Regardless of the considerations above, we leave the definition of what a `consistent` view of the state is quite open, as different consensus layer implementations may respond to different needs for consistency, or provide different approaches towards it. Some consensus approaches may also not worry about keeping a `peerset` as others do.

### Raft

The Raft consensus implementation was chosen as the default consensus layer for IPFS Cluster for several reasons:

* It is simple to understand and reliable in the small clusters that would be typical for datacenter deployments
* It provides strong consistency and protection against network splits
* The `hashicorp/raft` implementation of the algoritm was easy to wrap onto the `go-libp2p-consensus` interface, and a supported plugging-in a `libp2p` transport.

Raft works by commiting log entries to a "distributed log" which every peer follows. In IPFS Cluster, every "Pin" and "Unpin" requests are log entries in that log. When a peer receives a log "Pin" operation, it updates its local copy of the shared state to indicate that the CID is now pinned.

In order to work, Raft elects a cluster "Leader" by majority, which is the only peer allowed to commit entries to the log. Thus, a Leader election can only succeed if at least half of the nodes are online. Log entries, and other parts of the Cluster functionality, can only happen when a Leader exists.

For example, a commit operation to the log is triggered with  `ipfs-cluster-ctl pin add <cid>`. This will use the peer's API to send a Pin request. The peer's Raft consensus layer will in turn forward the request to the cluster's Leader, which will perform the commit of the operation and inform all the peers in the peerset about it. This is explained in more detail in the "Pinning an item" section below.

The "peer add" and "peer remove" operations also trigger log entries (internal to Raft) and depend too on a healthy consensus status. Modifying the cluster peers is a tricky operation because it requires informing every peer of the new peer's multiaddresses. If a peer is down during this operation, the operation will fail, as otherwise that peer will not know how to contact the new member. Thus, it is recommended remove and bootstrap any peer that is offline before making changes to the peerset.

By default, the consensus data is stored in the `raft` subfolder, next to the main configuration file. This folder stores two types of information: the **boltDB** database storing the Raft log, and the state snapshots. Snapshots from the log are performed regularly when the log grows too big (see the `raft` configuration section for options). When a peer is far behind in catching up with the log, Raft may opt to send a snapshot directly, rather than to send every log entry that makes up the state individually. This data is initialized on the first start of a cluster peer and maintained throughout its life. Removing or renaming the `raft` folder effectively resets the peer to a clean state. Only peers with a clean state should bootstrap to already running clusters.

When running a cluster peer, **it is very important that the consensus data folder does not contain any data from a different cluster setup**, or data from diverging logs. What this essentially means is that different Raft logs should not be mixed. On clean shutdowns, IPFS Cluster peers will also create a Raft snapshot. This snapshot is the state copy that can be used for exporting or upgrading the state format.

## The shared state, the local state and the ipfs state

It is important to understand that IPFS Cluster deals with three types of states, regardless of the consensus implementation used:

* The **shared state** is maintained by the consensus algorithm and a copy is kept in every cluster peer. The shared state stores the list of CIDs which are tracked by IPFS Cluster, their allocations (peers which are pinning them), their replication factor, names and any other relevant information for cluster.
* The **local state** is maintained separately by every peer and represents the state of CIDs tracked by cluster and allocated to that specific peer: status in ipfs (pinned or not), modification time etc. The *local state* may opportunistically be built from the *ipfs state* as needed.
* The **ipfs state** is the actual state in ipfs (`ipfs pin ls`) which is maintained by the ipfs daemon.

In normal operation, all three states are in sync, as updates to the *shared state* cascade to the local and the ipfs states. Additionally, syncing operations are regularly triggered by IPFS Cluster. Unpinning cluster-pinned items directly from ipfs will, for example, cause a mismatch between the local and the ipfs state. Luckily, there are ways to inspect every state:


* `ipfs-cluster-ctl pin ls` shows information about the *shared state*. The result of this command is produced locally, directly from the state copy stored the peer.

* `ipfs-cluster-ctl status` shows information about the *local state* in every cluster peer. It does so by aggregating local state information received from every cluster member.

* `ipfs-cluster-ctl sync` makes sure that the *local state* matches the *ipfs state*. In other words, it makes sure that what cluster expects to be pinned is actually pinned in ipfs, or otherwise marks items with an error. As mentioned, this also happens automatically. Every sync operations triggers an `ipfs pin ls --type=recursive` call to the local node.

As a final note, the *local state* may show items in *error*. This happens when an item took too long to pin/unpin, or the ipfs daemon became unavailable. `ipfs-cluster-ctl recover <cid>` can be used to rescue these items. See the "Pinning an item" section below for more information.


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

For example, the `local` DAGService is notified everytime an IPFS block is produced in the process of chunking and building the DAG. This module then performs an IPFSBlockPut broadcast call to multiple cluster peers (allocations) and sends the block to those peer's IPFS Connector component. After the importing process is finalized, it triggers a Cluster `Pin` request.

## The DHT service

The Cluster component attaches a `go-libp2p-kad-dht` service to the libp2p Host. It then uses it to create a [routed host](https://godoc.org/github.com/libp2p/go-libp2p/p2p/host/routed), which uses the DHT as [PeerRouting](https://godoc.org/github.com/libp2p/go-libp2p-routing#PeerRouting)) provider. This allows to retrieve the multiaddreses for a peer.ID from other peers when they are not known locally (not part of the peerstore).

The DHT currently used is a Kademlia implementation. Peers IDs from other peers can be sorted and classified by distance to the current peer, which prioritizes remembering those which are closer to itself than those which are far away. When no addresses are known for a peer ID, we contact the closest known peer and ask for it. The process repeats itself until we come to a peer which is close enough to have remembered the details of the peer.ID that we are looking for. We make sure to run a regular `dht bootstrap` process which performs a request with an empty peer.ID, thus traversing the DHT, discovering and getting connected to other peers in it.

We currently do not use the DHT to store any information, just for peer discovery (routing).

The DHT only works if the peer can connect to a `boostrapper` peer from the beginning, so that it has an starting point to access and discover the rest of the network. This requirement translates into two things in Cluster:

* First we ask users to have at least one peer multiaddress in the `peerstore` file when they first start their peers (and don't use `--bootstrap`)
* Second, we persist all known multiaddresses on shutdown to the `peerstore` file.

One of the benefits of using a DHT is that we don't need to have every peer connect and know everyone else's addresses as soon as they start/join a cluster. Instead, whenever they need to `Connect`, they will use the DHT to find the other peers as needed.


## Next steps: [Composite Clusters](/documentation/composite-clusters)
