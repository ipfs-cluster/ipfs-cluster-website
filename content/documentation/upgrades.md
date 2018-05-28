+++
title = "Upgrades"
+++

# Upgrades

This section describes the upgrade procedure for IPFS Cluster. There are several considerations:

* All the cluster peers need to run the same cluster version (`X.X.X`, including the patch number)
* If the state format changes, a state upgrade is needed (with the peer offline)

## Standard upgrade procedure

The following upgrade procedure provides the fastest and most straightforward upgrade path. It plays nicely with
any deployment automation tools or with docker.

For this method to work it is required that:

* `remove_on_shutdown` is set to `false`
* `wait_for_leader_timeout` is sufficiently high to account for the restart of all peers (default should be ok in most cases)

Steps:

1. Upgrade the `ipfs-cluster-service` and `ipfs-cluster-ctl` binaries (or containers)
2. At the same time, restart all the cluster peers running the service with `ipfs-cluster-service daemon --upgrade`

This will perform any state format migrations when necessary. Since all the peers start at once, using the new version of `ipfs-cluster-service` and with an up to date state, the cluster will be ready to work right away.

If you are using Docker, replacing your containers with the new image should be enough (it runs `ipfs-cluster-service daemon --upgrade` by default).

## Bootstrap upgrade procedure

Another way to perform an update is to sequentially remove the peers of the cluster, upgrade them, and the bootstrap them again.

Steps:

1. Run `ipfs-cluster-ctl peer rm <peerID>` for each cluster peer, except the last (a single-peer cluster will not remove its only peer).
2. This will shutdown the removed peers and clean their states
3. Shutdown the remaining peer, upgrade the `ipfs-cluster-service` and `ipfs-cluster-ctl` binaries
4. Run `ipfs-cluster-service state upgrade` and restart the peer (or simply restart it with `ipfs-cluster-service daemon --upgrade`)
5. Upgrade the binaries in the rest of the peers that were removed from the original cluster
6. Restart the rest of the peers sequentially. Because they were removed, they should have the existing peers multiaddresses configured as `bootstrap` addresses, which they will use to re-join the cluster. Since they were removed, the state was cleaned up and there is no need to upgrade it. They will receive a full copy of the state upon starting.

## Troubleshooting upgrades

The most important thing when performing an upgrade is to keep the cluster state (which stores the pinset) safe.

If the peers are removed from cluster, the state is automatically cleaned, but a backup copy is stored (see [data persistence and backups](/documentation/deployment/#data-persistence-and-backups)). You can always recover a backed up state by renaming the backup folder to the original name (`ipfs-cluster-data`). Then, you can export the state and import it on a different peer if needed (`state export/import`), making sure that it is running the same version as the peer from which it was exported.

Finally, as long as you have a valid state, you can upgrade the format with `ipfs-cluster-service state upgrade` after installing the new IPFS Cluster version. So, a full disaster recovery procedure would be as follows:

  1. Locate a peer that still stores the state, either in `ipfs-cluster-data` or as a backup copy of it
  2. Before upgrading, run `ipfs-cluster-service state export`
  3. Cleanup your peer or setup a new peer from scratch with the old version of IPFS Cluster
  4. Run `ipfs-cluster-service state import` to import the state copy from step 2
  5. Upgrade the IPFS Cluster binaries
  6. Run `ipfs-cluster-service state upgrade` to upgrade the imported state
  7. Start the peer as a single-peer-cluster.
  8. Fully cleanup, upgrade and bootstrap the rest of the peers to the running one.


## Next steps: [Internals](/documentation/internals)
