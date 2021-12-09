+++
title = "Test Cluster Quickstart"
weight = 5
aliases = [
    "/documentation/quickstart"
]
+++

# Test Cluster Quickstart

This will help you setup a testing, local instance of IPFS Cluster using [Docker](https://docs.docker.com/install/) and [Docker Compose](https://docs.docker.com/compose/install/). The objective is that you get a quick preview of what is to run an IPFS Cluster and how you can interact with it. To successfully follow these instructions you need to be familiar with Docker and with running commands from the command line (including checking out a git-repository).

We will be starting a 3-peer cluster (along with IPFS daemons) using a docker compose template. Once the cluster is up and running, we will be interacting with one of the peers using `ipfs-cluster-ctl`. 

## 0. Install Docker and Docker Compose

* [Docker](https://docs.docker.com/install/)
* [Docker Compose](https://docs.docker.com/compose/install/)

## 1. Download `ipfs-cluster-ctl`

Download and uncompress the latest version `ipfs-cluster-ctl` for your platform from [dist.ipfs.io](https://dist.ipfs.io/#ipfs-cluster-ctl) into a folder of your choice.

`ipfs-cluster-ctl` is the command-line client to the the IPFS Cluster daemon which we will use to inspect the cluster, add and pin content.

## 2. Download the `docker-compose.yml` file

[Download the docker-compose.yml](https://raw.githubusercontent.com/ipfs/ipfs-cluster/master/docker-compose.yml) and place it in the same directory as `ipfs-cluster-ctl`.

## 3. Start up the cluster

From the folder in which you downloaded both files, run:

```
$ docker-compose up
```

Wait until all the containers are running. You may see some errors because the cluster peers start too fast, before IPFs is ready, but they are harmless.

### SELinux Users

If the services fail to start because of "Permission denied" errors, you may need to do the following:

1. Look for AVC denials and grant the ipfs processes the needed SELinux permissions.
2. `sudo chmod -R 1000:100 compose`.  The services seem to use the `root` user when creating the compose directory.
3. Add `:z` to the end of the volumes in the docker-compose.yml file.  See [Configuring SELinux Volumes in Docker](https://docs.docker.com/storage/bind-mounts/#configure-the-selinux-label) for more information.

## 4. Play with the cluster

You should now have a 3-peer IPFS Cluster running! Use `ipfs-cluster-ctl` on a different terminal (same folder) to interact with it:

```shell
./ipfs-cluster-ctl peers ls                      # show information about the peers in the cluster
./ipfs-cluster-ctl add somefile                  # add a file to the cluster
./ipfs-cluster-ctl pin add /ipns/cluster.ipfs.io # pin the cluster website
./ipfs-cluster-ctl status <cid>                  # use the CID shown above to see the status in every peer
./ipfs-cluster-ctl pin ls <cid>                  # inspect the pin information
```

You can learn more about managing the pinset in the [pinning guide](/documentation/guides/pinning).

When you are done, you can run `docker-compose kill`.
