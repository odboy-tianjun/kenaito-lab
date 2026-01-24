FROM alibaba-cloud-linux-3-registry.cn-hangzhou.cr.aliyuncs.com/alinux3/alinux3:3.13.3
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
WORKDIR /home/admin

# 升级会有很多问题，比如nginx编译失败等
#RUN yum update -y && yum clean all;

# 时区
RUN ln -snf /usr/share/zoneinfo/$TimeZone /etc/localtime && echo $TimeZone > /etc/timezone

# $releasever 显式锁定 3，避免从其他地方解析错版本导致路径 404
RUN mkdir -p /etc/dnf/vars && echo 3 > /etc/dnf/vars/releasever

# 镜像内自带源指向内网域名 mirrors.cloud.aliyuncs.com，这里替换为公网 ali yun 源
RUN sed -i 's/mirrors.cloud.aliyuncs.com/mirrors.aliyun.com/g' /etc/yum.repos.d/*.repo && \
    grep -rl 'mirrors.aliyun.com' /etc/yum.repos.d/*.repo >/dev/null

# dnf 调优
RUN printf '%s\n' \
    'max_parallel_downloads=10' \
    'metadata_expire=3600' \
    'metadata_timer_sync=0' \
    'deltarpm=False' \
    'timeout=30' \
    'minrate=200k' >> /etc/dnf/dnf.conf

# 预制缓存，打进镜像
RUN dnf clean all && dnf makecache
