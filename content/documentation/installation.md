+++
title = "Installation"
+++


# Download and Installation


## Binary distribution

IPFS Cluster provides pre-built binaries for several platforms on the [IPFS Distributions page](https://dist.ipfs.io):

* [ipfs-cluster-service](https://dist.ipfs.io/#ipfs-cluster-service)
* [ipfs-cluster-ctl](https://dist.ipfs.io/#ipfs-cluster-ctl)

You can download these binaries, make them executable and run them directly. They include all the necessary dependencies.

The prebuilt-binaries are only updated on new releases (with occasional release candidates). These releases aim to provide a stable distribution of IPFS Cluster.


## Docker

We have automatic docker builds (https://hub.docker.com/r/ipfs/ipfs-cluster/) to create a minimal container that runs `ipfs-cluster-service` by default. You can obtain it with:

```
docker pull ipfs/ipfs-cluster:<tag>
```

where `<tag>` is either `latest` or a tagged version of cluster (i.e. `v0.3.5`). The latest build is built from `master`.

### ipfs-cluster-service and docker

When running `ipfs-cluster-service` using the docker container, it is recommended to use a external volume and provide the configuration and data folder: `/data/ipfs-cluster` (this is usually done passing `-v <your_local_path>:/data/ipfs-cluster` to `docker run`).

If no `/data/ipfs-cluster/service.json` file can be found, the container's entrypoint script will:

* run `ipfs-cluster-service init`
* make the following changes to the default configuration:
  * `api/restapi/http_listen_multiaddress` will be set to use `0.0.0.0` instead of `127.0.0.1`.
  * `ipfs_connector/ipfshttp/proxy_listen_multiaddress` will be set to use `0.0.0.0` instead of `127.0.0.1`.

Read the [Configuration documentation](configuration) for more information on how to configure IPFS Cluster.


## Snaps

We submit automated experimental builds to the [snapcraft.io](https://snapcraft.io) store:

```
snap install ipfs-cluster --edge
```

We currently do not provide stable snaps.

## Installing from source

The following requirements apply to the installation from source:

* Go 1.9+
* Git
* IPFS or internet connectivity (to download depedencies).

In order to install IPFS Clusters follow the steps:

```
git clone https://github.com/ipfs/ipfs-cluster.git
cd ipfs-cluster
make install
```

After the dependencies have been downloaded, `ipfs-cluster-service` and `ipfs-cluster-ctl` will be installed to your `$GOPATH/bin` (it uses `go install`).

If you rather have them built locally, use `make build` instead. You can run `make clean` to remove any generated artifacts and rewrite the import paths to their original form.
