+++
title = "Consensus"
weight = 9
+++ 

# The `consensus` section

The `consensus` contains configuration objects for the different implementations of the consensus component.

##### > `raft`

This is the default (and only) consensus implementation available.

|Key|Default|Description|
|:---|:-------|:-----------|
|`init_peerset`| `[]` | An array of peer IDs specifying the initial peerset when no raft state exists. |
|`wait_for_leader_timeout` | `"15s"` | How long to wait for a Raft leader to be elected before throwing an error. |
|`network_timeout` | `"10s"` | How long before Raft protocol network operations timeout. |
|`commit_retries` | `1` | How many times to retry committing an entry to the Raft log on failure. |
|`commit_retry_delay` | `"200ms"` | How long to wait before commit retries. |
|`backups_rotate` | `6` | How many backup copies on the state to keep when it's cleaned up. |
|`heartbeat_timeout` | `"1s"` | See https://godoc.org/github.com/hashicorp/raft#Config . |
|`election_timeout` | `"1s"` |  See https://godoc.org/github.com/hashicorp/raft#Config . |
|`commit_timeout` | `"50ms"` |  See https://godoc.org/github.com/hashicorp/raft#Config . |
|`max_append_entries` | `64` |  See https://godoc.org/github.com/hashicorp/raft#Config . |
|`trailing_logs` | `10240` |  See https://godoc.org/github.com/hashicorp/raft#Config . |
|`snapshot_interval` | `"2m0s"` |  See https://godoc.org/github.com/hashicorp/raft#Config . |
|`snapshot_threshold` | `8192` |  See https://godoc.org/github.com/hashicorp/raft#Config . |
|`leader_lease_timeout` | `"500ms"` |  See https://godoc.org/github.com/hashicorp/raft#Config . |

Raft stores and maintains the peerset internally but the cluster configuration offers the option to manually provide the peerset for the first start of a peer using the `init_peerset` key in the `raft` section of the configuration. For example:

```
"init_peerset": [
  "QmPQD6NmQkpWPR1ioXdB3oDy8xJVYNGN9JcRVScLAqxkLk",
  "QmcDV6Tfrc4WTTGQEdatXkpyFLresZZSMD8DgrEhvZTtYY",
  "QmWXkDxTf17MBUs41caHVXWJaz1SSAD79FVLbBYMTQSesw",
  "QmWAeBjoGph92ktdDb5iciveKuAX3kQbFpr5wLWnyjtGjb"
]
```

This will allow you to start a Cluster from scratch with already fixed peerset. See the [Starting multiple peers with a fixed peerset](/documentation/starting/#starting-multiple-peers-with-a-fixed-peerset) section.

###