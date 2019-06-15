+++
title = "Don't let Unknown Peers Access Your Cluster"
weight = 1
+++

_Found in https://cluster.ipfs.io/documentation/security/_


## Cluster swarm endpoints

IPFS Cluster peers communicate with each others using libp2p-encrypted streams (secio). This streams are by default protected by a shared cluster secret (using the libp2p private networks feature).

The endpoint is controlled by the cluster.listen_multiaddress configuration key, defaults to /ip4/0.0.0.0/tcp/9096 and represents the listening address to establish communication with other peers (via Remote RPC calls and consensus protocol).

The shared secret controls authorization by locking this endpoint so that only the cluster peers holding the secret can communicate.

If the secret configuration value is empty, then nothing prevents anyone from sending RPC commands to the cluster RPC endpoint and thus, controlling the cluster and the IPFS daemon (at least when it comes to pin/unpin/pin ls and swarm connect operations. IPFS Cluster administrators should therefore be careful keep this endpoint unaccessible to third-parties when no  cluster.secret is set.