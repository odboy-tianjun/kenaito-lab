#FROM alibaba-cloud-linux-3-registry.cn-hangzhou.cr.aliyuncs.com/alinux3/alinux3:220901.1
FROM alibaba-cloud-linux-3-registry.cn-hangzhou.cr.aliyuncs.com/alinux3/alinux3:3.13.3
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
WORKDIR /home/admin

# 升级会有很多问题，比如nginx编译失败等
#RUN yum update -y && yum clean all;

# 全局锁 releasever=8
RUN mkdir -p /etc/dnf/vars && echo 8 > /etc/dnf/vars/releasever

# 删除原有全部repo，手写 Anolis 8 阿里云源
RUN rm -rf /etc/yum.repos.d/* && \
cat > /etc/yum.repos.d/anolis-base.repo <<'EOF'
[anolis-BaseOS]
name=Anolis 8 BaseOS
baseurl=https://mirrors.aliyun.com/anolis/8/BaseOS/$basearch/os/
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/anolis/RPM-GPG-KEY-Anolis-8
enabled=1

[anolis-AppStream]
name=Anolis 8 AppStream
baseurl=https://mirrors.aliyun.com/anolis/8/AppStream/$basearch/os/
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/anolis/RPM-GPG-KEY-Anolis-8
enabled=1
EOF

# ========== 修复后的 EPEL8（重点：加 Everything） ==========
RUN cat > /etc/yum.repos.d/epel.repo <<'EOF'
[epel]
name=Extra Packages for Enterprise Linux 8
baseurl=https://mirrors.aliyun.com/epel/8/Everything/$basearch
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/epel/RPM-GPG-KEY-EPEL-8
enabled=1
EOF

# dnf 调优
RUN echo -e "max_parallel_downloads=10\nmetadata_expire=3600\nmetadata_timer_sync=0\ndeltarpm=False\ntimeout=15\nminrate=200k" >> /etc/dnf/dnf.conf

# 缓存
RUN dnf clean all && dnf makecache