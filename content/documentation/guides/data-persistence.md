+++
title = "Data Persistence and Backups"
weight = 2
+++

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