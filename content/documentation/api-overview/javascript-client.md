+++
title = "Javascript Client"
weight = 2
+++ 


# The JavaScript Client

> A client library for the IPFS Cluster HTTP API, implemented in JavaScript.

**UNOFFICIAL AND ALPHA**

This is a port of `ipfs/js-ipfs-api` adapted for the API exposed by `ipfs/ipfs-cluster`.

## Install

This module can be installed through npm directly from the github repository.

`npm install https://github.com/te0d/js-ipfs-cluster-api`

### Dependencies

This module requires `ipfs-cluster` to be running. It is assumed that the IPFS
Cluster API is running on "127.0.0.1:9094".

## Usage

To import the module:

```
var ipfsClusterAPI = require('ipfs-cluster-api')
```

```
// connect to ipfs-cluster daemon API server (displayed are default values)
var ipfsCluster = ipfsClusterAPI('localhost', 9094, {protocol: 'http'})
```

### API

The API is currently a work-in-progress. The exposed methods are designed
to be similar to `ipfs-cluster-ctl` provided in `ipfs/ipfs-cluster`.

```
ipfsCluster.id([options], [callback])

ipfsCluster.peers.ls([options], [callback])
ipfsCluster.peers.add(addr, [options], [callback]) // e.g. /ip4/1.2.3.4/tcp/1234/<peerid>
ipfsCluster.peers.rm(peerid, [options], [callback])

ipfsCluster.pin.ls([cid], [callback])
ipfsCluster.pin.add(cid, [options], [callback])   // e.g. { "replication_factor": 2 }
ipfsCluster.pin.rm(cid, [options], [callback])

ipfsCluster.status([cid], [callback])
ipfsCluster.sync([cid], [callback])
ipfsCluster.recover(cid, [options], [callback])

ipfsCluster.version([options], [callback])
```

## Maintainer

This is a side project of mine (te0d).

The code is mostly from `js-ipfs-api` modified to consume the `ipfs-cluster` API.

## Contribute

PRs Accepted.

## License

MIT