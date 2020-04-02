+++
title = "Deployment on Kubernetes"
weight = 100
aliases = [
    "/documentation/k8s"
]
+++

# Running Cluster on Kubernetes

This guide will show you how to:

* Run a simple Cluster on Kubernetes
* Using [Kustomize](https://kustomize.io), adapt the Cluster Kubernetes resources to your scenario

<div class="tipbox tip">This guide assumes you have a running Kubernetes cluster to deploy to and have properly configured `kubectl`.</div>

## Prepare Configuration Values

### Configuring the Secret Resource

In Kubernetes, `Secret` objects are used to hold values such as tokens, or private keys.

```yaml
# secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: secret-config
type: Opaque
data:
  cluster-secret: <INSERT_SECRET>
```

### Cluster Secret

To generate the `cluster_secret` value in `secret.yaml`, run the following and insert the output in the appropriate place in the `secret.yaml` file:

```sh
$ od  -vN 32 -An -tx1 /dev/urandom | tr -d ' \n' | base64 -w 0 -
```

### Bootstrap Peer ID and Private Key

To generate the values for `bootstrap_peer_id` and `bootstrap_peer_priv_key`, install [`ipfs-key`](https://github.com/whyrusleeping/ipfs-key) and then run the following:

```sh
$ ipfs-key | base64 -w 0
```

Copy the id into the `env-configmap.yaml` file. I.e:

```yaml
# env-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: env-config
data:
  bootstrap-peer-id: <INSERT_PEER_ID>
```

Then copy the private key value and run the following with it:

```sh
$ echo "<INSERT_PRIV_KEY_VALUE_HERE>" | base64 -w 0 -
```

Copy the output to the `secret.yaml` file.

```yaml
# secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: secret-config
type: Opaque
data:
  cluster-secret: <INSERT_SECRET>
  bootstrap-peer-priv-key: <INSERT_KEY>
```


## Defining a StatefulSet

From the Kubernetes documentation on [StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset):

> Manages the deployment and scaling of a set of Pods, and provides guarantees about the ordering and uniqueness of these Pods.

> Like a Deployment, a StatefulSet manages Pods that are based on an identical container spec. Unlike a Deployment, a StatefulSet maintains a sticky identity for each of their Pods. These pods are created from the same spec, but are not interchangeable: each has a persistent identifier that it maintains across any rescheduling.

This means for us, that any Kubernetes generated configuration, such as hostnames, i.e. `ipfs-cluster-0`, will be associated with the same Pod and VolumeClaim, which means for example, hostnames will always be associated with the same peer id that is stored in the `~/.ipfs-cluster/service.json` file. And all this is important, because it allows us to bootstrap our ipfs-cluster without a spinning up a specific bootstrapping peer.

Breaking the StatefulSet definition into chunks, the first is the preamble and start of the StatefulSet spec:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: ipfs-cluster
spec:
  serviceName: ipfs-cluster
  replicas: 3
  selector:
    matchLabels:
      app: ipfs-cluster
```

Following that is the definition of the `go-ipfs` container:

```yaml
  template:
    metadata:
      labels:
        app: ipfs-cluster
    spec:
      initContainers:
        - name: configure-ipfs
          image: "ipfs/go-ipfs:v0.4.18"
          command: ["sh", "/custom/configure-ipfs.sh"]
          volumeMounts:
            - name: ipfs-storage
              mountPath: /data/ipfs
            - name: configure-script
              mountPath: /custom
      containers:
        - name: ipfs
          image: "ipfs/go-ipfs:v0.4.18"
          imagePullPolicy: IfNotPresent
          env:
            - name: IPFS_FD_MAX
              value: "4096"
          ports:
            - name: swarm
              protocol: TCP
              containerPort: 4001
            - name: swarm-udp
              protocol: UDP
              containerPort: 4002
            - name: api
              protocol: TCP
              containerPort: 5001
            - name: ws
              protocol: TCP
              containerPort: 8081
            - name: http
              protocol: TCP
              containerPort: 8080
          livenessProbe:
            tcpSocket:
              port: swarm
            initialDelaySeconds: 30
            timeoutSeconds: 5
            periodSeconds: 15
          volumeMounts:
            - name: ipfs-storage
              mountPath: /data/ipfs
            - name: configure-script
              mountPath: /custom
          resources:
            {}
```

Take note of the `initContainers` section, which is used to configure the ipfs node with production appropriate values, see [Defining Configuration Scripts](#defining-configuration-scripts).

Next we define the `ipfs-cluster` container:

```yaml
        - name: ipfs-cluster
          image: "ipfs/ipfs-cluster:latest"
          imagePullPolicy: IfNotPresent
          command: ["sh", "/custom/entrypoint.sh"]
          envFrom:
            - configMapRef:
                name: env-config
          env:
            - name: BOOTSTRAP_PEER_ID
              valueFrom:
                configMapRef:
                  name: env-config
                  key: bootstrap-peer-id
            - name: BOOTSTRAP_PEER_PRIV_KEY
              valueFrom:
                secretKeyRef:
                  name: secret-config
                  key: bootstrap-peer-priv-key
            - name: CLUSTER_SECRET
              valueFrom:
                secretKeyRef:
                  name: secret-config
                  key: cluster-secret
            - name: CLUSTER_MONITOR_PING_INTERVAL
              value: "3m"
            - name: SVC_NAME
              value: $(CLUSTER_SVC_NAME)
          ports:
            - name: api-http
              containerPort: 9094
              protocol: TCP
            - name: proxy-http
              containerPort: 9095
              protocol: TCP
            - name: cluster-swarm
              containerPort: 9096
              protocol: TCP
          livenessProbe:
            tcpSocket:
              port: cluster-swarm
            initialDelaySeconds: 5
            timeoutSeconds: 5
            periodSeconds: 10
          volumeMounts:
            - name: cluster-storage
              mountPath: /data/ipfs-cluster
            - name: configure-script
              mountPath: /custom
          resources:
            {}
```

Note that `BOOTSTRAP_PEER_ID` and `BOOTSTRAP_PEER_PRIV_KEY` were the values we defined earlier, they will be used only be the very first ipfs-cluster container `ipfs-cluster-0` and then `BOOTSTRAP_PEER_ID` will be used to pass the bootstrapping multiaddress to the other ipfs-cluster containers.

Finally, we define the volumes for the configuration scripts and also the data volumes for the ipfs and ipfs-cluster containers:

```yaml
      volumes:
      - name: configure-script
        configMap:
          name: ipfs-cluster-set-bootstrap-conf


  volumeClaimTemplates:
    - metadata:
        name: cluster-storage
      spec:
        storageClassName: standard
        accessModes: ["ReadWriteOnce"]
        persistentVolumeReclaimPolicy: Retain
        resources:
          requests:
            storage: 5Gi
    - metadata:
        name: ipfs-storage
      spec:
        storageClassName: standard
        accessModes: ["ReadWriteOnce"]
        persistentVolumeReclaimPolicy: Retain
        resources:
          requests:
            storage: 200Gi
```

Depending on your cloud provider, you will have to change the value of `storageClassName` to the appropriate value.

The StatefulSet definition as an entirety, can be found at [github.com/lanzafame/ipfs-cluster-k8s](https://github.com/lanzafame/ipfs-cluster-k8s/blob/deploy-k8s-guide/ipfs-cluster-base/cluster-statefulset.yaml).

## Defining Configuration Scripts

The ConfigMap contains two scripts, `entrypoint.sh` which enables hands-free bootstrapping of the ipfs-cluster cluster and `configure-ipfs.sh` which configures the `ipfs` daemon with production values. For more information about configuring ipfs for production, see [`go-ipfs` configuration tweaks](/documentation/deployment/#go-ipfs-configuration-tweaks).

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: ipfs-cluster-set-bootstrap-conf
data:
  entrypoint.sh: |
    #!/bin/sh
    user=ipfs

    # This is a custom entrypoint for k8s designed to connect to the bootstrap
    # node running in the cluster. It has been set up using a configmap to
    # allow changes on the fly.


    if [ ! -f /data/ipfs-cluster/service.json ]; then
      ipfs-cluster-service init
    fi

    PEER_HOSTNAME=`cat /proc/sys/kernel/hostname`

    grep -q ".*ipfs-cluster-0.*" /proc/sys/kernel/hostname
    if [ $? -eq 0 ]; then
      CLUSTER_ID=${BOOTSTRAP_PEER_ID} \
      CLUSTER_PRIVATEKEY=${BOOTSTRAP_PEER_PRIV_KEY} \
      exec ipfs-cluster-service daemon --upgrade
    else
      BOOTSTRAP_ADDR=/dns4/${SVC_NAME}-0/tcp/9096/ipfs/${BOOTSTRAP_PEER_ID}

      if [ -z $BOOTSTRAP_ADDR ]; then
        exit 1
      fi
      # Only ipfs user can get here
      exec ipfs-cluster-service daemon --upgrade --bootstrap $BOOTSTRAP_ADDR --leave
    fi

  configure-ipfs.sh: |
    #!/bin/sh
    set -e
    set -x
    user=ipfs
    # This is a custom entrypoint for k8s designed to run ipfs nodes in an appropriate
    # setup for production scenarios.

    mkdir -p /data/ipfs && chown -R ipfs /data/ipfs

    if [ -f /data/ipfs/config ]; then
      if [ -f /data/ipfs/repo.lock ]; then
        rm /data/ipfs/repo.lock
      fi
      exit 0
    fi

    ipfs init --profile=badgerds,server
    ipfs config Addresses.API /ip4/0.0.0.0/tcp/5001
    ipfs config Addresses.Gateway /ip4/0.0.0.0/tcp/8080
    ipfs config --json Swarm.ConnMgr.HighWater 2000
    ipfs config --json Datastore.BloomFilterSize 1048576
    ipfs config Datastore.StorageMax 100GB
```

## Exposing IPFS Cluster Endpoints

The final step for us is to define the `Service` which expose the IPFS Cluster endpoints to the outside the `Pod`.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ipfs-cluster
  annotations:
      external-dns.alpha.kubernetes.io/hostname: change.me.com
  labels:
    app: ipfs-cluster
spec:
  type: LoadBalancer
  ports:
    - name: swarm
      targetPort: swarm
      port: 4001
    - name: swarm-udp
      targetPort: swarm-udp
      port: 4002
    - name: ws
      targetPort: ws
      port: 8081
    - name: http
      targetPort: http
      port: 8080
    - name: api-http
      targetPort: api-http
      port: 9094
    - name: proxy-http
      targetPort: proxy-http
      port: 9095
    - name: cluster-swarm
      targetPort: cluster-swarm
      port: 9096
  selector:
    app: ipfs-cluster
```

Depending on where and how you have set up your Kubernetes cluster, you may be able to make use of the [ExternalDNS](https://github.com/kubernetes-incubator/external-dns) annotation `external-dns.alpha.kubernetes.io/hostname`, which will automatically take the provided value, `change.me.com`, and create a DNS record in the configured DNS provider, i.e. AWS Route53 or Google CloudDNS.

Also note that the `targetPort` fields are using the named ports from the `PodSpec` defined in the `StatefulSet` resource.
