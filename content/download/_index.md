+++
title = "Download"
weight = 10
aliases = [
    "/documentation/download/"
]
+++

# Download

We offer `ipfs-cluster-service`, `ipfs-cluster-ctl` and `ipfs-cluster-follow` through several options. For information on how to setup and run IPFS Cluster:

* [Read the documentation](/documentation)
* Check the command help (`--help`) ([ipfs-cluster-ctl](/documentation/reference/ctl), [ipfs-cluster-service](/documentation/reference/service)), [ipfs-cluster-follow](/documentation/reference/follow)
* [Get support](/support)

## Binary distribution

IPFS Cluster provides pre-built binaries for several platforms on the [IPFS Distributions page](https://dist.ipfs.io):

* [ipfs-cluster-service](https://dist.ipfs.io/#ipfs-cluster-service)
* [ipfs-cluster-ctl](https://dist.ipfs.io/#ipfs-cluster-ctl)
* [ipfs-cluster-follow](https://dist.ipfs.io/#ipfs-cluster-follow)

You can download these binaries, make them executable and run them directly. They include all the necessary dependencies.

The prebuilt-binaries are only updated on new releases (with occasional release candidates). These releases aim to provide a stable distribution of IPFS Cluster.


## Docker

We have automatic docker builds (https://hub.docker.com/r/ipfs-cluster/ipfs-cluster/) to create a minimal container that runs `ipfs-cluster-service` by default. You can get it with:

```
docker pull ipfs-cluster/ipfs-cluster:\<tag\>
```

where `<tag>` is either `latest` or a tagged version of cluster (i.e. `v0.11.0`). The latest build is built from `master`.

<div class="tipbox tip">See the <a href="/documentation/deployment/automations#docker">Docker documentation section</a> for more details.</div>


## Installing from source

The following requirements apply to the installation from source:

* Go 1.12+
* Git

In order to build and install IPFS Cluster follow these steps:

```sh
git clone https://github.com/ipfs-cluster/ipfs-cluster.git
cd ipfs-cluster
export GO111MODULE=on # optional, if checking out the repository in $GOPATH.
go install ./cmd/ipfs-cluster-service
go install ./cmd/ipfs-cluster-ctl
go install ./cmd/ipfs-cluster-follow
```

After the dependencies have been downloaded, `ipfs-cluster-service`, `ipfs-cluster-ctl` and `ipfs-cluster-follow` will be installed to your `$GOPATH/bin`.

If you would rather have them built locally, use `go build ./cmd/<binary_name>` instead.


## Building the docker image

Run...

```
docker build . -t ipfs-cluster
```

...in the repository root.
