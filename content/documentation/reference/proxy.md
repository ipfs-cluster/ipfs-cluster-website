+++
title = "IPFS Proxy"
weight = 20
+++

# IPFS Proxy

The IPFS Proxy is an endpoint which presents the IPFS HTTP API in the following way:

* Some requests are intercepted and trigger cluster operations
* All non-intercepted requests are forwarded to the IPFS daemon attached to the cluster peer

This endpoint is enabled by default, and listens by default on `/ip4/127.0.0.1/tcp/9095` and is provided by the `ipfshttp` connector component. It can be disabled by removing its section from the [configuration file](/documentation/administration/configuration).

The requests that are intercepted are the following:

* `/add`: the proxy adds the content to the local ipfs daemon and pins the resulting hash[es] in cluster.
* `/pin/add`: the proxy pins the given CID in cluster.
* `/pin/update`: the proxy updates the given pin to a new one in cluster.
* `/pin/rm`: the proxy unpins the given CID from cluster.
* `/pin/ls`: the proxy lists the pinned items in cluster.
* `/repo/stat`: the proxy responds with aggregated `/repo/stat` from all connected IPFS daemons.

Responses from the proxy mimic the IPFS daemon responses, thus allowing to drop-in this endpoint in places where the IPFS API was used before. For example, you can use the `go-ipfs` CLI as follows:

* `ipfs --api /ip4/127.0.0.1/tcp/9095 pin add <cid>`
* `ipfs --api /ip4/127.0.0.1/tcp/9095 add myfile.txt`
* `ipfs --api /ip4/127.0.0.1/tcp/9095 pin rm <cid>`
* `ipfs --api /ip4/127.0.0.1/tcp/9095 pin ls`

<div class="tipbox tip">The IPFS Proxy endpoint can be used with the <a href="https://github.com/ipfs-shipyard/ipfs-companion">IPFS companion extension</a>.</div>

The responses would come from cluster, not from `go-ipfs`. The intercepted endpoints aim to mimic the format, headers and response codes from IPFS. If you have custom headers configured in IPFS, you will need to add their names them to the `ipfsproxy.extract_headers_extra` configuration option.
