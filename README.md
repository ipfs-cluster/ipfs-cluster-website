# multiformats website

> The multiformats website

Current iteration: https://ipfs.io/ipfs/QmcG6FJrhDPeK8GKMrDFNrczGoAe37kYZkBb5qaNbFnmYD/_site/

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

## Contribute

Please do! Check out the [issues](https://github.com/multiformats/website), or open a PR!

Note that this README follows the [Standard-Readme](https://github.com/RichardLitt/standard-readme) protocol.

## License

[MIT](LICENSE) © Protocol Labs
