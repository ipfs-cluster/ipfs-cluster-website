+++
title = "Architecture"
+++

# IPFS Cluster architecture

This document gives an overview of the IPFS Cluster architecture.

## Modularity

IPFS Cluster architecture attempts to be as modular as possible, with interfaces between its modules (components) clearly defined, in a way that they can:

  * Be swapped for alternative implementations, improved implementations, separately without affecting the rest of the system
  * Be easily tested in isolation

## Components

<center><img alt="A Cluster peer" title="A Cluster peer" src="/cluster/diagrams/png/peer.png" width="500px" /></center>


IPFS Cluster consists of:

  * The definitions of components and their interfaces and related types (`ipfscluster.go`)
  * The **Cluster** main-component which binds together the whole system and offers the Go API (`cluster.go`). This component takes an arbitrary:
    * **API**: a component which offers a public facing API. Default: `RESTAPI`
    * **IPFSConnector**: a component which talks to the IPFS daemon and provides a proxy to it. Default: `ipfshttp`
    * **State**: a component which keeps a list of Pins (maintained by the Consensus component). Default: `mapstate`
    * **PinTracker**: a component which tracks the pin set, makes sure that it is persisted by IPFS daemon as intended. Default: `maptracker`
    * **PeerMonitor**: a component to log metrics and detect peer failures. Default: `pubsubmon`
    * **PinAllocator**: a component to decide which peers should pin a CID given some metrics. Default: `descendalloc`
    * **Informer**: a component to collect metrics which are used by the `PinAllocator` and the `PeerMonitor`. Default: `disk`
  * The **Consensus** component. The consensus component uses `go-libp2p-raft` via `go-libp2p-consensus`. While it is attempted to be agnostic from the underlying consensus implementation, it is not possible in all places. These places are however well marked (everything that calls `Leader()`). Default: `raft`.

Components perform a number of functions and need to be able to communicate with eachothers: i.e.:

  * the API needs to use functionality provided by the main component
  * the PinTracker needs to use functionality provided by the IPFSConnector
  * the main component needs to use functionality provided by the main component of different peers

## RPC API

Communication between components happens through the RPC API: a set of functions which stablishes which functions are available to components (`rpc_api.go`).

The RPC API uses `go-libp2p-gorpc`. The main Cluster component runs an RPC server. RPC Clients are provided to all components for their use. The main feature of this setup is that **Components can use `go-libp2p-gorpc` to perform operations in the local cluster and in any remote cluster node using the same API**.

This makes broadcasting operations and contacting the Cluster leader really easy. It also allows to think of a future where components may be completely arbitrary and run from different applications. Local RPC calls, on their side, do not suffer any penalty as the execution is short-cut directly to the correspondant component of the Cluster, without network intervention.

On the down-side, the RPC API involves "reflect" magic and it is not easy to verify that a call happens to a method registered on the RPC server. Every RPC-based functionality should be tested. Bad operations will result in errors so they are easy to catch on tests.

## Code layout

Components are organized in different submodules (i.e. `pintracker/maptracker` represents component `PinTracker` and implementation `MapPinTracker`). Interfaces for all components are on the base module. Executables (`ipfs-cluster-service` and `ipfs-cluster-ctl` are also submodules to the base module).

## Configuration

A `config` module provides support for a central configuration file which provides configuration sections defined by each component by providing configuration objects which implement a `ComponentConfig` interface.
