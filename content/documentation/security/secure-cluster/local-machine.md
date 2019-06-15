+++
title = "By Default REST and Proxy API Only Works on Local Machines"
weight = 3
+++

_Found in https://cluster.ipfs.io/documentation/security/_

## IPFS and IPFS Proxy endpoints


IPFS Cluster peers communicate with the IPFS daemon (usually running on localhost) via plain, unauthenticated HTTP, using the IPFS HTTP API (by default on /ip4/127.0.0.1/tcp/9095.

IPFS Cluster peers also provide an unauthenticated HTTP IPFS Proxy endpoint, controlled by the ipfshttp.proxy_listen_multiaddress option which defaults to /ip4/127.0.0.1/tcp/9095.

Access to any of these two endpoints imply control of the IPFS daemon and of IPFS Cluster to a certain extent. Thus they run on localhost by default.

The IPFS Proxy will attempt to mimic CORS configuration from the IPFS daemon. If your application security depends on CORS, you should configure the IPFS daemon first, and then verify that the responses from hijacked endpoints in the proxy look as expected. OPTIONS requests are always proxied to IPFS.