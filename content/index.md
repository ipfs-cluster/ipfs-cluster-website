+++
title = ""
+++

Currently, we have the following multiformat protocols:

- [multiaddr](https://github.com/multiformats/multiaddr)
- [multicodec](https://github.com/multiformats/multicodec)
- [multihash](https://github.com/multiformats/multihash)
- [multistream](https://github.com/multiformats/multistream)
- [multibase](https://github.com/ipfs/specs/issues/130)
- [multigram](https://github.com/ipfs/specs/pull/123)
- [multikey](https://github.com/ipfs/specs/issues/58)

# multihash

{{% multiformat
	syntax="<fn-code> <length> <hash-digest>"
	labels="code of the hash function being used|varint digest size in bytes|hash function output"
	example="QmYtUc4iTCbbfVSDNKvtQqrfyezPPnFvE33wFmutw9PBBk"
	description=""
%}}

-----

{{% multihash
	input="hello world"
	fnCode="17"
	name="sha1"
	length="11"
	digest="68656c6c6f20776f726c64"
	fullHash="110b68656c6c6f20776f726c64"
%}}

{{% multihash
	fnCode="18"
	name="sha2-256"
	length="11"
	digest="68656c6c6f20776f726c64"
	fullHash="120b68656c6c6f20776f726c64"
%}}

{{% multihash
	fnCode="64"
	name="blake2b"
	length="11"
	digest="68656c6c6f20776f726c64"
	fullHash="400b68656c6c6f20776f726c64"
%}}

{{% multihash
	fnCode="65"
	name="blake2s"
	length="11"
	digest="68656c6c6f20776f726c64"
	fullHash="410b68656c6c6f20776f726c64"
%}}

# multiaddr

{{% multiformat
	syntax="(/<addr-str-code> /<addr-str-rep>)+"
	labels="address code as a string|the address itself"
	example="/ipv4/127.0.0.1/tcp/4000"
	%}}

-----------------
## notes 

what


<fn-code><length><hash-digest>

 ^       ^       ^
 |       |       |
 |       |       +-- hash function output
 |       |            
 |       |
 |       +------- varint digest size in bytes
 |
 +------------ code of the hash function being used


112008e11fc41466fcda0af7dee0905605d9
11 20 08e11fc41466fcda0af7dee0905605d9

fn code
   length
	     hash digest

hello
