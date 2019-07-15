+++
title = "PubSub"
weight = 3
+++

# Pub-sub

_Needs to be expanded upon, could only find info about pubsub in `guides/configuration`_

The `pubsubmon` implementation collects and broadcasts metrics using libp2p's pubsub. This will provide a more efficient and scalable approach for metric distribution.

|Key|Default|Description|
|:---|:-------|:-----------|
|`check_interval` | `"15s"` | The interval between checks making sure that no metrics are expired for any peers in the peerset. If an expired metric is detected, an alert is triggered. This may trigger repinning of items. |
