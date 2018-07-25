# The ipfs-cluster website

[![](https://img.shields.io/badge/made%20by-Protocol%20Labs-blue.svg?style=flat-square)](http://ipn.io)
[![](https://img.shields.io/badge/project-ipfs-blue.svg?style=flat-square)](https://github.com/ipfs/ipfs)
[![](https://img.shields.io/badge/freenode-%23ipfs-blue.svg?style=flat-square)](https://webchat.freenode.net/?channels=%23ipfs)
[![](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

> Official website for ipfs-cluster http://cluster.ipfs.io

This repository contains the source code for the ipfs-cluster website available at http://cluster.ipfs.io

This project builds out a static site to explain ipfs-cluster, ready for deployment on ipfs. It uses `hugo` to glue the html together. It provides an informative, public-facing website. The most important things are the words, concepts and links it presents.

## Install

```sh
git clone https://github.com/ipfs/ipfs-cluster-website
```

## Usage

Known issue:

This website uses Hugo v0.31.1 or earlier, which is not the latest version. You will need to grab the correct binary from [this Hugo release list](https://github.com/gohugoio/hugo/releases/tag/v0.31.1) and install by copying to your `/usr/local/bin`. If you want to run more than one version of Hugo, you will need to rename each executable accordingly. [More instructions on intalling Hugo from a tarball.](https://gohugo.io/getting-started/installing/#step-2-download-the-tarball)

To deploy the site cluster.ipfs.io, run:

```sh
# Build out the optimised site to ./public, where you can check it locally.
make

# Add the site to your local ipfs, you can check it via /ipfs/<hash>
make deploy

# Save your dnsimple api token as auth.token
cat "<api token here>" > auth.token

# Update the dns record for cluster.ipfs.io to point to the new ipfs hash.
make publish-to-domain
```

The following commands are available:

### `make`

Build the optimised site to the `./public` dir

### `make serve`

Preview the production ready site at http://localhost:1313 _(requires `hugo` on your `PATH`)_

### `make dev`

Start a hot-reloading dev server on http://localhost:1313 _(requires `hugo` on your `PATH`)_

### `make deploy`

Build the site in the `public` dir and add to `ipfs` _(requires `hugo` & `ipfs` on your `PATH`)_

### `make publish-to-domain` :rocket:

Update the DNS record for `cluster.ipfs.io`.  _(requires an `auto.token` file to be saved in the project root.)_

If you'd like to update the dnslink TXT record for another domain, pass `DOMAIN=<your domain here>` like so:

```sh
make publish-to-domain DOMAIN=tableflip.io
```

---

See the `Makefile` for the full list or run `make help` in the project root. You can pass the env var `DEBUG=true` to increase the verbosity of your chosen command.

## Maintainers

The ipfs-cluster team.

## Contribute

Please do! Check out the [issues](https://github.com/ipfs/ipfs-cluster-website/issues), or open a PR!

Check out our [contributing document](https://github.com/ipfs/ipfs-cluster/blob/master/contribute.md) for more information on how we work, and about contributing in general.

Small note: If editing the README, please conform to the [standard-readme](https://github.com/RichardLitt/standard-readme) specification.

## License

[MIT](LICENSE) © 2018 Protocol Labs Inc.
