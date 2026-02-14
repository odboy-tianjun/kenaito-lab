FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:system-alinux3
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
ENV PYTHON_HOME=/usr/local/python3
ENV PATH="${PYTHON_HOME}/bin:$PATH"
WORKDIR /home/admin
# https://www.python.org/ftp/python/3.10.0/Python-3.10.0.tgz
# 由 build.sh 预先下载到本目录
ADD Python-3.10.0.tgz ./
RUN set -e && yum install \
    libffi-devel \
    zlib-devel \
    bzip2-devel \
    openssl-devel \
    ncurses-devel \
    sqlite-devel \
    readline-devel \
    xz-devel \
    make \
    gcc \
    tar \
    sysstat \
    net-tools -y; \
    cd Python-3.10.0; \
    ./configure --prefix=/usr/local/python3; \
    make && make install; \
    python3 -V; \
    cd /home/admin && rm -rf Python-3.10.0; \
    mkdir ~/.pip;
COPY pip.conf ~/.pip/