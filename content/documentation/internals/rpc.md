+++
title = "RPC API"
weight = 2
+++

# RPC API

Communication between components happens through the RPC API: a set of functions which stablishes which functions are available to components (`rpc_api.go`).

The RPC API uses `go-libp2p-gorpc`. The main Cluster component runs an RPC server. RPC Clients are provided to all components for their use. The main feature of this setup is that **Components can use `go-libp2p-gorpc` to perform operations in the local cluster and in any remote cluster node using the same API**.

This makes broadcasting operations and contacting the Cluster leader really easy. It also allows to think of a future where components may be completely arbitrary and run from different applications. Local RPC calls, on their side, do not suffer any penalty as the execution is short-cut directly to the correspondant component of the Cluster, without network intervention.

On the down-side, the RPC API involves "reflect" magic and it is not easy to verify that a call happens to a method registered on the RPC server. Every RPC-based functionality should be tested. Bad operations will result in errors so they are easy to catch on tests.