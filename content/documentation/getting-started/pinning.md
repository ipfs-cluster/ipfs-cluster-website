+++
title = "Adding and pinning"
weight = 40
+++

# Adding and pinning

If you are here, you have successfully [downloaded and installed](/documentation/getting-started/installation) `ipfs-cluster-service` and `ipfs-cluster-ctl`, [setup and initialized](/documentation/getting-started/setup) your Cluster peers, and [started your Cluster](/documentation/getting-started/start) with one or several peers.

We will now add pins and content using `ipfs-cluster-ctl`:

* [Adding files to the Cluster](#adding-files-to-the-cluster)
* [Pinning CIDs](#pinning-cids)

<div class="tipbox tip">You can get help and usage information for all <code>ipfs-cluster-ctl</code> commands with <code>ipfs-cluster-ctl --help</code> and <code>ipfs-cluster-ctl &lt;command&gt; --help</code></div>

For extended information on pinset management, including how to list, filter and recover pins, see the [relevant section](/documentation/usage/pinset).

## Adding files to the Cluster

```sh
ipfs-cluster-ctl add myfile.txt
```

The `ipfs-cluster-ctl add` command is very similar to the `ipfs add` command and share most of the same options (such as those that define chunking, the DAG type or which CID-version to use).

However, where the `ipfs add` command only adds to the local IPFS daemon, the `ipfs-cluster-ctl add` command will add to several Cluster peers at the same time. How many it adds depends on the replication factors you set as command flags pin or the defaults in the configuration file.

This means that when the add process is finished, your file will have been fully added to several IPFS daemons (and not necessarily the local one). For example:

```sh
$ ipfs-cluster-ctl add pinning.md
added QmarNBnreCx4YtT4ETXxQ4dn2xQpcTGd2PaVM4b2UuyGku pinning.md
$ ipfs-cluster-ctl pin ls QmarNBnreCx4YtT4ETXxQ4dn2xQpcTGd2PaVM4b2UuyGku # check pin data
QmarNBnreCx4YtT4ETXxQ4dn2xQpcTGd2PaVM4b2UuyGku |  | PIN | Repl. Factor: -1 | Allocations: [everywhere] | Recursive
$ ipfs-cluster-ctl status QmarNBnreCx4YtT4ETXxQ4dn2xQpcTGd2PaVM4b2UuyGku # request status from every peer
QmarNBnreCx4YtT4ETXxQ4dn2xQpcTGd2PaVM4b2UuyGku :
    > cluster0        : PINNED | 2019-07-26T12:25:18.23191214+02:00
    > cluster1        : PINNED | 2019-07-26T10:25:18.234842017Z
    > cluster2        : PINNED | 2019-07-26T10:25:18.212836746Z
    > cluster3        : PINNED | 2019-07-26T10:25:18.238415569Z
    > cluserr4        : PINNED | 2019-07-26T10:25:24.508614677Z
```

## Pinning CIDs

```sh
ipfs-cluster-ctl pin add <cid/ipfs-path>
```

In many cases, you know what content from the IPFS network you want to add to your Cluster. The `ipfs-cluster-ctl pin add` operation is similar to the `ipfs pin add` one, but allows to set Cluster-specific flags, such the replication factors or the name associated to a pin. For example:

```sh
$ ipfs-cluster-ctl pin add --name cluster-website --replication 2 /ipns/cluster.ipfs.io
QmXvQLhK2heNz65fWRabTfbzXwYfaBgEBuTdUJNzp69Xjx :
    > cluster0           : PINNING | 2019-07-26T12:31:08.180738872+02:00
    > cluster1           : REMOTE | 2019-07-26T10:31:08.231791643Z
    > cluster2           : PINNING | 2019-07-26T10:31:08.223206563Z
    > cluster3           : REMOTE | 2019-07-26T10:31:08.227396652Z
    > cluster4           : REMOTE | 2019-07-26T10:31:09.189573842Z
$ ipfs-cluster-ctl pin ls QmXvQLhK2heNz65fWRabTfbzXwYfaBgEBuTdUJNzp69Xjx
QmXvQLhK2heNz65fWRabTfbzXwYfaBgEBuTdUJNzp69Xjx | cluster-website | PIN | Repl. Factor: 2--2 | Allocations: [12D3KooWGbmjg3MDUYFosLNPbE1jKkv5fzKHD7wyGDa1P95iKMjF QmYY1ggjoew5eFrvkenTR3F4uWqtkBkmgfJk8g9Qqcwy51] | Recursive

```

As we see, the pin started pinning in two places (replication = 2). When we check the pin object, we see both the peer IDs it was allocated to and that it is called `cluster-website`.

Pins can be removed at any time with `ipfs-cluster-ctl pin rm`.
