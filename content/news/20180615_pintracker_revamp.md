+++
title = "PinTracker revamp"
+++

## 20180615 | PinTracker Revamp | @lanzafame

In this post, I am going to cover how the IPFS Cluster's PinTracker component used to work, what some of the issues with that implementation were, how we fixed them, and where to go next.

#### How the PinTracker worked

First, the purpose of the pintracker: the pintracker serves the role of ferrying the appropriate state from IPFS Cluster's shared state to a peer's ipfs daemon state.

How this occurs is as follows:
- IPFS Cluster receives a request to Pin a particular Cid
- this request is routed to the consensus component, where it is stored in the distributed log and then an RPC call to Track the Cid is made to the pintracker
- the pintracker then creates and stores the PinInfo in an internal map, before making a Pin request to the IPFS node via an RPC call to the IPFSConnector component
- the IPFSConnector component is what finally requests the ipfs daemon to pin the Cid

#### Issues that we faced

The issues are separated into those which were due to how we initially implemented the MapPinTracker and then those that were/are inherent in any implementation of the pintracker that uses a map internally to store the status of the pins.

Issues with the implementation:

- the local state would get stale and required repeated syncing
- race conditions
- inability to cancel ongoing operations
  - resulted in unnecessary requests to 'undo' requests that couldn't be cancelled
- no way of knowing how many requests were currently in flight/queued for a single Cid

Issues with a MapPinTracker:

- the local state (the map inside the pintracker) is potentially too large to keep for large clusters
- unnecessary duplication of PinInfo in the pintracker component

#### How we fixed it

To tackle the issues with current implementation of the MapPinTracker, we did the following things. 

We moved to a model where we track in-flight operations, so instead of a map that stored the status of a Cid, i.e. `map[Cid]PinInfo`, we now store an operation for a Cid, i.e. `map[Cid]Operation`. 

Now, an Operation contains not only the type of operation that is being performed for a Cid, (Pin or Unpin), and the phase of the operation, (Queued, In Progress, Done, or Error), but a [`context.Context`](https://golang.org/pkg/context).

With the addition of context propagation through RPC calls to the IPFSConnector component, having a context available in every Operation gives us the ability to cancel an operation at any point.

Also upon receiving opposing operations for the same Cid we can cancel the in-flight operation automatically, maybe even before that operation had started to be processed depending on the timing. 

With the increased visibility into the queue of operations that have been requested and the ability to cancel operations, the potential of the local state getting out of sync has greatly decreased. This means that `cluster.StateSync` doesn't need to be called every 60 seconds anymore to guarantee consistency. Also, `Recover` is now async as the queue of operations is no longer a blackbox.

####  Where to go next

Currently in [PR](https://github.com/ipfs/ipfs-cluster/pull/460), there is a stateless implementation of the pintracker interface. This implementation removes the duplication of state and potential for stale PinInfos in the pintracker itself. The stateless pintracker relies directly on the shared state provided by the consensus component and the state provided by the ipfs node.
The main benefit is for clusters with a very large number of pins, as the status of all those pins will not be held in memory. 
