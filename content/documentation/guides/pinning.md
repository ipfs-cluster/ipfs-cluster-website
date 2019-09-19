+++
title = "Adding and pinning"
weight = 10
+++

# Adding and pinning

Cluster usage mostly consists on adding and removing pins. This is usually performed using the `ipfs-cluster-ctl` utility or talking to one of the Cluster APIs.

<div class="tipbox tip">You can get help and usage information for all <code>ipfs-cluster-ctl</code> commands with <code>ipfs-cluster-ctl --help</code> and <code>ipfs-cluster-ctl &lt;command&gt; --help</code></div>

When working with a large number of pins, it is important to keep an eye on the state of the pinset, whether every pin is getting correctly pinned an allocated. This section provides in-depth explanations on how pinning works and the different operations that a cluster peer can perform to simplify and maintain the cluster pinsets.

<div class="tipbox tip">For clarity, we use <code>ipfs-cluster-ctl</code> commands, but every one of them is using an HTTP REST API endpoint from the cluster peer, so all commands can be performed directly against the API.</div>

* [Adding files](#adding-files)
* [Pinning CIDs](#pinning-cids)
* [The pinning process](#the-pinning-process)
* [`pin ls` vs `status`](#pin-ls-vs-status)
* [Filtering results](#filtering-results)
* [Syncing](#syncing)
* [Recovering](#recovering)
* [Automatic syncing and recovering](#automatic-syncing-and-recovering)

---

## Adding files

```sh
ipfs-cluster-ctl add myfile.txt
```

The `ipfs-cluster-ctl add` command is very similar to the `ipfs add` command and share most of the same options (such as those that define chunking, the DAG type or which CID-version to use).

However, where the `ipfs add` command only adds to the local IPFS daemon, the `ipfs-cluster-ctl add` command will add to several Cluster peers at the same time. How many it adds depends on the replication factors you set as command flags pin or the defaults in the configuration file.

This means that when the add process is finished, your file will have been fully added to several IPFS daemons (and not necessarily the local one). For example:

```shell
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

## The pinning process

Cluster-pinning and unpinning are at the core of the cluster operation and involve multiple internal components but have two main stages:

* The *Cluster-pinning* stage: the pin is correctly persisted by cluster and broadcasted to every other peer.
* The *IPFS-pinning* stage: every peer allocated to the pin must ensure the IPFS daemon gets it pinned.

The stages and the results they produce are actually inspectable with the different options for `pin add`:

* `ipfs-cluster-ctl pin add ...` waits 1 second by default and reports `status` resulting from the ongoing IPFS-pinning process.
* `ipfs-cluster-ctl pin add --no-status ...` does not wait and reports `pin ls` information resulting from the Cluster-pinning process.
* `ipfs-cluster-ctl pin add --wait ...` waits until the IPFS-pinning process is complete.

### The Cluster-pinning stage

We **consider a `pin add` operation has been successful when the cluster-pinning stage is finished**. This means the pin has been ingested by Cluster and that things are underway to tell IPFS to pin the content. If IPFS fails to pin the content, Cluster will know, report about it and try to handle the situation. The cluster-pinning stage is relatively fast, but the ipfs-pinning stage can take days. Therefore the second stage happens asynchronously once the cluster-pinning stage is completed.

The process can be summarized as a follows:

1. A pin request arrives including certain options.
2. Given the options, a list of current cluster peers is selected as "allocations" for that pin, based on how much free space is available on each.
3. These and other things result in a pin object which is commited and broadcasted to everyone (the how depends on the [consensus component](/documentation/guides/consensus)).

### The IPFS-pinning stage

Once the Cluster-pinning stage is completed, each peer is notified of a new item in the pinset. If the peer is among the allocations for that item, it will proceed to ask ipfs to pin it:

1. Peer starts "tracking" CID
2. If allocated to it, an "ipfs pin add" operation is triggered
3. The tracking process waits for the "ipfs pin add" operation to succeed.

## `pin ls` vs `status`

It is very important to distinguish between `ipfs-cluster-ctl pin ls` and `ipfs-cluster-ctl status`. Both endpoints provide a list of CIDs pinned in the cluster, but they do it in very different ways:

* `pin ls` shows shows information from the cluster *shared state* or *global pinset* which is fully available in every peer. It shows which are the allocations and how the pin has been configured. For example:

```sh
QmY7UvWxx2oPBzTpJdHKTrjJbzKYA5GF8Qd8SnGpjXCFAp |  | PIN | Repl. Factor: 2--3 | Allocations: [12D3KooWGbmjg3MDUYFosLNPbE1jKkv5fzKHD7wyGDa1P95iKMjF QmSGCzHkz8gC9fNndMtaCZdf9RFtwtbTEEsGo4zkVfcykD QmdFBMf9HMDH3eCWrc1U11YCPenC3Uvy9mZQ2BedTyKTDf] | Recursive
```

* `status`. however, requests information about the status of each pin on each cluster peer, including whether that CID is PINNED on IPFS, or still PINNING, or errored for some reason:

```sh
QmY7UvWxx2oPBzTpJdHKTrjJbzKYA5GF8Qd8SnGpjXCFAp :
    > cluster0           : PINNED | 2019-07-26T12:18:29.834862706+02:00
    > cluster1           : PINNING | 2019-07-26T10:25:18.365068131Z
    > cluster2           : REMOTE | 2019-07-26T10:25:18.356000031Z
    > cluster3           : REMOTE | 2019-07-26T10:25:18.374354035Z
    > cluster4           : PINNING | 2019-07-26T10:28:19.661061918Z
```

In order to show this information, the `status` request must contact every of the peers (only the peers pinning something can return on what state that operation is). Thus, the **`status` request can be very expensive on clusters with many peers**, but provides very useful information on the state of pin. Both commands take an optional `cid` to limit the results to a single item.

## Filtering results

The `status` commands supports filtering to display only pins which are in a given situation (in at least one of the peers). The following filters are supported:

* `cluster_error`: pins for which we cannot obtain status information (i.e. the cluster peer is down)
* `pin_error`: pins that failed to pin (due to an ipfs problem or a timeout)
* `unpin_error`: pins that failed to unpin (due to an ipfs problem or a timeout)
* `error`: pins in `pin_error` or `unpin_error`
* `pinned`: pins were correctly pinned
* `pinning`: pins that are currently being pinned by ipfs
* `unpinning`: pins that are currently being unpinned by ipfs
* `remote`: pins that are allocated to other cluster peers (remote means: not handled by this peer).
* `pin_queued`: pins that are waiting to start pinning (usually because ipfs is already pinning a bunch of other things)
* `unpin_queued`: pins that are waiting to start unpinning (usually because something else is being unpinned)
* `queued`: pins in `pin_queued` or `unpin_queued` states.

It is sometimes useful to combine this option with the `--local` one. For example:

```sh
ipfs-cluster-ctl status --local --filter pinning,queued
```

will only display CIDs which are still pinning or queued (waiting to start pinning) in the local peer.

```sh
ipfs-cluster-ctl status --filter error
```

will display status information for CIDs which are in error state for some reason (the error message contains more information).

<div class="tipbox tip"><code>ipfs-cluster-ctl status --help</code> provides more information on usage and options</div>

## Syncing

Since the IPFS daemon runs separately from cluster, there might be cases when the `status` reported by a cluster peer does not match the actual pinned status of a CID in the IPFS daemon. These are namely:

* When a CID is manually unpinned from IPFS without cluster knowing about it
* When the IPFS daemon was down in a previous check and could not be contacted
* When bugs exists that may cause such discrepancies (all fixed at this point for all we know).

The `ipfs-cluster-ctl sync` commands triggers a manual re-sync which makes sure the status information tracker by the cluster peer matches the state of pins in the IPFS daemon. As explained below, `sync` operations are regularly triggered by every cluster peer automatically.

<div class="tipbox warning">The <code>sync</code> operation may be removed in future releases as it becomes superfluous.</div>

## Recovering

Sometimes an item is pinned in the Cluster but it actually fails to pin on the allocated IPFS daemons because of different reasons:

* The IPFS deamon is down or not responding
* The pin operation times out or errors

In these cases, the items will show a status of `PIN_ERROR` (equivalently, also `UNPIN_ERROR` when removing). However, the item is correctly allocated in the cluster: the cluster is healthy, all cluster peers know about it and those that should pin it are aware. Thus the error is mostly on the IPFS-side of things and cluster cannot do much about it.

In such cases, the `ipfs-cluster-ctl recover` can be used to retrigger a pin or unpin operation against the allocated ipfs daemons, once the problems have been fixed. As explained below, `recover` operations are regularly triggered by every cluster peer automatically. Note that pins can also be re-added with `pin add`, obtaining a similar effect. The main difference is that `recover` happens in sync (waits until done), while `pin add` returns immediately.

<div class="tipbox tip"><code>ipfs-cluster-ctl recover --help</code> provides more information on usage and options</div>


## Automatic syncing and recovering

Cluster peers run sync and recover operations automatically, in intervals defined in the [configuration](/documentation/reference/configuration):

* `state_sync_interval` controls the interval to make sure that all the items in the global pinset are tracked so that `status` can be reported on them.
* `ipfs_sync_interval` controls the interval to make sure that the ipfs status matches the current view of it that cluster has (the same as [syncing](#syncing) above)
* `pin_recover_interval` controls the interval to trigger [recover](#recovering) operations for all pins in error state.
