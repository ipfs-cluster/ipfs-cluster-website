+++
title = "Security"
+++

# Security

This section explores some security considerations when running IPFS Cluster.

There are four types of endpoins in IPFS Cluster to be taken into account when protecting access to the system.

## Internal endpoints

IPFS Cluster peers communicate with each others using libp2p-encrypted streams (`secio`). This streams are by default protected by a shared *cluster secret* (using the libp2p *private networks* feature).

The endpoint is controlled by the `cluster.listen_multiaddress` configuration key, defaults to `/ip4/0.0.0.0/tcp/9096` and represents the listening address to establish communication with other peers (via Remote RPC calls and consensus protocol).

The *shared secret* controls authorization by locking this endpoint so that only the cluster peers holding the secret can communicate.

If the `secret` configuration value is empty, then **nothing prevents anyone from sending RPC commands to the cluster RPC endpoint** and thus, controlling the cluster and the IPFS daemon (at least when it comes to pin/unpin/pin ls and swarm connect operations. **IPFS Cluster administrators should therefore be careful keep this endpoint unaccessible to third-parties when no `cluster.secret` is set**.

## HTTP API endpoints

IPFS Cluster peers provide by default an **HTTP API endpoint** which can be configured with SSL. It also provides a **libp2p API endpoint**, which re-uses either the Cluster libp2p host or a specifically configured libp2p host.

These endpoints are controlled by the `restapi.http_listen_multiaddress` (default `/ip4/127.0.0.1/tcp/9094`) and the `restapi.libp2p_listen_multiaddress` (if a specific `private_key` and `id` are configured in the `restapi` section).

Note that when the Cluster libp2p host is re-used to provide the libp2p API endpoint (which listens on `0.0.0.0`) the endpoint is automatically authenticated by the *cluster secret*.

Both endpoints support **Basic Authentication** but are unauthenticated by default.

Access to these endpoints allow to fully control IPFS Cluster, so they should be adecuately protected when they are opened up to other than `localhost`. The secure channel provided by the configurable SSL or libp2p endpoint, along with Basic Authentication, allow to safely use these endpoints for remote administration.

## IPFS and IPFS Proxy endpoints

IPFS Cluster peers communicate with the IPFS daemon (usually running on localhost) via plain, unauthenticated HTTP, using the IPFS HTTP API (by default on `/ip4/127.0.0.1/tcp/9095`.

IPFS Cluster peers also provide an unauthenticated HTTP IPFS Proxy endpoint, controlled by the `ipfshttp.proxy_listen_multiaddress` option which defaults to `/ip4/127.0.0.1/tcp/9095`.

Access to any of these endpoints imply control of the IPFS daemon and of IPFS Cluster to a certain extent. Thus they run on `localhost` by default.
