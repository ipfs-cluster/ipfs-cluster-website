# website

[![](https://img.shields.io/badge/made%20by-Protocol%20Labs-blue.svg?style=flat-square)](http://ipn.io)
[![](https://img.shields.io/badge/project-multiformats-blue.svg?style=flat-square)](https://github.com/multiformats/multiformats)
[![](https://img.shields.io/badge/freenode-%23ipfs-blue.svg?style=flat-square)](https://webchat.freenode.net/?channels=%23ipfs)
[![](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

> The multiformats website

Current iteration: https://ipfs.io/ipfs/QmVhFMu7ryuFyRXm8gpxWmVuSsLR5H9Z91j8YcTrc9GmUL

## Install

```sh
git clone https://github.com/multiformats/website
```

## Usage

#### Build

```
jekyll build
```

#### Serve

```
jsekyll serve
```

#### Deploy

```sh
jekyll build
ipfs add -r .
# Copy <hash1> for `website` into the appropriate baseurl and path in _config.yml
ipfs add -r .
# Then, take the newest hash for `website`
ipfs pin add <hash2>
# Then go to https://ipfs.io/ipfs/<hash2>/_site/
```

## Maintainers

[@victorbjelkholm](https://github.com/victorbjelkholm)

## Contribute

Please do! Check out the [issues](https://github.com/multiformats/website/issues), or open a PR!

Check out our [contributing document](https://github.com/multiformats/multiformats/blob/master/contributing.md) for more information on how we work, and about contributing in general. Please be aware that all interactions related to multiformats are subject to the IPFS [Code of Conduct](https://github.com/ipfs/community/blob/master/code-of-conduct.md).

Small note: If editing the README, please conform to the [standard-readme](https://github.com/RichardLitt/standard-readme) specification.

## License

[MIT](LICENSE) © 2016 Protocol Labs Inc.
