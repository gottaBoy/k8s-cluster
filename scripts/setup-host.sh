#!/bin/bash

# 主机与IP地址解析
cat >> /etc/hosts << EOF
192.168.10.10 ha1
192.168.10.11 ha2
192.168.10.12 k8s-master1
192.168.10.13 k8s-master2
192.168.10.14 k8s-master3
192.168.10.15 k8s-worker1
192.168.10.16 k8s-worker2
EOF

