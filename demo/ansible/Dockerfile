FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-python310
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
WORKDIR /home/admin

RUN set -e && yum install -y \
    epel-release \
    ansible;