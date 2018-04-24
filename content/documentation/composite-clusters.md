+++
title = "Composite clusters"
+++


# Composite clusters

The `ipfs-cluster-service` process provides a Proxy-To-IPFS endpoint, which effectively allows a cluster peer to present itself as if it were an IPFS daemon. This allows to use a cluster peer (from a different cluster) instead of an IPFS daemon, giving origin to the *composite clusters* idea.

## The IPFS Proxy

The IPFS Proxy is an endpoint which presents the IPFS HTTP API in the following way:

* Some requests are intercepted and trigger cluster operations
* All non-intercepted requests are forwarded to the IPFS daemon attached to the cluster peer

This endpoint listens by default on `/ip4/127.0.0.1/tcp/9095` and is provided by the `ipfshttp` connector component.

The requests that are intercepted are the following:

* `/add`: the proxy adds the content to the local ipfs daemon and pins the resulting hash[es] in cluster.
* `/pin/add`: the proxy pins the given CID in cluster.
* `/pin/rm`: the proxy unpins the given CID from cluster.
* `/pin/ls`: the proxy lists the pinned items in cluster.

Responses from the proxy mimic the IPFS daemon responses, thus allowing to drop-in this endpoint in places where the IPFS API was used before. For example, you can use the `go-ipfs` CLI as follows:

* `ipfs --api /ip4/127.0.0.1/tcp/9095 pin add <cid>`
* `ipfs --api /ip4/127.0.0.1/tcp/9095 add myfile.txt`
* `ipfs --api /ip4/127.0.0.1/tcp/9095 pin rm <cid>`
* `ipfs --api /ip4/127.0.0.1/tcp/9095 pin ls`

The responses would come from cluster, not from `go-ipfs`.

Note that the intercepted endpoints aim to mimic the format and response code from IPFS, but they may lack headers. If you encounter a problem, open an issue so we can address it.

## A Cluster of Clusters

As mentioned above, the Proxy endpoint allows to create a *cluster of clusters*. This functionality is, however, not fully tested and the particular usecases not fully developed.

## Next steps: [`ipfs-cluster-service`](/documentation/ipfs-cluster-service)
