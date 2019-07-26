+++
title = "Upgrades"
weight = 70
aliases = [
    "/documentation/upgrades"
]
+++

# Upgrades

The IPFS Cluster project releases new versions regularly. This section describes the procedure to upgrade Clusters with minimal or no downtime.

The main consideration is that:

<div class="tipbox warning"> All the cluster peers need to run the same cluster `major.minor` (but they can have different patch numbers). i.e.: <code>0.10.x</code> or <code>0.11.x</code>.</div>

Otherwise, peers will not be able to communicate. We plan to move to a more flexible scheme soon, as the feature set stabilizes.

The general approach to is to:

1. Replace `ipfs-cluster-ctl` and `ipfs-cluster-service` with their new versions.
2. Restart all the peers.

For compatible versions (patch bumps), this can be done gradually without general downtime.

In the case of `raft`, this only works if:

* `leave_on_shutdown` is set to `false`. Otherwise, those peer will need to be bootstrapped on the next start.
* `wait_for_leader_timeout` is sufficiently high to account for the restart of all peers (default should be ok in most cases)

