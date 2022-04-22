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
* [Replication factors](#replication-factors)
* [The pinning process](#the-pinning-process)
* [`pin ls` vs `status`](#pin-ls-vs-status)
* [Filtering results](#filtering-results)
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

The process of adding this way is slower than adding to a local IPFS daemon because all the blocks are sent to their remote locations in parallel. As an alternative, the `--local` flag can be provided to the `add` command. In this case, the content will be added to the local IPFS daemon of the peer receiving the request, and then pinned normally. This will make the `add` calls take less time, but the content will not be yet fully replicated when they return.

Adding with `--local` and no additional options will always include the local peer among the allocations for the content (regardless of free space etc.). This can be worked around using the `--allocations` flag to provide different allocations manually, if needed.

Another feature in the `add` command that is not available on IPFS is the possibility of importing CAR files (similar to `ipfs dag import`). In order to import a CAR file you can do `ipfs-cluster-ctl add --format car myfile.car`. CAR files should have a single root, which is the CID that becomes pinned after import. IPFS Cluster does not perform checks to verify that the CAR files are complete and contain all the blocks etc.

## Pinning CIDs

```sh
ipfs-cluster-ctl pin add <cid/ipfs-path>
```

In many cases, you know what content from the IPFS network you want to add to your Cluster. The `ipfs-cluster-ctl pin add` operation is similar to the `ipfs pin add` one, but allows to set Cluster-specific flags, such the replication factors or the name associated to a pin. For example:

```sh
$ ipfs-cluster-ctl pin add --name cluster-website --replication 3 /ipns/cluster.ipfs.io
QmXvQLhK2heNz65fWRabTfbzXwYfaBgEBuTdUJNzp69Xjx :
    > cluster2             : PINNED | 2021-12-07T15:24:58Z | Attempts: 0 | Priority: false
    > cluster3             : PINNING | 2021-12-07T15:24:58Z | Attempts: 0 | Priority: true
    > cluster0             : PINNING | 2021-12-07T15:24:58Z | Attempts: 0 | Priority: true
    > Qmabc123             : REMOTE | 2021-12-07T16:25:07.48933158+01:00 | Attempts: 0 | Priority: false
    > Qmabc456             : REMOTE | 2021-12-07T16:25:07.4893358+01:00 | Attempts: 0 | Priority: false
$ ipfs-cluster-ctl pin ls QmXvQLhK2heNz65fWRabTfbzXwYfaBgEBuTdUJNzp69Xjx
QmXvQLhK2heNz65fWRabTfbzXwYfaBgEBuTdUJNzp69Xjx | cluster-website | PIN | Repl. Factor: 3--3 | Allocations: [12D3KooWGbmjg3MDUYFosLNPbE1jKkv5fzKHD7wyGDa1P95iKMjF QmYY1ggjoew5eFrvkenTR3F4uWqtkBkmgfJk8g9Qqcwy51] | Recursive | Metadata: no | Exp: ∞ | Added: 2021-12-07 16:24:58
```

As we see, the pin started pinning in two places (replication = 3). When we check the pin object, we see both the peer IDs it was allocated to and that it is called `cluster-website`. We also see whether it has any metadata attached, an expiry date and date it was last added.

Pins can be removed at any time with `ipfs-cluster-ctl pin rm`.

## Replication factors

Every pin submitted to IPFS Cluster carries two replication options:

* `replication_factor_min` (`--replication-min` flag in `ipfs-cluster-ctl`)
* `replication_factor_max` (`--replication-max` flag in `ipfs-cluster-ctl`)

The cluster configuration sets the default values that apply when the option is not set.

The **replication_factor_min** value specifies the minimal number of copies that the pin should have in the cluster. If automatic repinning is enabled and the cluster detects that the peers that should be pinning an item are not available, and that the item is under-replicated (the number of peers pinning it is below `replication_factor_min`), it will re-allocate the item to new peers. Pinning will fail directly when there are not enough peers to pin something up to `replication_factor_min`.

The **replication_factor_max** value indicates how many peers should be allocated to the pin. On pin submission, the cluster will try to allocate that many peers, but not fail if it cannot find so many, as long as it finds more than `replication_factor_min`. Repinnings of an item will try to increase allocations to `replication_factor_max`, however automatic repinnings of an item, when enable, will not affect pins that are between the two thresholds.

The recommendation is to use thresholds with some leeway (usually 2-3, or 3-5) when `disable_repinning` is set to `false`. In this case, without leeway, a cluster peer going down for a few seconds could trigger repinnings and result in an unbalanced cluster, even if the peer comes up fine later and still holds the content (at which point it will be unpinned because it is no longer allocated to it).


## The pinning process

Cluster-pinning and unpinning are at the core of the cluster operation and involve multiple internal components but have two main stages:

* The *Cluster-pinning* stage: the pin is correctly persisted by cluster and broadcasted to every other peer.
* The *IPFS-pinning* stage: every peer allocated to the pin must ensure the IPFS daemon gets it pinned.

The stages and the results they produce are actually inspectable with the different options for `pin add`:

* `ipfs-cluster-ctl pin add ...` waits 1 second by default and reports `status` resulting from the ongoing IPFS-pinning process.
* `ipfs-cluster-ctl pin add --no-status ...` does not wait and reports `pin ls` information resulting from the Cluster-pinning process.
* `ipfs-cluster-ctl pin add --wait ...` waits until the IPFS-pinning process is complete in at least 1 peer.

### The Cluster-pinning stage

We **consider a `pin add` operation has been successful when the cluster-pinning stage is finished**. This means the pin has been ingested by Cluster and that things are underway to tell IPFS to pin the content. If IPFS fails to pin the content, Cluster will know, report about it and try to handle the situation. The cluster-pinning stage is relatively fast, but the ipfs-pinning stage can take much longer depending on the amount of things being pinned and the sizes involved. Therefore the second stage happens asynchronously once the cluster-pinning stage is completed.

The process can be summarized as a follows:

1. A pin request arrives including certain options.
2. Given the options (particularly replication factors), a list of current cluster peers is selected as "allocations" for that pin, based on the allocator configuration and the metrics associated to each peer. i.e. the simplest is to make the list ordered by based on how much free space is available on each peer.
3. These and other things result in a pin object which is committed and broadcasted to everyone (the how depends on the [consensus component](/documentation/guides/consensus)).

### The IPFS-pinning stage

Once the Cluster-pinning stage is completed, each peer is notified of a new item in the pinset. If the peer is among the allocations for that item, it will proceed to ask ipfs to pin it:

1. Peer starts "tracking" CID
2. If allocated to it, it queues it for pinning and when it turns comes in the queue an "ipfs pin add" operation is triggered
3. The tracking process waits for the "ipfs pin add" operation to succeed. The pinning operation may time out based on when was the last block received by ipfs, not based on the total amount of time spent pinning.
4. When the pinning completes, the item is considered pinned.
5. If an error happens while pinning, the item goes into error state and will be eventually retried by the cluster, increasing its attempt count.

The pinning process has two different queues which take the available pinning slots. The first one is a "priority" one for new items and items that have not failed to pin many times. The other is used for the rest of items. This allows that pins that cannot complete for whatever reason do not stand in the way and use pinning slots for new pins.

### CRDT-Batching

When CRDT-batching is enabled, pins will be batched in the local peer receiving the pin requests and submitted all together to the network in a single batch. This happens only when the batch reaches its maximum age, or when it gets full (both things controlled in the configuration).

If a peer is restarted before a batch has been broadcasted, these pins will be lost. Thus we recommend stopping requests and waiting for the batch max_age before restarting peers.

## `pin ls` vs `status`

It is very important to distinguish between `ipfs-cluster-ctl pin ls` and `ipfs-cluster-ctl status`. Both endpoints provide a list of CIDs pinned in the cluster, but they do it in very different ways:

* `pin ls` shows shows information from the cluster *shared state* or *global pinset* which is fully available in every peer. It shows which are the allocations and how the pin has been configured. For example:

```sh
QmXvQLhK2heNz65fWRabTfbzXwYfaBgEBuTdUJNzp69Xjx | cluster-website | PIN | Repl. Factor: 2--3 | Allocations: [12D3KooWGbmjg3MDUYFosLNPbE1jKkv5fzKHD7wyGDa1P95iKMjF QmYY1ggjoew5eFrvkenTR3F4uWqtkBkmgfJk8g9Qqcwy51] | Recursive | Metadata: no | Exp: ∞ | Added: 2021-12-07 16:24:58
```

* `status`. however, requests information about the status of each pin on each cluster peer allocated to it, including whether that CID is PINNED on IPFS, or still PINNING, or errored for some reason:

```sh
bafybeiary2ibmljf3l466qzk5hud3rnlk7zped37oik64zlfh22sa5nrg4 | cluster-website:
    > cluster2             : PINNED | 2021-12-07T15:24:58Z | Attempts: 0 | Priority: false
    > cluster3             : PINNED | 2021-12-07T15:24:58Z | Attempts: 0 | Priority: false
    > cluster0             : PINNED | 2021-12-07T15:24:58Z | Attempts: 0 | Priority: false
    > QmYAajUVaFMw7EyUsZqwDhbNmCsP8L7VDRLuXNkEw6DCC1 : REMOTE | 2021-12-07T16:40:08.122100484+01:00 | Attempts: 0 | Priority: false
    > QmaHvxFk6DoNsRHqe2a7UJH66AjGDKPG2HCBxr25YYop32 : REMOTE | 2021-12-07T16:40:08.122100484+01:00 | Attempts: 0 | Priority: false
```

In order to show this information, the `status` request must contact every of the peers allocated to the pin (only the peers pinning something can tell on what state that operation is). Thus, the **`status` request can be very expensive on clusters with many peers**, but provides very useful information on the state of pin. Both commands take an optional `cid` to limit the results to a single item. The `status` results include information to inspect how many attempts to pin something have occurred and whether the last attempt happened via the priority pinning queue or not. Finally, the `status` request supports a `--local` flag to just report status from the local peer.

## Filtering results

The `status` commands supports filtering to display only pins which are in a given situation (in at least one of the peers). The following filters are supported:

* `cluster_error`: pins for which we cannot obtain status information (i.e. the cluster peer is down)
* `pin_error`: pins that failed to pin (due to an ipfs problem or a timeout)
* `unpin_error`: pins that failed to unpin (due to an ipfs problem or a timeout)
* `error`: pins in `pin_error`, `unpin_error` or `cluster_error`
* `unexpected_unpinned`: pins that are not pinned by ipfs, yet they should be pinned and are not pin_queued or pinning right now.
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

## Recovering

Sometimes an item is pinned in the Cluster but it actually fails to pin on the allocated IPFS daemons because of different reasons:

* The IPFS daemon is down or not responding
* The pin operation times out or errors
* It is manually removed from IPFS.

In these cases, the items will show a status of `PIN_ERROR` (equivalently, also `UNPIN_ERROR` when removing) or `UNEXPECTEDLY_UNPINNED`. This is not a cluster issue and it usually indicates a problem with IPFS (content is not available etc.).

In such cases, the `ipfs-cluster-ctl recover` can be used to retrigger a pin or unpin operation against the allocated ipfs daemons as needed, once the problems have been fixed. As explained below, `recover` operations are regularly triggered by every cluster peer automatically anyways. Note that pins can also be re-added with `pin add`, obtaining a similar effect. The main difference is that `recover` happens in sync (waits until done), while `pin add` returns immediately.

<div class="tipbox tip"><code>ipfs-cluster-ctl recover --help</code> provides more information on usage and options.</div>


## Automatic unpinning and recovering

Cluster peers run unpin operations for expired items and recover operations automatically, in intervals defined in the [configuration](/documentation/reference/configuration):

* `state_sync_interval` how often to check for expired items and potentially trigger unpin requests.
* `pin_recover_interval` controls the interval to trigger [recover](#recovering) operations for all pins in error state.
