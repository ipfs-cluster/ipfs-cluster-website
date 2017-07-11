# The Multiformats website

[![](https://img.shields.io/badge/made%20by-Protocol%20Labs-blue.svg?style=flat-square)](http://ipn.io)
[![](https://img.shields.io/badge/project-multiformats-blue.svg?style=flat-square)](https://github.com/multiformats/multiformats)
[![](https://img.shields.io/badge/freenode-%23ipfs-blue.svg?style=flat-square)](https://webchat.freenode.net/?channels=%23ipfs)
[![](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

> Official website for Multiformats http://multiformats.io

This repository contains the source code for the Multiformats website available at http://multiformats.io

This project builds out a static site to explain Multiformats, ready for deployment on ipfs. It uses `hugo` to glue the html together. It provides an informative, public-facing website. The most important things are the words, concepts and links it presents.

## Install

```sh
git clone https://github.com/multiformats/website
```

## Usage

To deploy the site multiformats.io, run:

```sh
# Build out the optimised site to ./public, where you can check it locally.
make

# Add the site to your local ipfs, you can check it via /ipfs/<hash>
make deploy

# Save your dnsimple api token as auth.token
cat "<api token here>" > auth.token

# Update the dns record for multiformats.io to point to the new ipfs hash.
make publish-to-domain
```

The following commands are available:

### `make`

Build the optimised site to the `./public` dir

### `make serve`

Preview the production ready site at http://localhost:1313 _(requires `hugo` on your `PATH`)_

### `make dev`

Start a hot-reloading dev server on http://localhost:1313 _(requires `hugo` on your `PATH`)_

### `make dev-stop`

Stop that server (and take a break!)

### `make deploy`

Build the site in the `public` dir and add to `ipfs` _(requires `hugo` & `ipfs` on your `PATH`)_

### `make publish-to-domain` :rocket:

Update the DNS record for `libp2p.io`.  _(requires an `auto.token` file to be saved in the project root.)_

If you'd like to update the dnslink TXT record for another domain, pass `DOMAIN=<your domain here>` like so:

```sh
make publish-to-domain DOMAIN=tableflip.io
```

---

See the `Makefile` for the full list or run `make help` in the project root. You can pass the env var `DEBUG=true` to increase the verbosity of your chosen command.

## Contribute

Please do! Check out [the issues](https://github.com/ipld/website/issues), or open a PR!

Check out our [contributing document](https://github.com/ipld/ipld/blob/master/contributing.md) for more information on how we work, and about contributing in general. Please be aware that all interactions related to IPLD are subject to the IPFS [Code of Conduct](https://github.com/ipfs/community/blob/master/code-of-conduct.md).

Small note: If editing the README, please conform to the [standard-readme](https://github.com/RichardLitt/standard-readme) specification.

## License

[MIT](LICENSE) © 2016 Protocol Labs Inc.


## Install

```sh
git clone https://github.com/multiformats/website
```

## Usage

#### Build

```sh
> hugo
```

#### Serve

```sh
> hugo serve
```

#### Deploy

```sh
> hugo
> ipfs add -r public
> open https://ipfs.io/ipfs/<last hash from above>
```

## Dependencies

* `hugo` to build website
* `Node.js` and `npm` for build tools
* `ipfs` to deploy changes
* `dnslink-deploy` to deploy changes

## Maintainers

[@victorbjelkholm](https://github.com/victorbjelkholm)

## Contribute

Please do! Check out the [issues](https://github.com/multiformats/website/issues), or open a PR!

Check out our [contributing document](https://github.com/multiformats/multiformats/blob/master/contributing.md) for more information on how we work, and about contributing in general. Please be aware that all interactions related to multiformats are subject to the IPFS [Code of Conduct](https://github.com/ipfs/community/blob/master/code-of-conduct.md).

Small note: If editing the README, please conform to the [standard-readme](https://github.com/RichardLitt/standard-readme) specification.

## License

[MIT](LICENSE) © 2016 Protocol Labs Inc.
