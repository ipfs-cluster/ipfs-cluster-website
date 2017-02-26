+++
title = "Multiaddr"
multiformat = "multiaddr"
+++

⚠️️ _(Note: this page is a work in progress; [please improve it here](https://github.com/multiformats/website/blob/master/content/multiaddr.md))_ ⚠️️

> ## Self-describing network addresses

Multiaddr is a format for encoding addresses from various well-established network protocols. It is useful to write applications that future-proof their use of addresses, and allow multiple transport protocols and addresses to coexist.

## Network Protocol Ossification

The current network addressing scheme in the internet IS NOT self-describing. Addresses of the following forms leave much to interpretation and side-band context. The assumptions they make cause applications to also make those assumptions, which causes lots of "this type of address"-specific code. The network addresses and their protocols rust into place, and cannot be displaced by future protocols because the addressing prevents change.

For example, consider:

```
127.0.0.1:9090   # ip4. is this TCP? or UDP? or something else?
[::1]:3217       # ip6. is this TCP? or UDP? or something else?

http://127.0.0.1/baz.jpg
http://foo.com/bar/baz.jpg
//foo.com:1234
 # use DNS, to resolve to either ip4 or ip6, but definitely use
 # tcp after. or maybe quic... >.<
 # these default to TCP port :80.
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

A multiaddr value is a _recursive_ `(TLV)+` (type-length-value repeating) encoding. It has two forms:

- a _human-readable version_ to be used when printing to the user (UTF-8)
- a _binary-packed version_ to be used in storage, transmissions on the wire, and as a primitive in other formats.

### The human-readable version:

- path notation nests protocols and addresses, for example: `/ip4/127.0.0.1/udp/4023/quic` (this is the repeating part).
  - a protocol MAY be only a code, or also have an address value (nested under a `/`) (eg. `/quic` and `/ip4/127.0.0.1`)
- the _type_ <code class="c-0">\<addr-protocol-str-code></code> is a string code identifying the network protocol. The table of protocols is configurable. The default table is the [multicodec](./multicodec) table.
- the _value_ <code class="c-1">\<addr-value></code> is the network address value, in natural string form.

Human-readable encoding (psuedo regex)

{{% multiformat
  syntax="(/<addr-protocol-str-code> /<addr-value>) +"
  labels="protocol code as a string|the address itself (human readable)|the pattern repeats, protocols encapsulate other protocols"
  example="/ip4/127.0.0.1/tcp/4000"
  %}}


### The binary-packed version:

- the _type_ <code class="c-0">\<addr-protocol-code></code> is a variable integer identifying the network protocol. The table of protocols is configurable. The default table is the [multicodec](./multicodec) table.
- the _length_ is an [unsigned variable integer](https://github.com/multiformats/unsigned-varint) counting the length of the address value, in bytes.
  - **The _length_ is omitted by protocols who have an exact address value size, or no address value.**
- the _value_ <code class="c-1">\<addr-value></code> is the network address value, of length `L`.
  - **The _value_ is omitted by protocols who have no address value.**

Binary-packed encoding (psuedo regex)

{{% multiformat
  syntax="(<addr-protocol-code> <addr-value>) +"
  labels="protocol code as a varint|the address value itself (binary)|the pattern repeats, protocols encapsulate other protocols"
  example="047f000001060fa0"
  %}}

For Example

(TODO)

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

## F.A.Q.

TODO

## About

### Specification

We will be submitting an RFC to the IETF. It will be worked on [at the multiaddr repo](https://github.com/multiformats/multiaddr).

### Credits

The Multiaddr format was invented by [@jbenet](https://github.com/jbenet), and refined by the [IPFS Team](https://github.com/ipfs). It is now maintained by the Multiformats community. The Multihash implementations are written by a variety of authors, whose hard work has made future-proofing and upgrading hash functions much easier. Thank you!

### Open Source

The Multihash format (this documentation and the specification) is Open Source software, licensed under the MIT License and patent-free. The multihash implementations listed here are also Open Source software. Please contribute to make them great! Your bug reports, new features, and documentation improvements will benefit everyone.

### Part of the Multiformats Project

Multihash is part of [the Multiformats Project](../), a collection of protocols which aim to future-proof systems, today. [Check out the other multiformats](../#multiformat-protocols). It is also maintained and sponsored by [Protocol Labs](http://ipn.io).

<div class="about-logos">
<a href="../" class="no-decoration">
  <img alt="Multiformats Logo" id="logo" src="../logo.svg" width="60" style="vertical-align: middle;" />Multiformats
</a>
<a href="http://ipn.io" class="no-decoration">
  <img src="../protocol-labs-logo.png" height="64px" />
</a>
</div>
