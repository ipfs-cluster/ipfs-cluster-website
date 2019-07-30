+++
title = "Download and Install"
weight = 10
aliases = [
    "/download/",
    "/documentation/download/"
]
+++

# Download

In order to run an IPFS Cluster peer and perform actions on the Cluster, you will need to obtain the `ipfs-cluster-service` and `ipfs-cluster-ctl` binaries and run them from your console. This can be downloaded or compiled as explained below. You should run the latest stable version, and run all peers in your Cluster with the same version.

Sometimes, some things like configuration options or APIs change between versions. For more information, you can check the [official
changelog](https://github.com/ipfs/ipfs-cluster/blob/master/CHANGELOG.md).

## Binary distribution

IPFS Cluster provides pre-built binaries for several platforms on the [IPFS Distributions page](https://dist.ipfs.io):

* [ipfs-cluster-service](https://dist.ipfs.io/#ipfs-cluster-service)
* [ipfs-cluster-ctl](https://dist.ipfs.io/#ipfs-cluster-ctl)

You can download these binaries, make them executable and run them directly. They include all the necessary dependencies.

The prebuilt-binaries are only updated on new releases (with occasional release candidates). These releases aim to provide a stable distribution of IPFS Cluster.


## Docker

We have automatic docker builds (https://hub.docker.com/r/ipfs/ipfs-cluster/) to create a minimal container that runs `ipfs-cluster-service` by default. You can get it with:

```
docker pull ipfs/ipfs-cluster:\<tag\>
```

where `<tag>` is either `latest` or a tagged version of cluster (i.e. `v0.11.0`). The latest build is built from `master`.

<div class="tipbox tip">See the <a href="/documentation/guides/deployment#docker">Docker documentation section</a> for more details.</div>


## Installing from source

The following requirements apply to the installation from source:

* Go 1.12+
* Git

In order to build and install IPFS Cluster follow these steps:

```
git clone https://github.com/ipfs/ipfs-cluster.git
export GO111MODULE=on # optional, if checking out the repository in $GOPATH.
go install ./cmd/ipfs-cluster-service
go install ./cmd/ipfs-cluster-ctl
```

After the dependencies have been downloaded, `ipfs-cluster-service` and `ipfs-cluster-ctl` will be installed to your `$GOPATH/bin`.

If you would rather have them built locally, use `go build ./cmd/<binary_name>` instead.


## Building the docker image

Run...

```
docker build . -t ipfs-cluster
```

...in the repository root.
