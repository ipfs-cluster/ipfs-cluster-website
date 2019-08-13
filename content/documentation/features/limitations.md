+++
title = "Current limitations"
weight = 10
+++

# Current limitations

These are the currently observed main problems and things lacking in IPFS Cluster (from what people expect). Be sure to check our [roadmap](/documentation/roadmap/) to see how and when we are planning to address them:

* Unclear about the scalability limits:
  * Tested with 10 cluster peers on a global setup:
    * Repository size of around 70 GB/each
    * ~2000 pins/peer
  * Tested with 5 cluster peers on a regional setup
    * 44 TB disk
    * ~7000 entries in pinset
* The `crdt` consensus option is new and needs to be tested and improved.
