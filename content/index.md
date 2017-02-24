+++
title = "Multiformats"
+++

> ## Self-describing values for Future-proofing

Every choice in computing has a tradeoff. This includes formats, algorithms, encodings, and so on. And even with a great deal of planning, decisions may lead to breaking changes down the road, or to solutions which are no longer optimal. Allowing systems to evolve and grow is important.

Multiformats is a collection of protocols which aim to future-proof systems, today. They do this mainly by enhancing format values with self-description. This allows interoperability, protocol agility, and helps us avoid lock in.

## Multiformat protocols

Currently, we have the following multiformat protocols:

- [multihash](./multihash) - self-describing <span class="mfc mfc-multihash">hashes</span>
- [multiaddr](./multiaddr) - self-describing <span class="mfc mfc-multiaddr">network addresses</span>
- [multibase](./multibase) - self-describing <span class="mfc mfc-multibase">base and text encodings</span>
- [multicodec](./multicodec) - self-describing <span class="mfc mfc-multicodec">values and serialization</span>
- [multistream](./multistream) - self-describing <span class="mfc mfc-multistream">stream network protocols</span>
- [multigram](./multigram) <small>(WIP)</small> - self-describing <span class="mfc mfc-multigram">packet network protocols</span>
- [multikey](./multikey) <small>(WIP)</small> - self-describing <span class="mfc mfc-multikey">keys and proofs</span>

Several of the multiformats have stable specs and stable implementations. We're are working on the others. We prioritize their usage as soon as possible, as what they offer -- protocol interoperability and future-proofing -- has real-world consequences today.

Towards that end, we are encouraging improvements to WIP protocols, and implementations of all. Please contribute to the projects on Github.

The self-describing aspects of the protocols have a few stipulations:

- They MUST be _in-band_ (with the value); not _out-of-band_ (in context).
- They MUST avoid _lock-in_ and promote _extensibility_.
- They MUST be compact and have a _binary-packed_ representation.
- They MUST have a _human-readable_ representation.


### A note on the word Multiformats

Multiformats is the name for the organization, but it can also be used to refer to protocols; for instance, in the sentence "Use one of the multiformats". Formats is interchangeable with protocols, here. We try to capitalize Multiformats when it refers to the organization, on GitHub.

### Projects using Multiformats

The Multiformats project began through [the IPFS Project](https://ipfs.io). It is used extensively in projects like

<ul class="project-list">
	<li>
		<a href="https://ipfs.io"><img src="projects/ipfs.png" />IPFS</a>
		- a peer-to-peer hypermedia protocol and distributed file system.
	</li>
	<li>
		<a href="https://github.com/libp2p/libp2p">
		<img src="projects/libp2p.png" />libp2p</a>
		- a modular network library for peer-to-peer protocols.
	</li>
	<li>
		<small><a href="https://github.com/multiformats/website/blob/master/content/index.md">(add yours here)</a></small>
	</li>
</ul>

### Community

The Multiformats Project is an Open Source software project. It is built by a large community of contributors.

- [Github Project](https://github.com/multiformats/multiformats)
- [Website Repository](https://github.com/multiformats/website)
- IRC Channel: `#ipfs` on irc.freenode.org

Multiformats was started and is sponsored by [Protocol Labs](https://ipn.io).

<a href="http://ipn.io">
<img src="protocol-labs-logo.png" height="64px" />
</a>
