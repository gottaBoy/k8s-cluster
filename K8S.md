
# k8s 学习笔记
1. Docker基础
2. Docker镜像
3. Dockerfile
4. kubernetes基础
5. Master节点
6. Node节点
7. Pod
8. Label & Selector
8. RC 和 RS
9. Deployment
10. StatefulSet
11. DaemonSet
12. Service
13. Ingress
14. HPA
15. ConfigMap
16. Secret
17. Volumes
18. PV/PVC
19. CronJob
20. Taint&Toleration
21. InitContainer
22. Affinity
23. RBAC
24. Ephemeral Containers

## docker
命令
> docker version
~~~powershell
docker version
Client:
 Version:           18.09.9
 API version:       1.39
 Go version:        go1.11.13
 Git commit:        039a7df9ba
 Built:             Wed Sep  4 16:51:21 2019
 OS/Arch:           linux/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          18.09.9
  API version:      1.39 (minimum version 1.12)
  Go version:       go1.11.13
  Git commit:       039a7df
  Built:            Wed Sep  4 16:22:32 2019
  OS/Arch:          linux/amd64
  Experimental:     false
~~~


> docker info
~~~powershell
docker info
Containers: 0
 Running: 0
 Paused: 0
 Stopped: 0
Images: 0
Server Version: 18.09.9
Storage Driver: overlay2
 Backing Filesystem: xfs
 Supports d_type: true
 Native Overlay Diff: true
Logging Driver: json-file
Cgroup Driver: cgroupfs
Plugins:
 Volume: local
 Network: bridge host macvlan null overlay
 Log: awslogs fluentd gcplogs gelf journald json-file local logentries splunk syslog
Swarm: inactive
Runtimes: runc
Default Runtime: runc
Init Binary: docker-init
containerd version: 9ba4b250366a5ddde94bb7c9d1def331423aa323
runc version: N/A
init version: fec3683
Security Options:
 seccomp
  Profile: default
Kernel Version: 6.1.2-1.el7.elrepo.x86_64
Operating System: CentOS Linux 7 (Core)
OSType: linux
Architecture: x86_64
CPUs: 2
Total Memory: 3.841GiB
Name: k8s-master1
ID: W2TP:JY36:HU35:WMC7:5NMB:D7WQ:U47H:QIFE:UPAF:H2ZJ:6BQB:YQ67
Docker Root Dir: /var/lib/docker
Debug Mode (client): false
Debug Mode (server): false
Registry: https://index.docker.io/v1/
Labels:
Experimental: false
Insecure Registries:
 127.0.0.0/8
Live Restore Enabled: false
Product License: Community Engine
~~~


> dokcer search
~~~powershell
dokcer search centos
dokcer pull alpine:latest
dokcer push
dokcer run [-d] --rm # nginx -g daemon off
dokcer logs -f imagesId
dokcer ps [-a,-p]
dokcer exec
dokcer cp
dokcer rmi
dokcer rm
dokcer tag
dokcer images
dokcer stop
dokcer build [-t]
dokcer history
docker commmit [-a,-m] containerId name:latest
docker login

docker exec -it  <your-container-name>   /bin/sh
kubectl exec -it <your-pod-name> -n <your-namespace>  -- /bin/sh
kubectl exec -it <your-pod-name> -n <your-namespace>  -- bash
~~~

> Dockerfile指令

~~~powershell
FROM：继承基础镜像
MAINTAINER：镜像制作作者信息
RUN：用来执行shell命令
EXPOSE：暴露端口号
CMD：启动容器默认执行的命令
ENTRYPOINT：启动容器真正执行的命令
VOLUME：创建挂载点
ENV：配置环境变量
ADD：复制文件到容器会解压
COPY：复制文件到容器
WORKDIR：设置容器的工作目录
USER：容器使用的用户
LABEL: 标签
~~~

> Dockerfile 
~~~powershell
FROM nginx:latest
MAINTAINER minyi
# RUN useradd -D my
# USER my

RUN useradd my && mkdir -p /my
CMD["sh", "-c", "echo 1"]
ENV envtest=test version=1.0
CMD echo "envtest:$envtest version:$version"
ADD ./index.tar.gz /usr/share/nginx/html/
WORKDIR /usr/share/nginx/html
COPY /my/ .
VOLUME /data
# ENTRYPOINT["echo"]
# CMD["10"]
~~~


> Alpine、scratch、Debian、slim 
~~~powershell
docker build -t nginx:test
docker run nginx:test envtest:test version:1.0
docker run -ti --rm -v `pwd`/web:/data nginx:test bash

dockerfile 分阶段
COPY --from=0 or name
~~~

## master
~~~powershell
kubectl get clusterrole
kubectl get storageclass
kubectl get ingressclass
kubectl get secret
kubectl get ep
kubectl get event
time kubectl delete po nginx 
kubectl get deploy -A -owide
kubectl get rs -A -owide
kubectl get rc -A -owide
kubectl get sts -A -owide
kubectl edit sts nginx
kubectl delete sts nginx --cascade=false # 采用非级联删除
kubectl get ds nginx
kubectl explain ingressclass    
~~~

## node节点

## Pod

Pod是Kubernetes中最小的单元，它由一组、一个或多个容器组成，每个Pod还包含了一个Pause容器，Pause容器是Pod的父容器，主要负责僵尸进程的回收管理，通过Pause容器可以使同一个Pod里面的多个容器共享存储、网络、PID、IPC等

> Pod

1.3 Pod探针

- StartupProbe：k8s1.16版本后新加的探测方式，用于判断容器内应用程序是否已经启动。如果配置了startupProbe，就会先禁止其他的探测，直到它成功为止，成功后将不在进行探测。
- LivenessProbe：用于探测容器是否运行，如果探测失败，kubelet会根据配置的重启策略进行相应的处理。若没有配置该探针，默认就是success。
- ReadinessProbe：一般用于探测容器内的程序是否健康，它的返回值如果为success，那么久代表这个容器已经完成启动，并且程序已经是可以接受流量的状态。


1.4 Pod探针的检测方式

- ExecAction：在容器内执行一个命令，如果返回值为0，则认为容器健康。
- TCPSocketAction：通过TCP连接检查容器内的端口是否是通的，如果是通的就认为容器健康。
- HTTPGetAction：通过应用程序暴露的API地址来检查程序是否是正常的，如果状态码为200~400之间，则认为容器健康。


1.5 探针检查参数配置
~~~powershell
#      initialDelaySeconds: 60       # 初始化时间
#      timeoutSeconds: 2     # 超时时间
#      periodSeconds: 5      # 检测间隔
#      successThreshold: 1 # 检查成功为1次表示就绪
#      failureThreshold: 2 # 检测失败2次表示未就绪
~~~

> Pod下线 零宕机
Prestop：先去请求eureka接口，把自己的IP地址和端口号，进行下线，eureka从注册表中删除该应用的IP地址。然后容器进行sleep 90;kill `pgrep java`

~~~powershell
Terminating
Endpoint ip
Prestop
~~~


## RC && RS

- Replication Controller（简称RC）可确保Pod副本数达到期望值
- ReplicaSet是支持基于集合的标签选择器的下一代Replication Controller，它主要用作Deployment协调创建、删除和更新Pod，和Replication Controller唯一的区别是，ReplicaSet支持标签选择器

> Replication Controller
~~~powershell
apiVersion: v1
kind: ReplicationController
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    app: nginx
  template:
    metadata:
      name: nginx
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
~~~

> ReplicaSet
~~~powershell
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: frontend
  labels:
    app: guestbook
    tier: frontend
spec:
  # modify replicas according to your case
  replicas: 3
  selector:
    matchLabels:
      tier: frontend
    matchExpressions:
      - {key: tier, operator: In, values: [frontend]}
  template:
    metadata:
      labels:
        app: guestbook
        tier: frontend
    spec:
      containers:
      - name: php-redis
        image: gcr.io/google_samples/gb-frontend:v3
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
        env:
        - name: GET_HOSTS_FROM
          value: dns
          # If your cluster config does not include a dns service, then to
          # instead access environment variables to find service host
          # info, comment out the 'value: dns' line above, and uncomment the
          # line below.
          # value: env
        ports:
        - containerPort: 80
~~~

## Deployment DaemonSet StatefulSet
1.1 Deployment概念

用于部署无状态的服务，这个最常用的控制器。一般用于管理维护企业内部无状态的微服务，比如configserver、zuul、springboot。他可以管理多个副本的Pod实现无缝迁移、自动扩容缩容、自动灾难恢复、一键回滚等功能

1.2 创建一个Deployment
~~~powershell
# 手动创建：
kubectl create deployment nginx --image=nginx:1.15.2
kubectl get deploy -owide
~~~

从文件创建 cat nginx-deploy.yaml 
~~~powershell
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "1"
  generation: 1
  labels:
    app: nginx
  name: nginx
  namespace: default
spec:
  progressDeadlineSeconds: 600
  replicas: 2 #副本数
  revisionHistoryLimit: 10 # 历史记录保留的个数
  selector:
    matchLabels:
      app: nginx
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate # 更新策略 根据partion设置灰度发布
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx:1.15.2
        imagePullPolicy: IfNotPresent
        name: nginx
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
~~~

1.3 Deployment的更新
更改deployment的镜像并记录：
~~~powershell
kubectl set image deploy nginx nginx=nginx:1.15.3 –record
~~~

查看更新过程：
~~~powershell
kubectl rollout status deploy nginx

kubectl describe deploy nginx 
~~~


1.4 Deployment回滚

查看历史版本
~~~powershell
kubectl rollout history deploy nginx
~~~

执行更新操作
~~~powershell
kubectl set image deploy nginx nginx=nginx:887696da --record
~~~

回滚到上一个版本
~~~powershell
kubectl rollout undo deploy nginx
kubectl get po
kubectl get deploy nginx -oyaml | grep nginx
~~~

进行多次更新
~~~powershell
kubectl set image deploy nginx nginx=nginx:887696da --record
kubectl set image deploy nginx nginx=nginx:887696da --record
~~~

查看指定版本的详细信息
~~~powershell
kubectl rollout history deploy nginx --revision=5
~~~

回滚到执行的版本
~~~powershell
kubectl rollout undo deploy nginx --to-revision=5
~~~

查看deploy状态
~~~powershell
kubectl get deploy -oyaml
~~~

1.5 Deployment的暂停和恢复
Deployment 暂停功能
~~~powershell
kubectl rollout pause deployment nginx
kubectl set image deploy nginx nginx=nginx:1.15.3 --record
~~~

进行第二次配置变更 添加内存CPU配置
~~~powershell
kubectl set -h
kubectl set resources deploy nginx -c nginx --limits=cpu=200m,memory=128Mi --requests=cpu=10m,memory=16Mi
kubectl get deploy nginx -oyaml
# 查看pod是否被更新
kubectl get po
kubectl rollout resume deploy nginx
kubectl get rs
kubectl get deploy nginx -oyaml

# 扩容
kubectl scale --replicas=3 deploy nginx

# .spec.revisionHistoryLimit：设置保留RS旧的revision的个数，设置为0的话，不保留历史数据
# .spec.minReadySeconds：可选参数，指定新创建的Pod在没有任何容器崩溃的情况下视为Ready最小的秒数，默认为0，即一旦被创建就视为可用。
# 滚动更新的策略：
# .spec.strategy.type：更新deployment的方式，默认是RollingUpdate
# RollingUpdate：滚动更新，可以指定maxSurge和maxUnavailable
# maxUnavailable：指定在回滚或更新时最大不可用的Pod的数量，可选字段，默认25%，可以设置成数字或百分比，如果该值为0，那么maxSurge就不能0
# maxSurge：可以超过期望值的最大Pod数，可选字段，默认为25%，可以设置成数字或百分比，如果该值为0，那么maxUnavailable不能为0
# Recreate：重建，先删除旧的Pod，在创建新的Pod
~~~

## Deployment DaemonSet StatefulSet
1.1 有状态应用管理StatefulSet
StatefulSet（有状态集，缩写为sts）常用于部署有状态的且需要有序启动的应用程序，比如在进行SpringCloud项目容器化时，Eureka的部署是比较适合用StatefulSet部署方式的，可以给每个Eureka实例创建一个唯一且固定的标识符，并且每个Eureka实例无需配置多余的Service，其余Spring Boot应用可以直接通过Eureka的Headless Service即可进行注册。
Eureka的statefulset的资源名称是eureka，eureka-0 eureka-1 eureka-2
Service：headless service，没有ClusterIP	eureka-svc
Eureka-0.eureka-svc.NAMESPACE_NAME  eureka-1.eureka-svc …

1.1.1 StatefulSet的基本概念
StatefulSet主要用于管理有状态应用程序的工作负载API对象。比如在生产环境中，可以部署ElasticSearch集群、MongoDB集群或者需要持久化的RabbitMQ集群、Redis集群、Kafka集群和ZooKeeper集群等。
和Deployment类似，一个StatefulSet也同样管理着基于相同容器规范的Pod。不同的是，StatefulSet为每个Pod维护了一个粘性标识。这些Pod是根据相同的规范创建的，但是不可互换，每个Pod都有一个持久的标识符，在重新调度时也会保留，一般格式为StatefulSetName-Number。比如定义一个名字是Redis-Sentinel的StatefulSet，指定创建三个Pod，那么创建出来的Pod名字就为Redis-Sentinel-0、Redis-Sentinel-1、Redis-Sentinel-2。而StatefulSet创建的Pod一般使用Headless Service（无头服务）进行通信，和普通的Service的区别在于Headless Service没有ClusterIP，它使用的是Endpoint进行互相通信，Headless一般的格式为：
statefulSetName-{0..N-1}.serviceName.namespace.svc.cluster.local。
说明：
serviceName为Headless Service的名字，创建StatefulSet时，必须指定Headless Service名称；
0..N-1为Pod所在的序号，从0开始到N-1；
statefulSetName为StatefulSet的名字；
namespace为服务所在的命名空间；
.cluster.local为Cluster Domain（集群域）。
假如公司某个项目需要在Kubernetes中部署一个主从模式的Redis，此时使用StatefulSet部署就极为合适，因为StatefulSet启动时，只有当前一个容器完全启动时，后一个容器才会被调度，并且每个容器的标识符是固定的，那么就可以通过标识符来断定当前Pod的角色。
比如用一个名为redis-ms的StatefulSet部署主从架构的Redis，第一个容器启动时，它的标识符为redis-ms-0，并且Pod内主机名也为redis-ms-0，此时就可以根据主机名来判断，当主机名为redis-ms-0的容器作为Redis的主节点，其余从节点，那么Slave连接Master主机配置就可以使用不会更改的Master的Headless Service，此时Redis从节点（Slave）配置文件如下：
~~~powershell
port 6379
slaveof redis-ms-0.redis-ms.public-service.svc.cluster.local 6379
tcp-backlog 511
timeout 0
tcp-keepalive 0
~~~
其中redis-ms-0.redis-ms.public-service.svc.cluster.local是Redis Master的Headless Service，在同一命名空间下只需要写redis-ms-0.redis-ms即可，后面的public-service.svc.cluster.local可以省略。

1.1.2 StatefulSet注意事项
一般StatefulSet用于有以下一个或者多个需求的应用程序：
需要稳定的独一无二的网络标识符。
需要持久化数据。
需要有序的、优雅的部署和扩展。
需要有序的自动滚动更新。
如果应用程序不需要任何稳定的标识符或者有序的部署、删除或者扩展，应该使用无状态的控制器部署应用程序，比如Deployment或者ReplicaSet。

StatefulSet是Kubernetes 1.9版本之前的beta资源，在1.5版本之前的任何Kubernetes版本都没有。
Pod所用的存储必须由PersistentVolume Provisioner（持久化卷配置器）根据请求配置StorageClass，或者由管理员预先配置，当然也可以不配置存储。
为了确保数据安全，删除和缩放StatefulSet不会删除与StatefulSet关联的卷，可以手动选择性地删除PVC和PV（关于PV和PVC请参考2.2.12节）。
StatefulSet目前使用Headless Service（无头服务）负责Pod的网络身份和通信，需要提前创建此服务。
删除一个StatefulSet时，不保证对Pod的终止，要在StatefulSet中实现Pod的有序和正常终止，可以在删除之前将StatefulSet的副本缩减为0


kind: Service定义了一个名字为Nginx的Headless Service，创建的Service格式为nginx-0.nginx.default.svc.cluster.local，其他的类似，因为没有指定Namespace（命名空间），所以默认部署在default。

kind: StatefulSet定义了一个名字为web的StatefulSet，replicas表示部署Pod的副本数，本实例为2。
在StatefulSet中必须设置Pod选择器（.spec.selector）用来匹配其标签（.spec.template.metadata.labels）。在1.8版本之前，如果未配置该字段（.spec.selector），将被设置为默认值，在1.8版本之后，如果未指定匹配Pod Selector，则会导致StatefulSet创建错误。
当StatefulSet控制器创建Pod时，它会添加一个标签statefulset.kubernetes.io/pod-name，该标签的值为Pod的名称，用于匹配Service

## DaemonSet
DaemonSet：守护进程集，缩写为ds，在所有节点或者是匹配的节点上都部署一个Pod。
使用DaemonSet的场景
- 运行集群存储的daemon，比如ceph或者glusterd
- 节点的CNI网络插件，calico
- 节点日志的收集：fluentd或者是filebeat
- 节点的监控：node exporter
- 服务暴露：部署一个ingress nginx
~~~powershell

# 创建一个ds 更新策略建议使用OnDelete
kubectl create -f nginx-ds.yaml
kubectl get po -owide
kubectl label node k8s-work1 k8s-work2 ds=true
kubectl get node --show-labels
vim nginx-ds.yaml
kubectl replace -f nginx-ds.yaml
kubectl get po
kubectl get po -owide
kubectl rollout history ds nginx
kubectl label node k8s-master3 ds=true
~~~

## HPA
Horizontal Pod Autoscaler：Pod的水平自动伸缩器。观察Pod的CPU、内存使用率自动扩展或缩容Pod的数量。不适用于无法缩放的对象，比如DaemonSet
CPU、内存
自定义指标的扩缩容。

必须定义 Requests参数，必须安装metrics-server。
~~~powershell
kubectl autoscale deploy demo-nginx --cpu-percent=20 --min=2 --max=5
~~~


## ConfigMap
- [ConfigMap中文地址](https://kubernetes.io/zh/docs/tasks/configure-pod-container/configure-pod-configmap/)

> ConfigMap：
一般用ConfigMap去管理一些配置文件、或者一些大量的环境变量信息。

ConfigMap将配置和Pod分开，有一个nginx，nginx.conf -> configmap,nginx 
更易于配置文件的更改和管理。

~~~powershell
# 创建本地目录
mkdir -p configure-pod-container/configmap/

# 将示例文件下载到 `configure-pod-container/configmap/` 目录
wget https://kubernetes.io/examples/configmap/game.properties -O configure-pod-container/configmap/game.properties
wget https://kubernetes.io/examples/configmap/ui.properties -O configure-pod-container/configmap/ui.properties

# 创建 configmap
kubectl create configmap game-config --from-file=configure-pod-container/configmap/
kubectl describe configmaps game-config

# subpath使用
kubectl create cm nginx-conf --from-file=nginx.conf --dry-run -oyaml | kubectl replace -f - 
~~~

## Secret：Secret更倾向于存储和共享敏感、加密的配置信息
- [Secret](https://kubernetes.io/docs/concepts/configuration/secret/)
~~~powershell
echo -n 'admin' > ./username.txt
echo -n 'S!B\*d$zDsb=' > ./password.txt

kubectl create secret generic db-user-pass \
    --from-file=./username.txt \
    --from-file=./password.txt

kubectl get secrets
kubectl describe secret db-user-pass
kubectl get secret db-user-pass -o jsonpath='{.data}'
echo 'UyFCXCpkJHpEc2I9' | base64 --decode
kubectl edit secrets db-user-pass
kubectl delete secret db-user-pass
~~~

## Label和 Selector
~~~powershell
kubectl label node k8s-node02 region=subnet7
kubectl get no -l region=subnet7
kubectl label svc canary-v1 -n canary-production env=canary version=v1
kubectl label svc canary-v1 -n canary-production env=canary version=v1
kubectl get svc --all-namespaces -l version=v1
kubectl get svc --show-labels
kubectl get svc -l  'app in (details, productpage)' --show-labels
kubectl get svc -l  version!=v1,'app in (details, productpage)' --show-labels
kubectl get svc -l  version!=v1,'app in (details, productpage)' --show-labels

# 修改标签（Label）
kubectl get svc -l  version!=v1,'app in (details, productpage)' --show-labels
kubectl get svc -n canary-production --show-labels
kubectl label svc canary-v1 -n canary-production version=v2 --overwrite
kubectl get svc -n canary-production --show-labels

# 删除标签（Label）
kubectl label svc canary-v1 -n canary-production version-
kubectl get svc -n canary-production --show-labels
~~~

## Service Ingress
使用Pod IP 访问应用的问题：

Service：主要用于Pod之间的通信，相对于Pod的IP它创建完成以后就是不变的资源。Namespace级别的隔离。

最常用的service
~~~powershell
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: demo-nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      name: http
~~~

Service的类型：
	ClusterIP：在集群内部使用的，默认类型
	NodePort：在每个宿主机上暴露一个随机端口，30000-32767，--service-node-port-range，集群外部可访问。
	LoadBalancer：使用云服务商提供的IP地址。成本太高。
	ExternalName：反代到指定的域名上。
	
没有Selector的service。不会自动创建EndPoints。
192.168.1.100 3306  没有selector的service的名字+端口进行访问到192.168.1.100 3306。

ClusterIP+Ingress  域名访问
Ingress：
	它是Kubernetes集群中服务的入口，可以提供负载均衡、SSL终止和基于域名的虚拟主机。Treafik、Nginx、HAProxy、Istio。


Ingress 官方文档：https://kubernetes.io/docs/concepts/services-networking/ingress/

Ingress-Nginx安装文档：https://kubernetes.github.io/ingress-nginx/deploy/

Ingress-Nginx 文档：https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/


- [ingress-nginx](https://kubernetes.github.io/ingress-nginx/)
- [helm](https://helm.sh/)
~~~powershell
tar -zxvf helm-v3.10.3-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
helm help

helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo list 
helm search repo ingress-nginx

# 配置安装
helm pull ingress-nginx/ingress-nginx
# https://github.com/kubernetes/ingress-nginx/releases/download/helm-chart-4.4.2/ingress-nginx-4.4.2.tgz

# minyi/ingress-nginx-controller
# values.yml 配置
registry: registry.hub.docker.com # registry.k8s.io
image: minyi/ingress-nginx-controller # ingress-nginx/controller
dnsPolicy: ClusterFirstWithHostNet
hostNetwork: true
kind: DaemonSet
nodeSelector:
    kubernetes.io/os: linux
    ingress: "true"
type: ClusterIP #LoadBalancer
image: minyi/kube-webhook-certgen # ingress-nginx/kube-webhook-certgen

# 当前文件下安装
kubectl label node k8s-master3 ingress=true
kubectl create ns ingress-nginx 
helm install ingress-nginx -n ingress-nginx .
~~~

Ingress：https://kubernetes.io/docs/concepts/services-networking/ingress/

~~~powershell
helm install ingress-nginx -n ingress-nginx .
NAME: ingress-nginx
LAST DEPLOYED: Fri Jan  6 17:58:02 2023
NAMESPACE: ingress-nginx
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The ingress-nginx controller has been installed.
Get the application URL by running these commands:
  export POD_NAME=$(kubectl --namespace ingress-nginx get pods -o jsonpath="{.items[0].metadata.name}" -l "app=ingress-nginx,component=controller,release=ingress-nginx")
  kubectl --namespace ingress-nginx port-forward $POD_NAME 8080:80
  echo "Visit http://127.0.0.1:8080 to access your application."

An example Ingress that makes use of the controller:
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: example
    namespace: foo
  spec:
    ingressClassName: nginx
    rules:
      - host: www.example.com
        http:
          paths:
            - pathType: Prefix
              backend:
                service:
                  name: exampleService
                  port:
                    number: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
      - hosts:
        - www.example.com
        secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls
~~~

定义一个Ingress：
~~~powershell
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: simple-fanout-example
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: foo.bar.com
    http:
      paths:
      - path: /foo
        backend:
          serviceName: service1
          servicePort: 4200
      - path: /bar
        backend:
          serviceName: service2
          servicePort: 8080
~~~
host: 可选参数，一般都会配置我们自己的域名。
path: 一个路径对应一个serviceName和一个Port
backend: path对应的后端是谁。
foo.bar.com/foo  service1:4200

~~~powershell
get pod -n ingress-nginx
kubectl exec -it ingress-nginx-controller-hr29v -n ingress-nginx -- bash
~~~


## Volumes

Container（容器）中的磁盘文件是短暂的，当容器崩溃时，kubelet会重新启动容器，但最初的文件将丢失，Container会以最干净的状态启动。另外，当一个Pod运行多个Container时，各个容器可能需要共享一些文件。Kubernetes Volume可以解决这两个问题。
一些需要持久化数据的程序才会用到Volumes，或者一些需要共享数据的容器需要volumes。
Redis-Cluster：nodes.conf
日志收集的需求：需要在应用程序的容器里面加一个sidecar，这个容器是一个收集日志的容器，比如filebeat，它通过volumes共享应用程序的日志文件目录。
Volumes：官方文档https://kubernetes.io/docs/concepts/storage/volumes/
1. 背景
Docker也有卷的概念，但是在Docker中卷只是磁盘上或另一个Container中的目录，其生命周期不受管理。虽然目前Docker已经提供了卷驱动程序，但是功能非常有限，例如从Docker 1.7版本开始，每个Container只允许一个卷驱动程序，并且无法将参数传递给卷。
另一方面，Kubernetes卷具有明确的生命周期，与使用它的Pod相同。因此，在Kubernetes中的卷可以比Pod中运行的任何Container都长，并且可以在Container重启或者销毁之后保留数据。Kubernetes支持多种类型的卷，Pod可以同时使用任意数量的卷。
从本质上讲，卷只是一个目录，可能包含一些数据，Pod中的容器可以访问它。要使用卷Pod需要通过.spec.volumes字段指定为Pod提供的卷，以及使用.spec.containers.volumeMounts 字段指定卷挂载的目录。从容器中的进程可以看到由Docker镜像和卷组成的文件系统视图，卷无法挂载其他卷或具有到其他卷的硬链接，Pod中的每个Container必须独立指定每个卷的挂载位置。
1.1.1 emptyDir
和上述volume不同的是，如果删除Pod，emptyDir卷中的数据也将被删除，一般emptyDir卷用于Pod中的不同Container共享数据。它可以被挂载到相同或不同的路径上。
默认情况下，emptyDir卷支持节点上的任何介质，可能是SSD、磁盘或网络存储，具体取决于自身的环境。可以将emptyDir.medium字段设置为Memory，让Kubernetes使用tmpfs（内存支持的文件系统），虽然tmpfs非常快，但是tmpfs在节点重启时，数据同样会被清除，并且设置的大小会被计入到Container的内存限制当中。
使用emptyDir卷的示例，直接指定emptyDir为{}即可：


hostPath卷常用的type（类型）如下：
- type为空字符串：默认选项，意味着挂载hostPath卷之前不会执行任何检查。
- DirectoryOrCreate：如果给定的path不存在任何东西，那么将根据需要创建一个权限为0755的空目录，和Kubelet具有相同的组和权限。
- Directory：目录必须存在于给定的路径下。
- FileOrCreate：如果给定的路径不存储任何内容，则会根据需要创建一个空文件，权限设置为0644，和Kubelet具有相同的组和所有权。
- File：文件，必须存在于给定路径中。
- Socket：UNIX套接字，必须存在于给定路径中。
- CharDevice：字符设备，必须存在于给定路径中。
- BlockDevice：块设备，必须存在于给定路径中。

> Exporter配置
~~~powershell
/data/nfs/ 192.168.0.0/24(rw,sync,no_subtree_check,no_root_squash)
~~~

Volume：NFS、CEPH、GFS
PersistentVolume：NFS、CEPG/GFS

## PV、PVC
PV：由k8s配置的存储，PV同样是集群的一类资源，yaml。

PVC：对PV的申请，
PersistentVolumeClaim

PV文档：https://kubernetes.io/docs/concepts/storage/persistent-volumes/

Nfs类型的PV：
~~~powershell
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv0003
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  storageClassName: slow
  mountOptions:
    - hard
    - nfsvers=4.1
  nfs:
    path: /tmp
    server: 172.17.0.2

# persistentVolumeReclaimPolicy：
# 	Recycle: 回收，rm -rf
# 		Deployment -> PVC  PV, Recycle。
# 	Retain：保留。
# 	Delete：PVC –-> PV,删除PVC后PV也会被删掉，这一类的PV，需要支持删除的功能，动态存储默认方式。

# Capacity：PV的容量。
# volumeMode：挂载的类型，Filesystem，block

# accessModes：这个的PV访问模式：
# 	ReadWriteOnce：RWO，可以被单节点以读写的模式挂载。
# 	ReadWriteMany：RWX，可以被多节点以读写的形式挂载。
# 	ReadOnlyMany：ROX，可以被多个节点以只读的形式挂载。
# storageClassName：PV的类，可以说是一个类名，PVC和PV的这个名字一样，才能被绑定。

# Pv的状态：
# 	Available：空闲的PV，没有被任何PVC绑定。
# 	Bound：已经被PVC绑定
# 	Released：PVC被删除，但是资源未被重新使用
# 	Failed：自动回收失败。
~~~


> 很多情况下：
创建PVC之后，一直绑定不上PV（Pending）：
1. PVC的空间申请大小大于PV的大小
2. PVC的StorageClassName没有和PV的一致
3. PVC的accessModes和PV的不一致

创建挂载了PVC的Pod之后，一直处于Pending状态：
1. PVC没有被创建成功，或者被创建
2. PVC和Pod不在同一个Namespace

删除PVC后k8s会创建一个用于回收的Pod根据PV的回收策略进行pv的回收回收完以后PV的状态就会变成可被绑定的状态也就是空闲状态其他的Pending状态的PVC如果匹配到了这个PV，他就能和这个PV进行绑定。

## cornjob
CronJob：在k8s里面运行周期性的计划任务，crontab。
- * * * * * 分时日月周
- 需要调用应用的接口。
- 需要依赖某些环境。
- php xxx,直接用php项目的镜像进行执行计划任务。
- php-wordpress:v1.0.1
- CronJob被调用的时间，是用的controller-manager的时间。


创建一个CronJob：
~~~powershell
kubectl run hello --schedule="*/2 * * * *" --restart=OnFailure --image=nginx --image-pull-policy=IfNotPresent -- /bin/sh -c "date"

kubectl run --generator=cronjob/v1 is DEPRECATED and will be removed in a future version. Use kubectl run --generator=run-pod/v1 or kubectl create instead.

kubectl get cj
kubectl get cj hello -oyaml
~~~

## Taint&Toleration：
1. 在不同的机房
2. 在不同的城市
3. 有着不一样配置
a) GPU服务器
b) 纯固态硬盘的服务器

1. NodeSelect：
a)Gpu-server：true
b)Ssd-server：true
c)Normal-server：true

污点和容忍的理念：
	Taint在一类服务器上打上污点，让不能容忍这个污点的Pod不能部署在打了污点的服务器上。
	Master节点不应该部署系统Pod之外的任何Pod。
	每个节点可以打很多个污点。
~~~powershell
GPU： gpu-server: true
~~~

给一个节点打一个污点：
~~~powershell
kubectl taint node k8s-master01 master-test=test:NoSchedule
~~~powershell

~~~powershell
# NoSchedule：禁止调度
# NoExecute：如果不符合这个污点，会立马被驱逐
# PreferNoSchedule: 尽量避免将Pod调度到指定的节点上。

tolerations:
- effect: NoSchedule
key: master-test
operator: Equal
value: test

# Node节点有多个Taint，每个Taint都需要容忍才能部署上去。
tolerations:
- effect: NoSchedule
key: master-test
operator: Exists

tolerations:
- operator: Exists

tolerations:
- operator: Exists
key: master-test

# node.kubernetes.io/not-ready: 节点没有准备好，Ready不为true
~~~

> InitContainer：
初始化容器：在我应用容器启动之前做的一些舒适化操作。

postStart：在容器启动之前做一些操作。不能保证在你的container的EntryPoint


> Affinity：亲和力。
- NodeAffinity：节点亲和力，
- RequiredDuringSchedulingIgnoredDuringExecution：硬亲和力，即支持必须部署在指定的节点上，也支持必须不部署在指定的节点上。a=b
- PreferredDuringSchedulingIgnoredDuringExecution：软亲和力，尽量部署在满足条件的节点上，或者是尽量不要部署在被匹配的节点。

- PodAffinity：Pod亲和力
- A应用B应用C应用，将A应用根据某种策略尽量或者部署在一块。Label
- A：app=a  B：app=b
- RequiredDuringSchedulingIgnoredDuringExecution：
- 将A应用和B应用部署在一块
- PreferredDuringSchedulingIgnoredDuringExecution：
- 尽量将A应用和B应用部署在一块
- PodAntiAffinity：Pod反亲和力
- A应用B应用C应用，将A应用根据某种策略尽量或不部署在一块。Label
- RequiredDuringSchedulingIgnoredDuringExecution：
- 不要将A应用与与之匹配的应用部署在一块
- PreferredDuringSchedulingIgnoredDuringExecution
- 尽量。。。


- In：部署在满足多个条件的节点上
- NotIn：不要部署在满足这些条件的节点上
- Exists：部署在具有某个存在key为指定的值的Node节点上
- DoesNotExist：和Exists相反
- Gt： 大于指定的条件  条件为number，不能为字符串
- Lt：小于指定的条件

~~~powershell
topologyKey: kubernetes.io/hostname 
# topologyKey：拓扑域，首先说明一点不同的key不同的value是属于不同的拓扑域。

affinity:
    podAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
            - key: k8s-app
            operator: In
            values:
            - calico-kube-controllers
# 如果写了namespaces的字段，但是留空，他是匹配所有namespace下的指定label的Pod，如果写了namespace并且指定了值，就是匹配指定namespace下的指定label的Pod。如果没有写namespace，匹配当前namespace
# namespaces:
namespaces:
    - kube-system
topologyKey: kubernetes.io/hostname 

kube-systemk8s-app=calico-kube-controllers

affinity:
    podAntiAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
        - podAffinityTerm:
            labelSelector:
            matchExpressions:
            - key: app
                operator: In
                values:
                - demo-nginx
            topologyKey: jigui
        weight: 1
~~~

## RBAC：基于角色的访问控制，Role-Based Access Control。他是一种基于企业内个人角色来管理一些资源的访问方法。

Jenkins使用基于角色的用户权限管理。

RBAC：4中顶级资源，Role、ClusterRole、RoleBinding、ClusterRoleBinding。

Role：角色，包含一组权限的规则。没有拒绝规则，只是附加允许。Namespace隔离，只作用于命名空间内。
ClusterRole：和Role的区别，Role是只作用于命名空间内，作用于整个集群。

RoleBinding：作用于命令空间内，将ClusterRole或者Role绑定到User、Group、ServiceAccount。
ClusterRoleBinding：作用于整个集群。

ServiceAccount、User、Group。
Basic-auth-file


~~~powershell
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  # "namespace" omitted since ClusterRoles are not namespaced
  name: secret-reader
  labels:
     self-cluster-role: test
rules:
- apiGroups: [""]
  #
  # at the HTTP level, the name of the resource for accessing Secret
  # objects is "secrets"
  resources: ["secrets"]
  verbs: ["get", "watch", "list"]

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring
aggregationRule:
  clusterRoleSelectors:
  - matchLabels:
      self-cluster-role: test
rules: [] # The control plane automatically fills in the rules
~~~

https://kubernetes.io/docs/reference/access-authn-authz/rbac/


基于用户名密码实现不同用户有不同的权限
基于ServiceAccount实现不同的SA有不同的权限
~~~powershell
- --authentication-mode=basic,token
- --token-ttl=86400
~~~

注意：k8s 1.18+后可以直接使用kubectl alpha debug使用临时容器（也需要开启feature），比如启动一个session直接进行调试：
kubectl alpha debug alpine-85949985b6-qqztl -i --image=busybox
或者给某个pod加上一个临时容器，名字叫debugger：
kubectl alpha debug --image=myproj/debug-tools -c debugger mypod

临时容器：1.16+
就是在原有的Pod上，添加一个临时的Container，这个Container可以包含我们排查问题所有的工具，netstat、ps、top，jstat、jmap。
~~~powershell
--feature-gates=EphemeralContainers=true \
~~~

~~~powershell
{
    "apiVersion": "v1",
    "kind": "EphemeralContainers",
    "metadata": {
            "name": "demo-nginx-xxx"
    },
    "ephemeralContainers": [{
        "command": [
            "sh"
        ],
        "image": "busybox",
        "imagePullPolicy": "IfNotPresent",
        "name": "debugger",
        "stdin": true,
        "tty": true,
        "terminationMessagePolicy": "File"
    }]
}
~~~

~~~powershell
kubectl replace --raw /api/v1/namespaces/default/pods/demo-nginx-xxx/ephemeralcontainers  -f ec.json
{"kind":"EphemeralContainers","apiVersion":"v1","metadata":{"name":"demo-nginx-xxx","namespace":"default","selfLink":"/api/v1/namespaces/default/pods/demo-nginx-xxx/ephemeralcontainers","uid":"32d8ddda-1dfd-487a-aa83-40f1c1bf89ee","resourceVersion":"4345959","creationTimestamp":"2020-03-25T15:34:26Z"},"ephemeralContainers":[{"name":"debugger","image":"busybox","command":["sh"],"resources":{},"terminationMessagePolicy":"File","imagePullPolicy":"IfNotPresent","stdin":true,"tty":true}]}
~~~

文档地址：https://kubernetes.io/docs/concepts/workloads/pods/ephemeral-containers/


DaemonSet需要单独配置：shareProcessNamespace
Deployment不需要单独配置。
StatefulSet



