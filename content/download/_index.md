+++
title = "Download"
weight = 30
aliases = ["/documentation/download/"]
+++


# Download

## Binary distribution

IPFS Cluster provides pre-built binaries for several platforms on the [IPFS Distributions page](https://dist.ipfs.io):

* [ipfs-cluster-service](https://dist.ipfs.io/#ipfs-cluster-service)
* [ipfs-cluster-ctl](https://dist.ipfs.io/#ipfs-cluster-ctl)

You can download these binaries, make them executable and run them directly. They include all the necessary dependencies.

The prebuilt-binaries are only updated on new releases (with occasional release candidates). These releases aim to provide a stable distribution of IPFS Cluster.


## Docker

We have automatic docker builds (https://hub.docker.com/r/ipfs/ipfs-cluster/) to create a minimal container that runs `ipfs-cluster-service` by default. You can obtain it with:

```
docker pull ipfs/ipfs-cluster:\<tag\>
```

where `<tag>` is either `latest` or a tagged version of cluster (i.e. `v0.7.0`). The latest build is built from `master`.

<div class="tipbox tip">Make sure to read the <a href="/documentation/deployment/docker">Docker documentation section</a>.</div>

## Snaps

We submit automated experimental builds to the [snapcraft.io](https://snapcraft.io) store:

```
snap install ipfs-cluster --edge
```

We currently do not provide stable snaps.

## Installing from source

The following requirements apply to the installation from source:

* Go 1.11+
* Git

In order to build and install IPFS Cluster follow the steps:

```
git clone https://github.com/ipfs/ipfs-cluster.git
export GO111MODULE=on # optional, if checking out the repository in $GOPATH.
go install ./cmd/ipfs-cluster-service
go install ./cmd/ipfs-cluster-ctl
```

After the dependencies have been downloaded, `ipfs-cluster-service` and `ipfs-cluster-ctl` will be installed to your `$GOPATH/bin`.

If you would rather have them built locally, use `go build ./cmd/<binary_name>` instead.


### Building the docker image

This is as easily as running:

```
docker build . -t ipfs-cluster
```

in the repository root.

## Changelog

The project Changelog is available [here](https://github.com/ipfs/ipfs-cluster/blob/master/CHANGELOG.md).

## Next steps: [Configuration](/documentation/configuration)
