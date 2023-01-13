## Pre Setup
https://killer.sh
https://kubernetes.io/docs
https://kubernetes.io/blog

Once you’ve gained access to your terminal it might be wise to spend ~1 minute to setup your environment. You could set these:

~~~powershell
alias k=kubectl                         # will already be pre-configured
export do="--dry-run=client -o yaml"    # k create deploy nginx --image=nginx $do
export now="--force --grace-period 0"   # k delete pod x $now
~~~

Vim
The following settings will already be configured in your real exam environment in ~/.vimrc. But it can never hurt to be able to type these down:

~~~bash
set tabstop=2
set expandtab
set shiftwidth=2
~~~

More setup suggestions are in the tips section.

## Question 1 | Contexts
~~~powershell
k config get-contexts -o name > /opt/course/1/contexts
k config get-contexts | awk '{print $2}' > /opt/course/1/contexts

vim /opt/course/1/context_default_kubectl.sh
kubectl config get-contexts -o name

vim /opt/course/1/context_default_no_kubectl.sh
cat ~/.kube/config | grep current
cat ~/.kube/config | grep current | sed -e "s/current-context: //"
cat ~/.kube/config | grep current | awk -F " " '{print $2}'
~~~



## Question 2 | Schedule Pod on Controlplane Node
~~~powershell
kubectl config use-context k8s-c1-H
k get node # find controlplane node
k describe node cluster1-controlplane1 | grep Taint -A1 # get controlplane node taints
k get node cluster1-controlplane1 --show-labels # get controlplane node labels
k run pod1 --image=httpd:2.4.41-alpine --dry-run=client -oyaml > 2.yaml
~~~

https://kubernetes.io/zh-cn/docs/concepts/scheduling-eviction/taint-and-toleration/

~~~powershell
# 2.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: pod1
  name: pod1
spec:
  containers:
  - image: httpd:2.4.41-alpine
    name: pod1-container                       # change
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
  tolerations:
  - key: "node-role.kubernetes.io/master"
    operator: "Equal"
    value: ""
    effect: "NoSchedule"
  nodeSelector:                                # add
    node-role.kubernetes.io/control-plane: ""  # add
status: {}
~~~

k create -f 2.yaml 
k get pod pod1 -o wide

## Question 3 | Scale down StatefulSet

~~~powershell
kubectl config use-context k8s-c1-H
k -n project-c13 get pod | grep o3db
k -n project-c13 get deploy,ds,sts | grep o3db
k -n project-c13 get pod --show-labels | grep o3db
k -n project-c13 scale sts o3db --replicas 1
~~~

## Question 4 | Pod Ready if Service is reachable
~~~powershell
k run ready-if-service-ready --image=nginx:1.16.1-alpine --dry-run=client -oyaml > 4_pod1.yaml

k create -f 4_pod1.yaml 
k get pod ready-if-service-ready
k describe pod ready-if-service-ready
k run am-i-ready --image=nginx:1.16.1-alpine --labels="id=cross-server-ready"
k describe svc service-am-i-ready
k get ep # also possible

~~~

~~~powershell
# 4_pod1.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: ready-if-service-ready
  name: ready-if-service-ready
spec:
  containers:
  - image: nginx:1.16.1-alpine
    name: ready-if-service-ready
    resources: {}
    livenessProbe:                                      # add from here
      exec:
        command:
        - 'true'
    readinessProbe:
      exec:
        command:
        - sh
        - -c
        - 'wget -T2 -O- http://service-am-i-ready:80'   # to here
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
~~~

## Question 5 | Kubectl sorting
~~~powershell
kubectl config use-context k8s-c1-H
# /opt/course/5/find_pods.sh
kubectl get pod -A --sort-by=.metadata.creationTimestamp
# /opt/course/5/find_pods_uid.sh
kubectl get pod -A --sort-by=.metadata.uid
~~~

## Question 6 | Storage, PV, PVC, Pod volume
~~~powershell
# 6_pv.yaml
kind: PersistentVolume
apiVersion: v1
metadata:
 name: safari-pv
spec:
 capacity:
  storage: 2Gi
 accessModes:
  - ReadWriteOnce
 hostPath:
  path: "/Volumes/Data"
~~~

~~~powershell
# 6_pvc.yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: safari-pvc
  namespace: project-tiger
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
     storage: 2Gi
~~~

~~~powershell
k -n project-tiger get pv,pvc

k -n project-tiger create deploy safari \
  --image=httpd:2.4.41-alpine $do > 6_dep.yaml
~~~

~~~powershell
# 6_dep.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: safari
  name: safari
  namespace: project-tiger
spec:
  replicas: 1
  selector:
    matchLabels:
      app: safari
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: safari
    spec:
      volumes:                                      # add
      - name: safari-data                           # add
        persistentVolumeClaim:                      # add
          claimName: safari-pvc                     # add
      containers:
      - image: httpd:2.4.41-alpine
        name: container
        volumeMounts:                               # add
        - name: safari-data                         # add
          mountPath: /tmp/safari-data               # add
~~~

~~~powershell
k -f 6_dep.yaml create
k -n project-tiger describe pod safari-5cbf46d6d-mjhsb  | grep -A2 Mounts:
~~~


## Question 7 | Node and Pod Resource Usage
~~~powershell
k top -h
k top node
k top pod -h
# /opt/course/7/pod.sh
kubectl top pod --containers=true
~~~

Question 8 | Get Controlplane Information
~~~powershell
ssh cluster1-controlplane1
ps aux | grep kubelet # shows kubelet process
find /etc/systemd/system/ | grep kube
find /etc/systemd/system/ | grep etcd
find /etc/kubernetes/manifests/
kubectl -n kube-system get pod -o wide | grep controlplane1
kubectl -n kube-system get ds
kubectl -n kube-system get deploy

# /opt/course/8/controlplane-components.txt
kubelet: process
kube-apiserver: static-pod
kube-scheduler: static-pod
kube-controller-manager: static-pod
etcd: static-pod
dns: pod coredns
~~~

## Question 9 | Kill Scheduler, Manual Scheduling
~~~powershell
k get node
ssh cluster2-controlplane1
kubectl -n kube-system get pod | grep schedule

cd /etc/kubernetes/manifests/
mv kube-scheduler.yaml ..
kubectl -n kube-system get pod | grep schedule
k run manual-schedule --image=httpd:2.4-alpine
k get pod manual-schedule -o wide

k get pod manual-schedule -o yaml > 9.yaml
spec:
  nodeName: cluster2-controlplane1        # add the controlplane node name

k -f 9.yaml replace --force
k get pod manual-schedule -o wide

ssh cluster2-controlplane1
cd /etc/kubernetes/manifests/
mv …/kube-scheduler.yaml .
kubectl -n kube-system get pod | grep schedule

k run manual-schedule2 --image=httpd:2.4-alpine
k get pod -o wide | grep schedule
~~~

## Question 10 | RBAC ServiceAccount Role RoleBinding
~~~powershell
k -n project-hamster create sa processor
k -n project-hamster create role -h # examples

k -n project-hamster create role processor --verb=create --resource=secret --resource=configmap
k -n project-hamster create rolebinding -h # examples
k -n project-hamster create rolebinding  processor --role=processor --serviceaccount=project-hamster:processor
k auth can-i -h

➜ k -n project-hamster auth can-i create secret --as system:serviceaccount:project-hamster:processor
yes

➜ k -n project-hamster auth can-i create configmap --as system:serviceaccount:project-hamster:processor
yes

➜ k -n project-hamster auth can-i create pod --as system:serviceaccount:project-hamster:processor
no

➜ k -n project-hamster auth can-i delete secret --as system:serviceaccount:project-hamster:processor
no

➜ k -n project-hamster auth can-i get configmap --as system:serviceaccount:project-hamster:processor
no

~~~

~~~powershell
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: processor
  namespace: project-hamster
rules:
- apiGroups:
  - ""
  resources:
  - secrets
  - configmaps
  verbs:
  - create
~~~

## Question 11 | DaemonSet on all Nodes
~~~powershell
k -n project-tiger create deployment --image=httpd:2.4-alpine ds-important $do > 11.yaml
k -f 11.yaml create
k -n project-tiger get ds
~~~

~~~powershell
# 11.yaml
apiVersion: apps/v1
kind: DaemonSet                                     # change from Deployment to Daemonset
metadata:
  creationTimestamp: null
  labels:                                           # add
    id: ds-important                                # add
    uuid: 18426a0b-5f59-4e10-923f-c0e078e82462      # add
  name: ds-important
  namespace: project-tiger                          # important
spec:
  #replicas: 1                                      # remove
  selector:
    matchLabels:
      id: ds-important                              # add
      uuid: 18426a0b-5f59-4e10-923f-c0e078e82462    # add
  #strategy: {}                                     # remove
  template:
    metadata:
      creationTimestamp: null
      labels:
        id: ds-important                            # add
        uuid: 18426a0b-5f59-4e10-923f-c0e078e82462  # add
    spec:
      containers:
      - image: httpd:2.4-alpine
        name: ds-important
        resources:
          requests:                                 # add
            cpu: 10m                                # add
            memory: 10Mi                            # add
      tolerations:                                  # add
      - effect: NoSchedule                          # add
        key: node-role.kubernetes.io/control-plane  # add
#status: {}                                         # remove

~~~

## Question 12 | Deployment on all Nodes
~~~powershell
k -n project-tiger create deployment --image=nginx:1.17.6-alpine deploy-important $do > 12.yaml
~~~

~~~powershell
# 12.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    id: very-important                  # change
  name: deploy-important
  namespace: project-tiger              # important
spec:
  replicas: 3                           # change
  selector:
    matchLabels:
      id: very-important                # change
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        id: very-important              # change
    spec:
      containers:
      - image: nginx:1.17.6-alpine
        name: container1                # change
        resources: {}
      - image: kubernetes/pause         # add
        name: container2                # add
      affinity:                                             # add
        podAntiAffinity:                                    # add
          requiredDuringSchedulingIgnoredDuringExecution:   # add
          - labelSelector:                                  # add
              matchExpressions:                             # add
              - key: id                                     # add
                operator: In                                # add
                values:                                     # add
                - very-important                            # add
            topologyKey: kubernetes.io/hostname             # add
status: {}
~~~

~~~powershell
# 12.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    id: very-important                  # change
  name: deploy-important
  namespace: project-tiger              # important
spec:
  replicas: 3                           # change
  selector:
    matchLabels:
      id: very-important                # change
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        id: very-important              # change
    spec:
      containers:
      - image: nginx:1.17.6-alpine
        name: container1                # change
        resources: {}
      - image: kubernetes/pause         # add
        name: container2                # add
      topologySpreadConstraints:                 # add
      - maxSkew: 1                               # add
        topologyKey: kubernetes.io/hostname      # add
        whenUnsatisfiable: DoNotSchedule         # add
        labelSelector:                           # add
          matchLabels:                           # add
            id: very-important                   # add
status: {}

~~~

## Question 13 | Multi Containers and Pod shared Volume
~~~powershell
~~~

Question 14 | Find out Cluster Information
Question 15 | Cluster Event Logging
Question 16 | Namespaces and Api Resources
Question 17 | Find Container of Pod and check info
Question 18 | Fix Kubelet
Question 19 | Create Secret and mount into Pod
Question 20 | Update Kubernetes Version and join cluster
Question 21 | Create a Static Pod and Service
Question 22 | Check how long certificates are valid
Question 23 | Kubelet client/server cert info
Question 24 | NetworkPolicy
Question 25 | Etcd Snapshot Save and Restore
Extra Question 1 | Find Pods first to be terminated
Extra Question 2 | Curl Manually Contact API
Preview Question 1
Preview Question 2
Preview Question 3
CKA Tips Kubernetes 1.26
