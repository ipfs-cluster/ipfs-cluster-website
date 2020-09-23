+++
title = "Upgrades"
weight = 70
aliases = [
    "/documentation/upgrades"
]
+++

# Upgrades

The IPFS Cluster project releases new versions regularly. This section describes the procedure to upgrade Clusters with minimal or no downtime.

It is very important to check the [changelog](https://github.com/ipfs/ipfs-cluster/blob/master/CHANGELOG.md) before upgrading, in order to get familiar with changes since the last version. All information about potential incompatibilities and breaking changes are included there.

The other main consideration is that:

<div class="tipbox warning"> Starting on v0.12.1, all the cluster peers need to run on the same RPC protocol version.</div>

The RPC Protocol version can be seen in the response of `ipfs-cluster-ctl --enc=json id` (`rpc_protocol_version` field), or in the [source code](https://github.com/ipfs/ipfs-cluster/blob/master/version/version.go). It should remain stable accross multiple IPFS Cluster releases and it only changes when non-backwards compatible RPC changes happen.

If there is a mismatch between the RPC protocol versions of the peers, they will not be able to communicate.

When the RPC protocol version is the same, the core functionality of peers will work even if the cluster is made of peers running different versions, unless the [changelog](https://github.com/ipfs/ipfs-cluster/blob/master/CHANGELOG.md) states otherwise.

## Running the upgrade

The general approach to is to:

1. Upgrade `ipfs-cluster-ctl`, `ipfs-cluster-service` or `ipfs-cluster-follow` to the new version.
2. Restart all the peers (either sequentially or at once).

In the case of `raft`, the restart only works if:

* `leave_on_shutdown` is set to `false`. Otherwise, those peer will need to be bootstrapped on the next start.
* `wait_for_leader_timeout` is sufficiently high to account for the restart of the majority peers in the cluster (default should be ok in most cases)
