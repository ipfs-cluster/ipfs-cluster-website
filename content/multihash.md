+++
title = "/ Multihash"
+++

> ## Self-describing hashes

Multihash is a protocol for differentiating outputs from various well-established cryptographic hash functions, addressing size + encoding considerations. A multihash value is a `TLV` (type-length-value) encoding.

- the _type_ `T` is a variable integer identifying the hash function. The table of functions is configurable. The default table is the [multicodec](./multicodec) table.
- the _length_ `L` is a variable integer counting the length of the digest, in bytes
- the _value_ `V` is the hash function digest, of length L.

It is useful to write applications that future-proof their use of hashes, and allow multiple hash functions to coexist.

## Multihash Format


{{% multiformat
  syntax="<hash-func-type> <digest-length> <digest-value>"
  labels="multicodec code of the hash function being used|varint digest size in bytes|hash function output value"
  description="foo"
%}}

For example:

{{% multihash
  fnName="sha2-256"
  fnCode="12"
  length="32"
  lengthCode="20"
  digest="41dd7b6443542e75701aa98a0c235951a28a0d851b11564d20022ab11d2589a8"
  multihash="122041dd7b6443542e75701aa98a0c235951a28a0d851b11564d20022ab11d2589a8"
%}}

## Implementations

These implementations are available:

- [go-multihash](//github.com/multiformats/go-multihash)
- [java-multihash](//github.com/multiformats/java-multihash)
- [js-multihash](//github.com/multiformats/js-multihash)
- [clj-multihash](//github.com/multiformats/clj-multihash)
- rust-multihash
  - [by @dignifiedquire](//github.com/dignifiedquire/rust-multihash)
  - [by @google](//github.com/google/rust-multihash)
- [haskell-multihash](//github.com/LukeHoersten/multihash)
- [python-multihash](//github.com/tehmaze/python-multihash)
- [elixir-multihash](//github.com/zabirauf/ex_multihash), [elixir-multihashing](//github.com/candeira/ex_multihashing)
- [swift-multihash](//github.com/NeoTeo/SwiftMultihash)
- [ruby-multihash](//github.com/neocities/ruby-multihash)
- [MultiHash.Net](//github.com/MCGPPeters/MultiHash.Net)
- [cs-multihash](//github.com/multiformats/cs-multihash)
- [scala-multihash](//github.com/mediachain/scala-multihash)
- [php-multihash](//github.com/Fil/php-multihash)
- [net-ipfs-core](//github.com/richardschneider/net-ipfs-core)
- [(add yours here)](https://github.com/multiformats/website/blob/master/content/multihash.md)

## Examples

The following multihash examples are different hash function outputs of the same exact input:

```
Merkle–Damgård
```

The multihash examples are chosen to show different hash functions and different hash digest lengths at play.

### sha1

{{% multihash
  fnName="sha1"
  fnCode="11"
  length="20"
  lengthCode="14"
  digest="8a173fd3e32c0fa78b90fe42d305f202244e2739"
  multihash="11148a173fd3e32c0fa78b90fe42d305f202244e2739"
%}}

### sha2-256

{{% multihash
  fnName="sha2-256"
  fnCode="12"
  length="32"
  lengthCode="20"
  digest="41dd7b6443542e75701aa98a0c235951a28a0d851b11564d20022ab11d2589a8"
  multihash="122041dd7b6443542e75701aa98a0c235951a28a0d851b11564d20022ab11d2589a8"
%}}

### sha2-512

{{% multihash
  fnName="sha2-512"
  fnCode="13"
  length="64"
  lengthCode="40"
  digest="52eb4dd19f1ec522859e12d89706156570f8fbab1824870bc6f8c7d235eef5f4c2cbbafd365f96fb12b1d98a0334870c2ce90355da25e6a1108a6e17c4aaebb0"
  multihash="134052eb4dd19f1ec522859e12d89706156570f8fbab1824870bc6f8c7d235eef5f4c2cbbafd365f96fb12b1d98a0334870c2ce90355da25e6a1108a6e17c4aaebb0"
%}}

### blake2b-512

{{% multihash
  fnName="blake2b-512"
  fnCode="b240"
  length="64"
  lengthCode="40"
  digest="d91ae0cb0e48022053ab0f8f0dc78d28593d0f1c13ae39c9b169c136a779f21a0496337b6f776a73c1742805c1cc15e792ddb3c92ee1fe300389456ef3dc97e2"
  multihash="c0e40240d91ae0cb0e48022053ab0f8f0dc78d28593d0f1c13ae39c9b169c136a779f21a0496337b6f776a73c1742805c1cc15e792ddb3c92ee1fe300389456ef3dc97e2"
%}}

### blake2b-256

{{% multihash
  fnName="blake2b-256"
  fnCode="b220"
  length="32"
  lengthCode="20"
  digest="7d0a1371550f3306532ff44520b649f8be05b72674e46fc24468ff74323ab030"
  multihash="a0e402207d0a1371550f3306532ff44520b649f8be05b72674e46fc24468ff74323ab030"
%}}

