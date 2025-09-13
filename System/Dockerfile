FROM alibaba-cloud-linux-3-registry.cn-hangzhou.cr.aliyuncs.com/alinux3/alinux3:220901.1
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
WORKDIR /home/admin

# 升级会有很多问题，比如nginx编译失败等
#RUN yum update -y && yum clean all;