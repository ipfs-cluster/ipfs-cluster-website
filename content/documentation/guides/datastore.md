+++
title = "Datastore backends"
weight = 20
+++

# Datastore backends

IPFS Cluster supports several datastore backend options. The backend is a
key-value store for all the persistent storage needed by a cluster peer. This
includes the pinset information and also the CRDT-DAG blockstore etc.

Datastores are highly configurable, and configuration has an impact on
performance, memory footprint and disk footprint. Different datastores will
likely behave differently based on whether the underlying medium are SSDs or
spinning disks. Depending on constraints, hardware used etc. it may be better
to use one or another, but **we recommend the newer Pebble or Badger3** and
discourage using Badger or LevelDB.

Configuration settings for each of the backends can be found in the
[Configuration reference](/documentation/reference/configuration).

## Pebble

[Pebble](https://github.com/cockroachdb/pebble) is a high performant
backend from Cochroachdb, used by default in Cluster:

* Proven to work well on very large pinsets.
* Best disk-usage compared to the rest. No need to trigger GC cycles for space reclaim.
* Performance and memory usage seems on par with Badger3, and behaves better than Badger on both counts.
* Behaves correctly with default settings but we bump them up a bit.
* 0-delay startup times, even with very large amounts of data.
* Options support compression (we chose to leave it enabled by default).
* The Pebble project is officially alive and maintained.
* Pebble only runs on 64-bit architectures.
* One key difference with Badger3 is that Pebble stores keys and values
  together and any lookup for a key will also read the values, while Badger3
  can store keys and values separately (i.e. keys only in the index, which can
  be loaded onto memory when small enough).

## Badger3

[Badger](https://github.com/dgraph-io/badger) is based on the v3 series of the library:

* Badger3 has tons of improvements over Badger.
* Significantly better disk-footprint. GC cycles work better. Still higher footprint than Pebble though.
* Works well with default settings for large clusters.
* Reduced memory usage (because can use more conservative settings to start with).
* Startup times are faster than Badger but still slow for large pinsets.
* Badger3 works with 32-biut architectures and is the default for those.


## Badger

[Badger](https://github.com/dgraph-io/badger) is based on the v1.6.2 version of the library:

* Heavily battle tested, it was used for our largest cluster deployments.
* Bad disk-footprint behaviour: needs regular GC cycles but they don't quite
  achieve to reduce disk usage as much as it would be possible.
* Baseline performance and memory usage.
* Needs configuration tuning for large clusters (see deployment guide).
* Startup times become very slow once the pinset grows (can take minutes to open the datastore).
* Legacy and unmaintained.


## LevelDB

[LevelDB](https://github.com/syndtr/goleveldb) is based on a LevelDB implementation as used by Kubo:

* This backend is known to misbehave with very large number of items.
* Lightweight, needs little tuning and its ok for smaller clusters.
* Disk-footprint is better than Badger.
* It was added as an alternative to Badger, but usage not recommended given
  Pebble and Badger3 options.
* Do not use.
