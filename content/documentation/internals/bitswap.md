+++
title = "Bitswap"
weight = 4
+++ 

## The DHT service

The Cluster component attaches a `go-libp2p-kad-dht` service to the libp2p Host. It then uses it to create a [routed host](https://godoc.org/github.com/libp2p/go-libp2p/p2p/host/routed), which uses the DHT as [PeerRouting](https://godoc.org/github.com/libp2p/go-libp2p-routing#PeerRouting)) provider. This allows to retrieve the multiaddreses for a peer.ID from other peers when they are not known locally (not part of the peerstore).

The DHT currently used is a Kademlia implementation. Peers IDs from other peers can be sorted and classified by distance to the current peer, which prioritizes remembering those which are closer to itself than those which are far away. When no addresses are known for a peer ID, we contact the closest known peer and ask for it. The process repeats itself until we come to a peer which is close enough to have remembered the details of the peer.ID that we are looking for. We make sure to run a regular `dht bootstrap` process which performs a request with an empty peer.ID, thus traversing the DHT, discovering and getting connected to other peers in it.

We currently do not use the DHT to store any information, just for peer discovery (routing).

The DHT only works if the peer can connect to a `boostrapper` peer from the beginning, so that it has an starting point to access and discover the rest of the network. This requirement translates into two things in Cluster:

* First we ask users to have at least one peer multiaddress in the `peerstore` file when they first start their peers (and don't use `--bootstrap`)
* Second, we persist all known multiaddresses on shutdown to the `peerstore` file.

One of the benefits of using a DHT is that we don't need to have every peer connect and know everyone else's addresses as soon as they start/join a cluster. Instead, whenever they need to `Connect`, they will use the DHT to find the other peers as needed.