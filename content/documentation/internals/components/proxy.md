+++
title = "Proxy API"
weight = 2
+++ 

# The Proxy Component

This component provides the IPFS Proxy Endpoint. This is an API which mimics the IPFS daemon. Some requests (pin, unpin, add) are hijacked and handled by Cluster. Others are simply forwarded to the IPFS daemon specified by `node_multiaddress`. The component is by default configured to mimic CORS headers configurations as present in the IPFS daemon. For
that it triggers accessory requests to them (like CORS preflights).

|Key|Default|Description|
|:---|:-------|:-----------|
|`node_multiaddress` | `"/ip4/127.0.0.1/tcp/5001"` | The listen addres of the IPFS daemon API. |
|`listen_multiaddress` | `"/ip4/127.0.0.1/tcp/9095"` | The proxy endpoint listening address. |
|`node_https` | `false` | Use HTTPS to talk to the IPFS API endpoint (experimental). |
|`read_timeout` | `"0s"` | Parameters for https://godoc.org/net/http#Server . Note setting this value might break adding to cluster, if the timeout is shorter than the time it takes to add something to the cluster. |
|`read_header_timeout` | `"30s"` | Parameters for https://godoc.org/net/http#Server . |
|`write_timeout` | `"0s"` | Parameters for https://godoc.org/net/http#Server . Note setting this value might break adding to cluster, if the timeout is shorter than the time it takes to add something to the cluster. |
|`idle_timeout` | `"30s"` | Parameters for https://godoc.org/net/http#Server . |
|`extract_headers_extra` | `[]` | If additional headers need to be extracted from the IPFS daemon and used in hijacked requests responses, they can be added here. |
|`extract_headers_path` | `"/api/v0/version"` | When extracting headers, a request to this path in the IPFS API is made. |
|`extract_headers_ttl` | `"5m"` | The extracted headers from `extract_headers_path` have a TTL. They will be remembered and only refreshed after the TTL. |
