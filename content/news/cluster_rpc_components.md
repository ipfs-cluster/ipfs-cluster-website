+++
title = "RPC Components in IPFS Cluster"
date = 2018-08-22
publishdate = 2018-08-22
author = "@hsanjuan"
+++

## RPC Components in IPFS Cluster | @hsanjuan

In this post, I would like to perform a deep dive into one of the architectural features of IPFS Cluster which has turned out to be extremely useful for building a distributed application on top of libp2p: *Components*.

Cluster *Components* are modules that implement different parts of Cluster. For example, the [`restapi` module](https://godoc.org/github.com/ipfs/ipfs-cluster/api/rest) implements the HTTP server that provides the API to interact with a Cluster peer. The [`ipfshttp` module](https://godoc.org/github.com/ipfs/ipfs-cluster/ipfsconn/ipfshttp) implements functionality to interact with the IPFS daemon. In the following diagram, we can see the multiple components that make up an IPFS Cluster peer:

<center><img alt="Components in an IPFS Cluster peer" title="Components in an IPFS Cluster peer" src="/cluster/diagrams/png/peer.png" width="500px" /></center>

When I started developing IPFS Cluster, some things were very clear:

* We would need modules with fixed interfaces for the very distinct functionality areas
* The implementations of these modules would likely need not only to be improved over time, but probably be fully replaced by alternative implementations. For example, perhaps we would have to write a different API module in addition to the original one.
* Unlike a traditional application, where all your objects/modules/classes are at hand as part of the running process, the modules in a distributed application like Cluster would likely need to easily interact with other peers, running in a different computer.


The approach to the first two items in that list is rather obvious and consists in dividing splitting the functionality in modules and giving them the right interfaces, something which the Go language supports very well. The last item however, prompted me to put RPC at the center of the design for every Cluster peer and every module playing a part in it. This meant:

* Creating an internal [RPC API](https://godoc.org/github.com/ipfs/ipfs-cluster#RPCAPI), that every Cluster peer offers, exposing all of the functionality provided by the modules.
* Defining a base [`Component` interface](https://godoc.org/github.com/ipfs/ipfs-cluster#Component) that every module would need to implement and which makes them RPC-powered (with an RPC client), as I'll explain below.

These RPC-enabled modules became what we call *Components* and their particularlity is being **RPC-first: any functionality not belonging to the component itself is accessed via RPC, even if it belongs to the same peer**.

The main Component (called the [`Cluster` component](https://godoc.org/github.com/ipfs/ipfs-cluster#NewCluster)), ties all components together. It is in charge of running the RPC server for the Cluster peer and making an RPC client available to all components.

Thus, whenever a component needs to make use of functionality offered by its peer, or by another peer, the approach is the same (pseudocode):

```
rpcClient.Call(<peerID>, <method>, <argument>, <response>)
```

This may seem counter intuitive at first. For example, when the `restapi` component receives a [`POST /pins/<cid>`](https://github.com/ipfs/ipfs-cluster/blob/b9485626d14b0d9bcf76ac5e645269df2f2e4e97/api/rest/restapi.go#L590), it doesn't have access to the [`Cluster.Pin()`](https://godoc.org/github.com/ipfs/ipfs-cluster#Cluster.Pin) method offered by the main component directly. Instead, it needs to `rpcClient.Call("<localPeerID>", "Pin", cid, nil)`.

However, it soon became clear that  this becomes really convenient when needing to orchestrate actions on several Cluster peers, as shown by several examples from the code base:

* Broadcasting an action to the whole suddenly becomes extremely natural. For example, the [`Peers()` method (`peers ls`)](https://github.com/ipfs/ipfs-cluster/blob/b9485626d14b0d9bcf76ac5e645269df2f2e4e97/cluster.go#L1089) action is just a parallel call to the `ID()` exposed by every peer via RPC. The response is an array of the individual answers provided by each peer.
* Redirecting an action to the right actor becomes totally transparent. For example, our `raft` layer (`Consensus` component), needs to redirect all write actions to the Raft Leader. When a peer is performing one of these actions and sees the leader is a different peer, it just uses [RPC to trigger the same method in the right peer](https://github.com/ipfs/ipfs-cluster/blob/b9485626d14b0d9bcf76ac5e645269df2f2e4e97/consensus/raft/consensus.go#L250).
* There is no cumbersome code overhead when it comes to performing actions anywhere in the Cluster vs. performing them locally. For example, when adding content through Cluster, the peer receiving the upload will chunk the content and then will send the resulting blocks directly to the [`IPFSConnector.BlockPut` method in the peers allocated to receive that content](https://github.com/ipfs/ipfs-cluster/blob/b9485626d14b0d9bcf76ac5e645269df2f2e4e97/adder/util.go#L18).

*RPC-first* means that any submodule has full access to all of the Cluster functionality anywhere in the Cluster, for free (or almost, as we'll see below). As such, doing things anywhere in the Cluster is as natural as doing them in the local peer.

### The RPC library: go-libp2p-gorpc

Every IPFS Cluster peer runs on top of it's own [libp2p Host](https://godoc.org/github.com/libp2p/go-libp2p-host), and exposes different services on it. Because libp2p multiplexes several streams onto the same connection, we can run dozens of different services and expose them on the same socket. libp2p facilitates things a lot: we do not need to do connection management, nor worry about closing and opening [tcp] connections (a very expensive operation), nor even knowing in which IP or port our desntination peer is, and all our communications occur encrypted and under a private network.

The RPC server, which receives RPC requests and sends the call to the appropriate Component and Method, is one of those services. 

We use [go-libp2p-gorpc](https://github.com/libp2p/go-libp2p-rpc) as our RPC library. It started as a libp2p-powered clone of Go's original [`net/rpc`](https://golang.org/pkg/net/rpc/) and, while it has evolved a little bit, it still remains a very simple and easy to use module. It cannot compete with [`gRPC`](https://godoc.org/google.golang.org/grpc) in terms of functionality, but it certainly represents a reduced overhead (no protobuffers generation) along with some helpers that come very handy.

The most useful of these helpers is the local-server-shortcut. Making remote RPC calls is not cheap as the request and response need to travel on the wire. Local RPC calls are better, but libp2p Hosts cannot open streams to themselves, and if they could it would still add some lag. In order to have super fast local calls, `go-libp2p-rpc` allows [initializing the RPC `Client` with a `Server`](https://godoc.org/github.com/hsanjuan/go-libp2p-gorpc#NewClientWithServer). When the destination peer ID is empty (`""`), or matches the local libp2p host, the server method for that call is invoked directly. This saves us the need to serialize the arguments, write the request, read the response from the connection and deserialize it (even if it was a local call). **Cluster components calling RPC methods on the local peer benefit from the RPC layer without suffering a large performance penalty**.

Another trick is that `Client` also offers a [`MultiCall` method](https://godoc.org/github.com/hsanjuan/go-libp2p-gorpc#Client.MultiCall), which facilitates making the same request to several destinations in parallel. All calls take contexts which, upon cancelled, automatically cancel the context used to call the RPC methods on the server side.

### Component testing

One of the advantages of using RPC for all inter-component communication is that we can very easily isolate the components for testing, by simply creating partial RPC server mocks which implement just the functionality required by the component (or the test).

For example, our `maptracker` module, an implementation of the `PinTracker` component, uses a custom [RPC server implementation](https://github.com/ipfs/ipfs-cluster/blob/b9485626d14b0d9bcf76ac5e645269df2f2e4e97/pintracker/maptracker/maptracker_test.go#L26) which provides the `IPFSPin` method. Depending on what is pinned, this server will simulate that IPFS takes a very long time to pin something, or that the request has been cancelled, or simply that the item gets pinned very quickly. Thus we can correctly test things like cancelling ongoing IPFS Pin requests when, for example, an Unpin request is received.

Mocks are always an option when testing, specially when Go code makes correct use of interfaces, but in the case of the RPC we don't need to mock every method of the RPC API (as we would have to do if we were creating a mock implementation to satisfy an interface), but just those which we are going to use. Even so, many tests benefit from a common [dummy RPC server implementation](https://github.com/ipfs/ipfs-cluster/blob/master/test/rpc_api_mock.go#L31).

### Re-implementing components

The Component architecture has made it easy to provide alternative or replacement implementations for components. One of the examples is the [`PinTracker` component](https://godoc.org/github.com/ipfs/ipfs-cluster#PinTracker), which triggers, cancels and tracks errors from requests to the `IPFSConnector` component as new pins are tracked in the system.

This component had a [`maptracker` implementation](https://godoc.org/github.com/ipfs/ipfs-cluster/pintracker/maptracker), which stores all the information in memory. We recently added an [`stateless` implementation](https://godoc.org/github.com/ipfs/ipfs-cluster/pintracker/stateless) which relies on the IPFS daemon pinset as well as the shared state to piece together the PinTracker state, keeping track only of errors, and thus reducing memory usage with really big pinsets.

We also re-implemented the [`PeerMonitor` component](https://godoc.org/github.com/ipfs/ipfs-cluster#PeerMonitor), using [Pubsub](https://godoc.org/github.com/ipfs/ipfs-cluster/monitor/pubsubmon) instead of RPC calls to broadcast peer metrics.

Because components share the same RPC API and must implement the same interfaces, different peers in a Cluster may potentially run with different implementations of the same component. 

### A final note and future path for improvement

The Cluster Component architecture has resulted very handy in building IPFS Cluster and currently saves a lot of effort when approaching the implementation of new functionality that requires coordinated actions among several peers. However, using this *RPC-first* approach also comes with some downsides.

The first downside is the need to be able to serialize objects and responses used in RPC methods. This means, that every argument and every response provided in RPC methods needs to be translatable to something that can be unmarshaled into the same object type on the other side. This is a common requirement for all RPC protocols, but since we need to use the RPC API for local calls too (even with the local-call-shortcut explained above), we suffer a penalty translating objects to their serializable versions. I.e. a `*cid.Cid` type cannot be sent as such, so we make it a `string` first. This also implies designing APIs types with this limitations in mind. Depending on the type and the size of data, making a type serializable might take way longer time that it would take to just pass a pointer to a local method call. [**UPDATE**: As of v0.10.0 Cluster all internal types are serializable directly, so we do not need to make any copies anymore].

The `go-libp2p-gorpc` library puts some hard constraints on how the RPC server methods look like (1 input and 1 output argument). It does not require definitions or code pre-generate code like `gRPC`, but on the other side, it becomes easier to introduce bad runtime errors, for example, calling a method with different types than expected.

The use of RPC-for-all also needs to be accompanied by considerations on security. Currently, we rely on libp2p private network's pre-shared-key to protect all internal libp2p services. But in the future we will have to explore additional authorization methods, probably associated at each request type. The good thing about libp2p is that the requests are directly authenticated by the peer ID originating them, so that side of things is solved for us. [**UPDATE**: `go-libp2p-gorpc` now offers per-method authorization support].

Finally, if you're planning to transmit large amounts of data over RPC you will need an RPC layer that supports streaming (hopefully in a duplex fashion for request and responses). This is something that we'll likely end up adding to `go-libp2p-gorpc`.

If you read down here, I hope you now have a better idea of how different parts of your Cluster peers interact. I will be making regular posts on other parts of the codebase. In the meantime, if you have any questions, feel free to ask in our [Discourse forum](https://discuss.ipfs.io/).
