+++
title = "Multihash"
multiformat = "multihash"
stars = "multiformats/multihash"
+++

> ## Self-describing hashes

Multihash is a protocol for differentiating outputs from various well-established hash functions, addressing size + encoding considerations. It is useful to write applications that future-proof their use of hashes, and allow multiple hash functions to coexist.

<!-- manual toc unfortunately. dont want all qs printed here -->

- [Safer, easier cryptographic hash function upgrades](#safer-easier-cryptographic-hash-function-upgrades)
- [The Multihash Format](#the-multihash-format)
- [Implementations](#implementations)
- [Examples](#examples)
- [F.A.Q.](#f-a-q)
- [About](#about)
  - [Specification](#specification)
  - [Credits](#credits)
  - [Open Source](#open-source)
  - [Part of the Multiformats Project](#part-of-the-multiformats-project)

### Safer, easier cryptographic hash function upgrades

Multihash is particularly important in systems which depend on [**cryptographically secure hash functions**](https://en.wikipedia.org/wiki/Cryptographic_hash_function). Attacks [may break](https://en.wikipedia.org/wiki/Hash_function_security_summary) the cryptographic properties of secure hash functions. These [_cryptographic breaks_](https://en.wikipedia.org/wiki/Cryptanalysis) are particularly painful in large tool ecosystems, where tools may have made assumptions about hash values, such as function and digest size. Upgrading becomes a nightmare, as all tools which make those assumptions would have to be upgraded to use the new hash function and new hash digest length. Tools may face serious interoperability problems or error-prone special casing.

> How many programs out there assume a git hash is a sha1 hash?
>
> How many scripts assume the hash value digest is **_exactly_** 160 bits?
>
> How many tools will break when these values change?
>
> How many programs will fail silently when these values change?

**This is precisely where Multihash shines. It was designed for upgrading.**

When using Multihash, a system warns the consumers of its hash values that these may have to be upgraded in case of a break. Even though the system may still only use a single hash function at a time, the use of multihash makes it clear to applications that hash values may use different hash functions or be longer in the future. Tooling, applications, and scripts can avoid making assumptions about the length, and read it from the multihash value instead. This way, the vast majority of tooling -- which may not do any checking of hashes -- would not have to be upgraded at all. This vastly simplifies the upgrade process, avoiding the waste of hundreds or thousands of software engineering hours, deep frustrations, and high blood pressure.

## The Multihash Format

A multihash follows the `TLV` (type-length-value) pattern.

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

## F.A.Q.

> #### Q: Why have digest length as a separate number?

Because combining hash function code and hash digest length ends up with a function code really meaning "function-and-digest-size-code". Makes using custom digest sizes annoying, and much less flexible. We would need hundreds of codes for all the combinations people would want to use.

> #### Q: Why varints (variable integers)?

So that we have no limitation on functions or lengths.

> #### Q: What kind of varints?

A Most Significant Bit unsigned varint, as defined by the [multiformats/unsigned-varint](https://github.com/multiformats/unsigned-varint) doc.

> #### Q: Don't we have to agree on a table of functions?

Yes, but we already have to agree on functions, so this is not hard. The table even leaves some room for custom function codes.

> #### Q: Why not use `"sha256:<digest>"`?

For three reasons:

- (1) Multihash and all other multiformats endeavor to make the values be "in-band" and to be treated as the original value. The construction `<string-prefix>:<hex-digest>` is human readable and tuned for some outputs. Hashes are stored compactly in their binary representation. Forcing applications to always convert is cumbersome (split on `:`, turn the right hand side into binary, remove the `:`, concat).

- (2) Multihash and all other multiformats endeavor to be as compact as possible, which means a binary packed representation will help save a lot of space in systems that use millions or billions of hashes. For example, a 100 TB file in IPFS may have as many as 400 million subobjects, which would mean 400 million hashes.
    ```
    400,000,000 hashes * (7 - 2) bytes = 2 GB
    ```

- (3) The length is extremely useful when hashes are truncated. This is a type of choice that should be expressed in-band. It is also useful when hashes are concatenated or kept in lists, and when scanning a stream quickly.

> #### Q: Is Multihash only for cryptographic hashes?
> #### What about non-cryptographic hashes like `murmur3`, `cityhash`, etc?

We decided to make Multihash work for all hash functions, not just cryptographic hash functions. The same kind of choices that people make around

We wanted to be able to include `MD5` and `SHA1`, as they are widely used even now, despite no longer being secure. Ultimately, we could consider these cryptographic hash functions that have transitioned into non-cryptographic hash functions. Perhaps all of them eventually do.

> #### Q: How do I add hash functions to the table?

Three options to add custom hash functions:

- (1) If other applications would benefit from this hash function, propose it at [the multihash repo](https://github.com/multiformats/multihash/issues/)
- (2) If your function is only for your application, you can add a hash function to the table in a range reserved specially for this purpose. See the table.
- (3) If you need to use a completely custom table, most implementations support loading a separate hash function table.

> #### Q. I want to upgrade a large system to use Multihash. Could you help me figure out how?

Sure, ask for help in IRC, github, or other fora. See the [Multiformats Community](../#contribute-community) listing.

> #### Q. I wish Multihash would _______. I really hate _______.

Those are not questions. But please leave any and all feedback over in [the Multihash repo](https://github.com/multiformats/multihash/issues/). It will help us improve the project and make sure it addresses our users' needs. Thanks!

## About

### Specification

There is a spec in progress, which we hope to submit to the IETF. It is being worked on [at this pull-request](https://github.com/multiformats/multihash/pull/41).

### Credits

The Multihash format was invented by [@jbenet](https://github.com/jbenet), and refined by the [IPFS Team](https://github.com/ipfs). It is now maintained by the Multiformats community. The Multihash implementations are written by a variety of authors, whose hard work has made future-proofing and upgrading hash functions much easier. Thank you!

### Open Source

The Multihash format (this documentation and the specification) is Open Source software, licensed under the MIT License and patent-free. The multihash implementations listed here are also Open Source software. Please contribute to make them great! Your bug reports, new features, and documentation improvements will benefit everyone.

### Part of the Multiformats Project

Multihash is part of [the Multiformats Project](../), a collection of protocols which aim to future-proof systems, today. [Check out the other multiformats](../#multiformat-protocols). It is also maintained and sponsored by [Protocol Labs](http://ipn.io).

<div class="about-logos">
  <div>
    <a href="../" class="no-decoration">
      <img alt="Multiformats Logo" id="logo" src="../logo.svg" width="60" style="vertical-align: middle;" />Multiformats
    </a>
  </div>
  <div>
    <a href="http://ipn.io" class="no-decoration">
      <img src="../protocol-labs-logo.png" height="64px" />
    </a>
  </div>
</div>
