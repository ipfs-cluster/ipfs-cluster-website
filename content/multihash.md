+++
title = "Multihash"
+++

> ## Self-describing hashes

Multihash is a protocol for differentiating outputs from various well-established hash functions, addressing size + encoding considerations. It is useful to write applications that future-proof their use of hashes, and allow multiple hash functions to coexist.

### Safer, easier cryptographic hash function upgrades

Multihash is particularly important in systems which depend on [**cryptographically secure hash functions**](https://en.wikipedia.org/wiki/Cryptographic_hash_function). Attacks [may break](https://en.wikipedia.org/wiki/Hash_function_security_summary) the cryptographic properties of secure hash functions. These [_cryptographic breaks_](https://en.wikipedia.org/wiki/Cryptanalysis) are particularly painful in large tool ecosystems, where tools may have made assumptions about hash values, such as function and digest size. Upgrading becomes a nightmare, as all tools which make those assumptions would have to be upgraded to use the new hash function and new hash digest length. Tools may face serious interoperability problems or error-prone special casing.

> How many tools out there assume a git hash is a sha1 hash? How many scripts assume the hash value digest is **_exactly_** 160 bits?

**This is precisely where Multihash shines. Upgrading is what it was designed for.**

When using Multihash, a system warns the consumers of its hash values that these may have to be upgradied in case of a break. Even though the system may still only use a single hash function at a time, the use of multihash makes it clear to applications that hash values may use different hash functions or be longer in the future. Tooling, applications, and scripts can avoid making assumptions about the length, and read it from the multihash value instead. This way, the vast majority of tooling -- which may not do any checking of hashes -- would not have to be upgraded at all. This vastly simplifies the upgrade process, avoiding the waste of hundreds or thousands of software engineering hours, deep frustrations, and high blood pressue.

## The Multihash Format

A multihash follows a `TLV` (type-length-value) pattern.

- the _type_ <code class="c-0">\<hash-func-type></code> is an [unsigned variable integer](https://github.com/multiformats/unsigned-varint) identifying the hash function. There is a default table, and it is configurable. The default table is [the multihash table](https://github.com/multiformats/multihash/blob/master/hashtable.csv).
- the _length_ <code class="c-1">\<digest-length></code> is an [unsigned variable integer](https://github.com/multiformats/unsigned-varint) counting the length of the digest, in bytes
- the _value_ <code class="c-2">\<digest-value></code> is the hash function digest, with a length of exactly <code class="c-1">\<digest-length></code> bytes.

{{% multiformat
  syntax="<hash-func-type> <digest-length> <digest-value>"
  labels="unsigned varint code of the hash function being used|unsigned varint digest length, in bytes|hash function output value, with length matching the prefixed length value"
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

<!-- output of running list-multihashes.js -->

### sha1 - 160 bits

{{% multihash
  fnName="sha1"
  fnCode="11"
  length="20"
  lengthCode="14"
  digest="8a173fd3e32c0fa78b90fe42d305f202244e2739"
  multihash="11148a173fd3e32c0fa78b90fe42d305f202244e2739"
%}}

### sha2-256 - 256 bits (aka sha256)

{{% multihash
  fnName="sha2-256"
  fnCode="12"
  length="32"
  lengthCode="20"
  digest="41dd7b6443542e75701aa98a0c235951a28a0d851b11564d20022ab11d2589a8"
  multihash="122041dd7b6443542e75701aa98a0c235951a28a0d851b11564d20022ab11d2589a8"
%}}

### sha2-512 - 256 bits

{{% multihash
  fnName="sha2-512"
  fnCode="13"
  length="32"
  lengthCode="20"
  digest="52eb4dd19f1ec522859e12d89706156570f8fbab1824870bc6f8c7d235eef5f4"
  multihash="132052eb4dd19f1ec522859e12d89706156570f8fbab1824870bc6f8c7d235eef5f4"
%}}

### sha2-512 - 512 bits (aka sha512)

{{% multihash
  fnName="sha2-512"
  fnCode="13"
  length="64"
  lengthCode="40"
  digest="52eb4dd19f1ec522859e12d89706156570f8fbab1824870bc6f8c7d235eef5f4c2cbbafd365f96fb12b1d98a0334870c2ce90355da25e6a1108a6e17c4aaebb0"
  multihash="134052eb4dd19f1ec522859e12d89706156570f8fbab1824870bc6f8c7d235eef5f4c2cbbafd365f96fb12b1d98a0334870c2ce90355da25e6a1108a6e17c4aaebb0"
%}}

### blake2b-512 - 512 bits

{{% multihash
  fnName="blake2b-512"
  fnCode="b240"
  length="64"
  lengthCode="40"
  digest="d91ae0cb0e48022053ab0f8f0dc78d28593d0f1c13ae39c9b169c136a779f21a0496337b6f776a73c1742805c1cc15e792ddb3c92ee1fe300389456ef3dc97e2"
  multihash="c0e40240d91ae0cb0e48022053ab0f8f0dc78d28593d0f1c13ae39c9b169c136a779f21a0496337b6f776a73c1742805c1cc15e792ddb3c92ee1fe300389456ef3dc97e2"
%}}

### blake2b-256 - 256 bits

{{% multihash
  fnName="blake2b-256"
  fnCode="b220"
  length="32"
  lengthCode="20"
  digest="7d0a1371550f3306532ff44520b649f8be05b72674e46fc24468ff74323ab030"
  multihash="a0e402207d0a1371550f3306532ff44520b649f8be05b72674e46fc24468ff74323ab030"
%}}

### blake2s-256 - 256 bits

{{% multihash
  fnName="blake2s-256"
  fnCode="b260"
  length="32"
  lengthCode="20"
  digest="a96953281f3fd944a3206219fad61a40b992611b7580f1fa091935db3f7ca13d"
  multihash="e0e40220a96953281f3fd944a3206219fad61a40b992611b7580f1fa091935db3f7ca13d"
%}}

### blake2s-128 - 128 bits

{{% multihash
  fnName="blake2s-128"
  fnCode="b250"
  length="16"
  lengthCode="10"
  digest="0a4ec6f1629e49262d7093e2f82a3278"
  multihash="d0e402100a4ec6f1629e49262d7093e2f82a3278"
%}}

