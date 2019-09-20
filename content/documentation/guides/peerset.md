+++
title = "Peerset management"
weight = 50
+++

# Peerset management

Adding and removing peers from the Cluster might be a simpler or trickier operation depending on the "consensus" component used by the cluster (the [consensus component is in charge on managing the peerset](/documentation/guides/consensus)).

## Listing peers

```sh
ipfs-cluster-ctl peers ls
```

The `peers ls` command will produce the list of peers in the cluster will all their information. It is the equivalent of calling `ipfs-cluster-ctl id` on every cluster peer and building a list with the results, but for it to work it needs to contact all the current peers of the cluster, meaning it can be a slow operation. Instead, if you just want a list of the peer IDs in the cluster you can see it wit hthe `id` command (the `text` output only shows the number of peers):

```sh
ipfs-cluster-ctl --enc=json id
```



## Adding new peers

Adding new peers to a cluster works exactly as described in the [Bootstrapping the Cluster](/documentation/deployment/bootstrap) section. The works-for-all method is to use the `ipfs-cluster-service daemon --bootstrap` flag.

## Removing peers

### CRDT mode

In CRDT-mode, peers can be simply stopped. Other peers may consider them part of the peerset until their last metric expires. Thus, reducing the [metric ttls](/documentation/guides/metrics) will speed this up.

### Raft mode

In Raft-mode, peers can be stopped, but then they will not be available to participate in cluster operations and will still be considered part of the peerset. This is perfectly fine if the peer will be re-started on the future and the majority of cluster peers will still be online. Otherwise, the departing peer needs to be manually removed with:

```sh
ipfs-cluster-ctl peers rm <pid>
```

<div class="tipbox warning">Raft peers can only be removed when the Raft cluster has at least 50% of its members online.</div>

This can be called from the peer shutting down (self-removal) or from any other peer. In any case, it will cause the peer to shut itself down when it realizes it has been removed.

Alternatively, the `leave_on_shutdown` configuration option can be set to `true`. With this option, a peer shutting down cleanly will try to remove itself from the Raft peerset in the process. **Peers which have been removed from the Raft peerset** automatically clean their state and will need to bootstrap again to it to re-join it.
