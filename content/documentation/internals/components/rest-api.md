+++
title = "REST API"
weight = 3
+++ 

# The Rest API

This is the component which provides the REST API implementation to interact with Cluster.

|Key|Default|Description|
|:---|:-------|:-----------|
|`http_listen_multiaddress` | `"/ip4/127.0.0.1/tcp/9094"` | The API HTTP listen endpoint. Set empty to disable the HTTP endpoint. |
|`ssl_cert_file` | `""` | Path to an x509 certificate file. Enables SSL on the HTTP endpoint. Unless an absolute path, relative to config folder. |
|`ssl_key_file` | `""` | Path to a SSL private key file. Enables SSL on the HTTP endpoint. Unless an absolute path, relative to config folder. |
|`read_timeout` | `"0s"` | Parameters for https://godoc.org/net/http#Server . Note setting this value might break adding to cluster, if the timeout is shorter than the time it takes to add something to the cluster. |
|`read_header_timeout` | `"30s"` | Parameters for https://godoc.org/net/http#Server . |
|`write_timeout` | `"0s"` | Parameters for https://godoc.org/net/http#Server . Note setting this value might break adding to cluster, if the timeout is shorter than the time it takes to add something to the cluster. |
|`idle_timeout` | `"30s"` | Parameters for https://godoc.org/net/http#Server . |
|`libp2p_listen_multiaddress` | `""` | A listen multiaddress for the alternative libp2p host. See below. |
|`id` | `""` | A peer ID for the alternative libp2p host (must match `private_key`). See below. |
|`private_key` | `""` | A private key for the alternative libp2p host (must match `id`). See below. |
|`basic_auth_credentials` | `null` | An object mapping `"username"` to `"password"`. It enables Basic Authentication for the API. Should be used with SSL-enabled or libp2p-endpoints. |
|`headers` | `null` | A `key: [values]` map of headers the API endpoint should return with each response to `GET`, `POST`, `DELETE` requests. i.e. `"headers": {"header_name": [ "v1", "v2" ] }`. Do not place CORS headers here, as they are fully handled by the options below. |
|`cors_allowed_origins`| `["*"]` | CORS Configuration: values for `Access-Control-Allow-Origin`. |
|`cors_allowed_methods`| `["GET"]` | CORS Configuration: values for `Access-Control-Allow-Methods`. |
|`cors_allowed_headers`| `[]` | CORS Configuration: values for `Access-Control-Allow-Headers`. |
|`cors_exposed_headers`| `["Content-Type", "X-Stream-Output",` `"X-Chunked-Output", "X-Content-Length"]` | CORS Configuration: values for `Access-Control-Expose-Headers`. |
|`cors_allow_credentials`|  `true` | CORS Configuration: value for `Access-Control-Allow-Credentials`. |
|`cors_max_age`|  `"0s"` | CORS Configuration: value for `Access-Control-Max-Age`. |

The REST API component automatically, and additionally, exposes the HTTP API as a libp2p service on the main libp2p cluster Host (which listens on port `9096`). Exposing the HTTP API as a libp2p service allows users to benefit from the channel encryption provided by libp2p. Alternatively, the API supports specifying a fully separate libp2p Host by providing `id`, `private_key` and `libp2p_listen_multiaddress`. When using a separate Host, it is not necessary for an API consumer to know the cluster secret. Both the HTTP and the libp2p endpoints are supported by the [API Client](https://godoc.org/github.com/ipfs/ipfs-cluster/api/rest/client) and by [`ipfs-cluster-ctl`](/documentation/ipfs-cluster-ctl/).
