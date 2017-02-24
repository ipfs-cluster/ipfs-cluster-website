+++
title = "/ Multiaddr"
+++

> ## Self-describing network addresses

Multiaddr is a format for encoding addresses from various well-established network protocols. A multiaddr value is a _recursive_ `(TL?V)+` (type-length-value repeating) encoding.

In the human-readable version:
- a path notation nests protocols and addresses, for example: `/ip4/127.0.0.1/udp/4023/quic`.
- the _type_ `T` is a string code identifying the network protocol. The table of protocols is configurable. The default table is the [multicodec](./multicodec) table.
- the _value_ `V` is the network address value, in natural string form.

In the binary version:
- the _type_ `T` is a variable integer identifying the network protocol. The table of protocols is configurable. The default table is the [multicodec](./multicodec) table.
- the _length_ `L` is a variable integer counting the length of the address value, in bytes. **Sometimes `L` is omitted by protocols who have an exact address size**.
- the _value_ `V` is the network address value, of length `L`.

It is useful to write applications that future-proof their use of addresses, and allow multiple transport protocols and addresses to coexist.

## Network Protocol Ossification

The current network addressing scheme in the internet IS NOT self-describing. Addresses of the following forms leave much to interpretation and side-band context. The assumptions they make cause applications to also make those assumptions, which causes lots of "this type of address"-specific code. The network addresses and their protocols rust into place, and cannot be displaced by future protocols because the addressing prevents change.

```
127.0.0.1:9090   # ip4. is this TCP? or UDP? or something else?
[::1]:3217       # ip6. is this TCP? or UDP? or something else?
http://127.0.0.1/baz.jpg
http://foo.com/bar/baz.jpg
//foo.com
     # default to port :80. tcp, of course. (or quic if chrome)
     # use DNS, to resolve to either ip4 or ip6, but definitely
     # use tcp after. or maybe quic.
```

Instead, when addresses are fully qualified, we can build applications that will work with network protocols of the future, and do not accidentally ossify the stack.

```
/ip4/127.0.0.1/udp/9090/quic
/ip6/[::1]/tcp/3217
/ip4/127.0.0.1/tcp/90/http/baz.jpg
/dns/foo.com/http/bar/baz.jpg
/dns/foo.com/https
```

## Multiaddr Format

Human-readable encoding

{{% multiformat
  syntax="(/<addr-protocol-str-code> /<addr-value>)+"
  labels="protocol code as a string|the address itself (human readable)"
  example="/ip4/127.0.0.1/tcp/4000"
  %}}

Binary-packed encoding

{{% multiformat
  syntax="(<addr-protocol-code> <addr-value>)+"
  labels="protocol code as a varint|the address value itself (binary)"
  example="047f000001060fa0"
  %}}

For example:

TOTO

## Implementations

These implementations are available:

- [js-multiaddr](https://github.com/multiformats/js-multiaddr) - stable
- [go-multiaddr](https://github.com/multiformats/go-multiaddr) - stable
- [java-multiaddr](https://github.com/multiformats/java-multiaddr) - stable
- [hs-multiaddr](https://github.com/basile-henry/hs-multiaddr) - draft
- [py-multiaddr](https://github.com/sbuss/py-multiaddr) - alpha
- [rust-multiaddr](https://github.com/multiformats/rust-multiaddr) - draft
- [cs-multiaddress](https://github.com/tabrath/cs-multiaddress) - alpha
- [net-ipfs-core](https://github.com/richardschneider/net-ipfs-core) - stable
- [(add yours here)](https://github.com/multiformats/website/blob/master/content/multiaddr.md)

## Examples

TODO
