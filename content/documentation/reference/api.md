+++
title = "REST API"
weight = 10
aliases = [
    "/documentation/developer/api"
]
+++

## REST API Reference

IPFS Cluster peers include an API component which provides HTTP-based access to the peer's functionality. The API attempts to be REST-ful in form and behaviour. It is enabled by default, but it can be disabled by removing its section from the `service.json` configuration file.

We do not mantain ad-hoc API documentation, as it gets easily out of date or, at worst, is innacurate or buggy. Instead, we provide an easy way to find how to do what you need to do by using the `ipfs-cluster-ctl` command.

Running `ipfs-cluster-service --enc=json --debug <command>` will print information about the endpoint, the query options, the request body and raw responses for that command. Use it on a [test cluster](/documentation/quickstart/)!

`ipfs-cluster-ctl` is an HTTP API client to the REST API endpoint with full feature-parity that always works with the HTTP API as offered by a cluster peer on the same version. Anything that `ipfs-cluster-ctl` can do is supported by the REST API. The command flags usually control different request options.

As additional resources:

* All the available API endpoints and their parametres and object formats are supported and documented by the [Go API Client](https://pkg.go.dev/github.com/ipfs/ipfs-cluster/api/rest/client?tab=doc#Client).
* The [API source code is here](https://github.com/ipfs/ipfs-cluster/blob/master/api/rest/restapi.go) (the `routes` method is a good place to start).
* A [Javascript client library](https://github.com/ipfs-cluster/js-cluster-client) also exists.
* The request body for the `/add` endpoint is a bit special, but it works just like the IPFS one. See the [`/api/v0/add` documentation](https://docs-beta.ipfs.io/reference/http/api/#api-v0-add) for information.

The above should be enough to find out about the existing endpoints, their methods and current supported options.

As a final tip, this table provides a quick summary of methods available.

|Method      |Endpoint              |Comment                          |
|:-----------|:---------------------|:--------------------------------|
|`GET`       |`/id`                 |Cluster peer information         |
|`GET`       |`/version`            |Cluster version|
|`GET`       |`/peers`              |Cluster peers|
|`DELETE`    |`/peers/{peerID}`     |Remove a peer|
|`POST`      |`/add`                |Add content to the cluster|
|`GET`       |`/allocations`        |List of pins and their allocations (pinset)|
|`GET`       |`/allocations/{cid}`  |Show a single pin and its allocations (from the pinset)|
|`GET`       |`/pins`               |Local status of all tracked CIDs|
|`POST`      |`/pins/sync`          |Sync local status from IPFS|
|`GET`       |`/pins/{cid}`         |Local status of single CID|
|`POST`      |`/pins/{cid}`         |Pin a CID|
|`POST`      |`/pins/{ipfs\|ipns\|ipld}/<path>`|Pin using an IPFS path|
|`DELETE`    |`/pins/{cid}`         |Unpin a CID|
|`DELETE`    |`/pins/{ipfs\|ipns\|ipld}/<path>`|Unpin using an IPFS path|
|`POST`      |`/pins/{cid}/sync`    |Sync a CID|
|`POST`      |`/pins/{cid}/recover` |Recover a CID|
|`POST`      |`/pins/recover`       |Recover all pins in the receiving Cluster peer|
|`GET`       |`/health/graph`       |  Get connection graph |
