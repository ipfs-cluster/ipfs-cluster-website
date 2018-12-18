+++
title = "Download"
weight = 30
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
* IPFS or internet connectivity (to download depedencies).

### Unix

In order to build and install IPFS Cluster in Unix systems follow the steps:

```
git clone https://github.com/ipfs/ipfs-cluster.git $GOPATH/src/github.com/ipfs/ipfs-cluster
cd $GOPATH/src/github.com/ipfs/ipfs-cluster
make install
```

After the dependencies have been downloaded, `ipfs-cluster-service` and `ipfs-cluster-ctl` will be installed to your `$GOPATH/bin` (it uses `go install`).

If you would rather have them built locally, use `make build` instead. You can run `make clean` to remove any generated artifacts and rewrite the import paths to their original form.

Note that when the ipfs daemon is running locally on its default ports, the build process will use it to fetch `gx`, `gx-go` and all the needed dependencies directly from IPFS.

### Windows and manual installation

In order to build in Windows, you will have to download and install `gx` and `gx-go` first and then build manually:

```
git clone https://github.com/ipfs/ipfs-cluster.git $GOPATH/github.com/ipfs/ipfs-cluster
cd $GOPATH/github.com/ipfs/ipfs-cluster
go get -u github.com/whyrusleeping/gx
go get -u github.com/whyrusleeping/gx-go
gx install --global
gx-go rw
cd ipfs-cluster-service
go install
cd ../ipfs-cluster-ctl
go install
```

`ipfs-cluster-service` and `ipfs-cluster-ctl` should not be available in `$GOPATH/bin`.


### Building the docker image

This is as easily as running:

```
docker build . -t ipfs-cluster
```

in the repository root.

## Changelog

The project Changelog is available [here](https://github.com/ipfs/ipfs-cluster/blob/master/CHANGELOG.md).

## Next steps: [Configuration](/documentation/configuration)
