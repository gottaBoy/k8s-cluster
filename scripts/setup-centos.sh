#!/bin/bash
source "/vagrant/scripts/common.sh"

log info "Centos 基本配置" 
log info "安装 epel-release" 
# sudo rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
# sudo yum update

# cp -a /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
# wget -O /etc/yum.repos.d/CentOS-Base.repo https://repo.huaweicloud.com/repository/conf/CentOS-7-reg.repo
yum clean all
yum makecache
yum install -y -q epel-release

# 设置系统时区
log info "设置时区" 
timedatectl set-timezone Asia/Shanghai 

# ssh 设置允许密码登录
log info "设置ssh" 
sed -i 's@^PasswordAuthentication no@PasswordAuthentication yes@g' /etc/ssh/sshd_config
sed -i 's@^#PubkeyAuthentication yes@PubkeyAuthentication yes@g' /etc/ssh/sshd_config
systemctl restart sshd.service

# limit优化
ulimit -SHn 65535

log info "设置最大文件句柄数、最大线程数和最大进程数" 
# 设置最大文件句柄数和最大线程数
echo -e "* soft nofile 65536\n* hard nofile 65536\n* soft nproc 131072\n* hard nproc 131072" >> /etc/security/limits.conf

# cat <<EOF >> /etc/security/limits.conf
# * soft nofile 655360
# * hard nofile 131072
# * soft nproc 655350
# * hard nproc 655350
# * soft memlock unlimited
# * hard memlock unlimited
# EOF

# 设置进程数
sed -i 's@4096@65536@g' /etc/security/limits.d/20-nproc.conf

# 关闭防火墙
systemctl stop firewalld
systemctl disable firewalld
firewall-cmd --state

# 关闭selinux CentOS取消SELINUX 
setenforce 0
sed -i "s@^SELINUX=.*@SELINUX=disabled@g" /etc/selinux/config
sestatus

# 交换分区设置
swapoff -a
sed -ri 's/.*swap.*/#&/' /etc/fstab
echo "vm.swappiness=0" >> /etc/sysctl.conf

sysctl -p
# 虚拟内存扩容
echo "vm.max_map_count=262144" >> /etc/sysctl.conf

# 安装基本的软件：-q（不显示安装的过程）
# 高质量软件包管理
log info "安装 sshpass lrzsz expect unzip zip vim-enhanced lzop"
yum install -y -q sshpass
yum install -y -q expect 
yum install -y -q unzip 
yum install -y -q zip 
yum install -y -q vim-enhanced 
yum install -y -q lzop 
yum install -y -q dos2unix
log info "安装 nmap-ncat net-tools nc wget lsof"
yum install -y -q nmap-ncat 
yum install -y -q nc 
yum install -y -q lsof 
yum install -y -q tcpdump 
yum install -y -q ntp
yum install wget jq psmisc vim net-tools telnet yum-utils device-mapper-persistent-data lvm2 git lrzsz -y

yum -y install ipvsadm ipset sysstat conntrack libseccomp

# yum -y install ntpdate
# 制定时间同步计划任务
# crontab -e
# 0 */1 * * * ntpdate time1.aliyun.com

# 已安装(查看openssl version -a)
# yum install -y -q openssl-devel
# git升级
log info "安装 git" 
#yum remove -y  -q git
# rpm -ivh https://opensource.wandisco.com/git/wandisco-git-release-7-2.noarch.rpm
# yum install -y -q git

# 支持中文包
# yum -y -q groupinstall "fonts"
log info "安装 中文包" 
yum install -y -q glibc-common
localectl set-locale LANG=zh_CN.UTF-8

# 创建 /etc/modules-load.d/ipvs.conf 并加入以下内容： 
cat >/etc/modules-load.d/ipvs.conf <<EOF 
ip_vs 
ip_vs_lc 
ip_vs_wlc 
ip_vs_rr 
ip_vs_wrr 
ip_vs_lblc 
ip_vs_lblcr 
ip_vs_dh 
ip_vs_sh 
ip_vs_fo 
ip_vs_nq 
ip_vs_sed 
ip_vs_ftp 
ip_vs_sh 
nf_conntrack 
ip_tables 
ip_set 
xt_set 
ipt_set 
ipt_rpfilter 
ipt_REJECT 
ipip 
EOF

# 永久性加载模块
cat > /etc/modules-load.d/containerd.conf << EOF
overlay
br_netfilter
EOF

# 设置为开机启动
systemctl enable --now systemd-modules-load.service

min_version="4.18"
osname=`uname -r`
echo "os: $osname"
if [ $osname \< $min_version ];then
    echo "setup-kernel start"
    sh /vagrant/scripts/setup-kernel.sh
    echo "setup-kernel end"
fi