FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-python315
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
WORKDIR /home/admin

# 锁定 ansible-core 版本，避免 EPEL 仓库升级后构建结果漂移；版本不可用会让构建直接失败
RUN set -e && yum install -y \
    epel-release \
    ansible-core-2.16.3; \
    ansible --version

COPY ./ansible/ansible.cfg /etc/ansible/ansible.cfg
COPY ./ansible/hosts /etc/ansible/hosts
