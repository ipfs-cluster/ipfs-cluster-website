+++
title = "/ Multihash"
+++

# multihash

{{% multiformat
  syntax="<fn-code> <length> <hash-digest>"
  labels="code of the hash function being used|varint digest size in bytes|hash function output"
  example="QmYtUc4iTCbbfVSDNKvtQqrfyezPPnFvE33wFmutw9PBBk"
  description=""
%}}


{{% multihash
  fnName="sha2-256"
  fnCode="18"
  length="11"
  lengthCode="0b"
  digest="68656c6c6f20776f726c64"
  fullHash="180b68656c6c6f20776f726c64"
%}}

{{% multihash
  fnName="sha2-256"
  fnCode="18"
  length="11"
  lengthCode="0b"
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
