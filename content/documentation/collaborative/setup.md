+++
title = "Hosting a collaborative cluster"
weight = 10
aliases = []
+++

# Collaborative clusters setup

In order to create your own collaborative cluster that other people can subscribe to you will need to:

* [Setup your regular production deployment of IPFS Cluster](#trusted-peers-setup) in CRDT mode (these will be your "trusted peers").
* [Distribute a configuration template](#distributing-a-configuration-template) so that follower peers can easily join the cluster.
* Let users [take advantage of ipfs-cluster-follow](#ipfs-cluster-follow).

## Trusted peers setup

<div class="tipbox tip">Collaborative clusters must use CRDT mode.</div>

The first step in setting a collaborative cluster is to deploy a regular CRDT cluster with one or more peers.

Follow the instructions in the [Production deployment](/documentation/deployment/) section, particularly those related to the [CRDT mode bootstrapping](/documentation/deployment/bootstrap/). The simplest is to run a single-peer cluster, although you may choose to run two or more to have some redundancy.

A summarized version of the instructions for a single peer with default configuration would amount to the following:

```sh
# Start your ipfs daemon
$ ipfs-cluster-service init --consensus crdt
$ ipfs-cluster-service daemon
# Write down:
# - The generated cluster secret (will need to be re-used in other peers)
# - The peer ID (this will be a "trusted peer")
# - The multiaddress on which it will be reachable by other peers (usually /ip4/public_ip/tcp/9096/p2p/peer_id
```


Once you have your base cluster configured and running, you will need to make sure that the `trusted_peers` array in the `crdt` configuration section is set to the peer IDs in your base cluster. Otherwise (if set to the default `*`), ***anyone might be able to modify the pinset and this may be something you don't want***.

Review the resulting configuration in your cluster peers:

* All *trusted peers* in your setup should probably have the same configuration (unless they are running on machines with different requirements)
* `trusted_peers` should be set to the list of peer IDs in the original cluster that are under your control (or someone's trusted control).
* You should have generated a cluster `secret`. It will be ok to distribute this secret later.
* Depending on your Cluster setup, who you plan to join the cluster, and the level of trust on those follower peers, you can set `replication_factor_min/max`. For the general usecase, we recommend leaving at `-1` (everything pinned everywhere). The main usecase of collaborative clusters is to ensure wide distribution and replication of content.
* You can modify the `crdt/cluster_name` value to your liking, but remember to inform your followers about its value.

In principle, followers can use exactly the same configuration as your trusted peers, but we recommend tailoring a specific follower configuration as explained in the next section.

## Distributing a configuration template

Any follower peer can start a IPFS cluster peer that will join your collaborative clusters with these pieces of information:

* The list of `trusted_peers` in the Cluster.
* The full, reachable multiaddress of at least one of those peers.
* The cluster `secret`.
* If changed, the value of `crdt/cluster_name`

It is however better when you can distribute a configuration template which has all the options set right for your cluster. Ultimately, you will want follower peers to run using `ipfs-cluster-follow`, rather than `ipfs-cluster-service`.

### Creating a configuration template for followers

Follower peers can technically use the same configuration as trusted peers but we recommend considering a couple of modifications. The following apply to a copy of your `service.json` file that you will distribute to your followers:

* Set `peer_addresses` to the addresses of your trusted peers. These must be reachable whenever any follower peer starts, so ensure there is connectivity to your cluster.
* Consider removing any configurations in the `api` section (`restapi`, `ipfsproxy`): follower peers should not be told how their peers APIs should look like. Misconfiguring the APIs might open unwanted security holes. `ipfs-cluster-follow` overrides any `api` configuration by creating a secure, local-only endpoint.
* Reset `connection_manager/high_water` and `low_water` to sensible defaults if you modified them for your trusted peers configuration.
* Set `follower_mode` to `true`: while non-trusted peers cannot do anything to the cluster pinset, they can still modify their own view of it, which may be very confusing. This setting (which `ipfs-cluster-follow` activates automatically) ensures useful error messages are returned when trying to perform write actions.
* If you are running multiple collaborative clusters, or expect your users to do so, consider modifying the addresses defined in `listen_multiaddress` by changing the default ports to something else, hopefully unused. You can use `0` as well, so that peers choose a random free port during start, but this will cause that peers change ports on every re-start (how important that is depends on your setup).

After all these changes, you will have a `service.json` file that is ready to be distributed to followers. Test it first:

* `ipfs-cluster-service -c someFolder init`
* Replace the generated default `service.json` with the follower configuration you created.
* Run `ipfs-cluster-service -c someFolder daemon` and make sure a peer starts and joins the main cluster (`ipfs-cluster-ctl peers ls` on one of the trusted peers should show it).

### Distributing the template

Once you have a configuration template to provide to your followers, you can either host it on a webserver and make it accessible through HTTP(s), or, more interestingly, add it to IPFS (and to the cluster you created) and make it accessible through every IPFS daemon's gateway:

```sh
ipfs-cluster-ctl add follower_service.json --name follower-config
```

Once the configuration is on IPFS, any follower peer can be configured from it by reading it via the local IPFS gateway.

For example, when using `ipfs-cluster-service`:

```sh
ipfs-cluster-service init http://127.0.0.1:8080/ipfs/Qm....
```

We, however, recommend using `ipfs-cluster-follow`, instead:

```sh
ipfs-cluster-follow myCluster init http://127.0.0.1:8080/ipfs/Qm...
```

If you have a domain name you can control, we recommend using it to set a [DNSLINK TXT record](https://dnslink.io/) pointing to the hash of the configuration `/ipfs/Qm...`. This way your users can use `http://127.0.0.1:8080/ipns/my.domain.com` instead, and you can update the configuration by updating the `dnslink` value. Configurations are always read during the start of the peer (not during initialization).


## ipfs-cluster-follow

The [`ipfs-cluster-follow`](https://dist.ipfs.io/#ipfs-cluster-follow) command is specially crafted to make it super easy to join collaborative clusters. We recommend that follower peers are always run using this command rather than `ipfs-cluster-service`.

`ipfs-cluster-follow` does a number of things to improve user experience when joining collaborative clusters:

* It allows to initialize and run multiple peers by separating configuration folders for each based on a given cluster name.
* It is streamlined to use IPFS-hosted configuration templates, translating `my.domain.com` to `http://127.0.0.1:8080/ipns/my.domain.com` during initialization.
* It can initialize and run the peer in a single command.
* It runs, by default, a local HTTP API endpoint on a local socket, preventing conflicts for multiple API endpoints listening on the same ports and ensuring the follower peers API cannot be accessed from the outside. Any API configuration provided in the template is discarded.
* It sets `follower_mode` automatically along with a number of other small changes to the config for a better user experience.

You can find more about `ipfs-cluster-follow` [here](/documentation/reference/follow/) and in the [joining a collaborative cluster section](/documentation/collaborative/joining).
