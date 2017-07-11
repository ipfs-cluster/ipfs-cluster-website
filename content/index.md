+++
title = "Multiformats"
stars = "multiformats/multiformats"
+++

> ## Self-describing values for Future-proofing

Every choice in computing has a tradeoff. This includes formats, algorithms, encodings, and so on. And even with a great deal of planning, decisions may lead to breaking changes down the road, or to solutions which are no longer optimal. Allowing systems to evolve and grow is important.

- [What are Multiformats?](#what-are-multiformats)
- [Multiformat protocols](#multiformat-protocols)
- [Projects using Multiformats](#projects-using-multiformats)
- [Contribute & Community](#contribute-community)

## What are Multiformats?

The Multiformats Project is a collection of protocols which aim to future-proof systems, today. They do this mainly by enhancing format values with self-description. This allows interoperability, protocol agility, and helps us avoid lock in.

The self-describing aspects of the protocols have a few stipulations:

- They MUST be _in-band_ (with the value); not _out-of-band_ (in context).
- They MUST avoid _lock-in_ and promote _extensibility_.
- They MUST be compact and have a _binary-packed_ representation.
- They MUST have a _human-readable_ representation.


## Multiformat protocols

Currently, we have the following multiformat protocols:

- [multihash](./multihash) - self-describing <span class="mfc mfc-multihash">hashes</span>
- [multiaddr](./multiaddr) - self-describing <span class="mfc mfc-multiaddr">network addresses</span>
- [multibase](https://github.com/multiformats/multibase) - self-describing <span class="mfc mfc-multibase">base encodings</span>
- [multicodec](https://github.com/multiformats/multicodec) - self-describing <span class="mfc mfc-multicodec">serialization</span>
- [multistream](https://github.com/multiformats/multistream) - self-describing <span class="mfc mfc-multistream">stream network protocols</span>
- [multigram](https://github.com/multiformats/multigram) <small>(WIP)</small> - self-describing <span class="mfc mfc-multigram">packet network protocols</span>

<!--
- [multikey](https://github.com/ipfs/specs/issues/58) <small>(WIP)</small> - self-describing <span class="mfc mfc-multikey">keys and proofs</span>
 -->

Each of the projects has its list of implementations in various languages.

### Project Status

Several of the multiformats have stable specs and stable implementations. We're are working on the others. We prioritize their usage as soon as possible, as what they offer -- protocol interoperability and future-proofing -- has real-world consequences today.

Towards that end, we are encouraging improvements to WIP protocols, and implementations of all. Please contribute to the projects on Github.


### A note on the word Multiformats

Multiformats is the name for the organization, but it can also be used to refer to protocols; for instance, in the sentence "Use one of the multiformats". Formats is interchangeable with protocols, here. We try to capitalize Multiformats when it refers to the organization, on GitHub.

## Projects using Multiformats

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

## Contribute & Community

<a href="/">The Multiformats Project</a> is an Open Source software project. It is built by a large community of contributors. Please join us on Github or IRC to request features, file bugs, contribute code, improve documentation, and ask questions. We have a very open and welcoming community.

- [Github Project](https://github.com/multiformats/multiformats)
- [Website Repository](https://github.com/multiformats/website)
- IRC Channel: `#ipfs` on irc.freenode.org
- [Code of Conduct](https://github.com/ipfs/community/blob/master/code-of-conduct.md)
- [Contributing Guide](https://github.com/multiformats/multiformats/blob/master/contributing.md)
