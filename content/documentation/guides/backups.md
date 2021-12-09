+++
title = "Data, backups and recovery"
weight = 40
+++

# Data, backups, and recovery

The configurations and data persisted by a running IPFS Cluster peer (with `ipfs-cluster-service`) is, by default, in the `$HOME/.ipfs-cluster/` folder. A Cluster peer persists several types of information on disk:

* The list of known peer addresses for future use. Is stored in the `peerstore` file during shutdown.
* The cluster pinset (the list of objects that are pinned in the cluster along with all the options associated to them (like the name, the allocations or the replication factor) are stored depending on the consensus component chosen:
  * `crdt` stores everything in a key-value BadgerDB datastore in the `badger` folder.
  * `raft` stores the-append-only log making up the pinset, along with the list of cluster peers in a BoltDB store frequently snapshotted. All is saved in the `raft` folder.
* `service.json` and `identity.json` are also persistent data, but normally they are not modified.

## Offline state: export and import

Since the pinset information is persistend on disk, it can be exported from an offline peer with:

```bash
ipfs-cluster-service state export
```

This will produce a list of json objects that represent the current pinset (very similar to `ipfs-cluster-ctl --enc=json pin ls` on peers that are online). The resulting file can be re-imported with:

```sh
ipfs-cluster-service state import
```

<div class="tipbox warning">Always re-import using the same <code>ipfs-cluster-service</code> version that you exported with.</div>

Note that the **state dump just contains the pinset**. It does not include any bookkeeping information, Raft peerset membership, Raft current term, CRDT Merkle-DAG nodes etc. Thus, when re-importing a pinset it is important to remember that:

  * In `raft`, the given pinset will be used to create a new snapshot, newer than any existing ones, but including information like the current peerset when existing.
  * In `crdt`, importing will [clean](#resetting-a-peer-state-cleanup) the state completely and create a single batch Merkle-DAG node. This effectively compacts the state by replacing the Merkle-DAG, but to prevent this peer from re-downloading the old DAG, all other peers in the Cluster should have replaced or removed it too.

See [Disaster recovery](#disaster-recovery) below for more information.

<div class="tipbox tip"> <code>raft</code> state dumps can be imported as <code>crdt</code> pinsets and vice-versa.</div>

## Resetting a peer: state cleanup

Cleaning up the state results in a blank cluster peer. Such peer will need to re-bootstrap (`raft`) or reconnect (`crdt`) to a Cluster in order to re-download the state. The state can also be provided by importing it, as described above. The cleanup can be performed by:

```sh
ipfs-cluster-service state cleanup
```

Note that this does not remove or rewrite the configuration, the identity or the peerstore files. Removing the `raft` or `crdt` data folders is to all effects the equivalent of a state cleanup.

When using Raft, the `raft` folder will be renamed as `raft.old.X`. Several copies will be kept depending on the `backups_rotate` configuration value. When using CRDT, the `crdt` related data will be deleted from the badger datastore.

## Disaster recovery

The only content that IPFS Cluster stores and which is unique to a cluster peer is the pinset. IPFS content is stored by IPFS. Usually, if you are running a cluster, there will be several peers replicating the content and the cluster pinset so that when one or several peers crash, are destroyed, disappear or simply fail, they can be reset to their clean form re-sync from other existing peers.

<div class="tipbox tip">A <b>healthy cluster</b> is that with at least 50% of healthy online peers (<code>raft</code>) or at least one trusted, healthy peer (<code>crdt</code>).</div>

Thus, any peer can be fully [reset](#resetting-a-peer-state-cleanup) and re-join an otherwise *healthy cluster* with the same procedure that you would add a new peer. In `raft`, departed peers should be nevertheless manually removed with `ipfs-cluster-ctl peer rm` if they are never going to re-join again.

### Unhealthy clusters

Things change for *unhealthy clusters*:

* In `crdt`, the lack of trusted peers will prevent the restored peer from re-syncing to the cluster state (although, as a workaround, it could temporally trust any other peer).
* In `raft`, the lack of quorum when more than 50% of peers are down, prevents adding new peers, removing broken peers or operating the cluster.

In such events, it may be easier to simply salvage the state and re-create your cluster following the next procedure:

  1. Locate a peer that still stores the state (`raft` or `badger` folders)
  2. Export the pinset with `ipfs-cluster-service state export`
  3. Reset your peer or setup a new peer from scratch
  4. Run `ipfs-cluster-service state import` to import the state copy from step 2
  7. Start the peer as a single-peer-cluster
  8. Fully cleanup, upgrade and bootstrap the rest of the peers to the running one

### State upgrades

Since version 0.10.0, Cluster peers will not need manual state upgrades (the `state upgrade` command is gone).
