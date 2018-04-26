+++
title = "Frequently Asked Questions"
+++

# Frequently Asked Questions

This page gathers answers to some of the questions the users are asking most...

<div class="tipbox warning">In progress...</div>


## Can I have my cluster peers deployed around the world?

Yes, the `consensus.raft` section of the [Configuration](/documentation/configuration) provides options to adjust the delays and timeouts to deployments with higher network latencies. There are more details in the [Deployment documentation](/documentation/deployment).

## I have trouble running the ipfs/ipfs-cluster Docker container

Check the [Deployment using Docker](/documentation/deployment#deployment-using-docker) section of the documentation. The `ipfs-cluster` container **does not run IPFS**, so you need to run it separately and adjust the `service.json` configuration according to your Docker networking choices.
