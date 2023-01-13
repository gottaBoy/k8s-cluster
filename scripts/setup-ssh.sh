#!/bin/bash

# 配置免密登录
ssh-keygen
ssh-copy-id root@k8s-master1
ssh-copy-id root@k8s-master2
ssh-copy-id root@k8s-master3
ssh-copy-id root@k8s-worker1
ssh-copy-id root@k8s-worker2

# ssh root@k8s-master1
