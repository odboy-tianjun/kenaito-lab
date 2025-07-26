# 编译阶段：仅用于构建 Python，构建工具链不进入最终镜像
FROM alibaba-cloud-linux-3-registry.cn-hangzhou.cr.aliyuncs.com/alinux3/alinux3:220901.1 AS builder
ENV TimeZone=Asia/Shanghai
ENV PYTHON_HOME=/usr/local/python3
WORKDIR /home/admin

ADD https://www.python.org/ftp/python/3.10.0/Python-3.10.0.tgz ./
RUN yum install \
    libffi-devel \
    zlib-devel \
    bzip2-devel \
    openssl-devel \
    ncurses-devel \
    sqlite-devel \
    readline-devel \
    tk-devel \
    gdbm-devel \
    libpcap-devel \
    xz-devel \
    make \
    patch \
    gcc \
    tar -y; \
    tar -xvf Python-3.10.0.tgz; \
    cd Python-3.10.0; \
    ./configure --prefix=/usr/local/python3; \
    make && make install; \
    python3 -V

# 运行阶段：仅保留 Python 运行时
FROM alibaba-cloud-linux-3-registry.cn-hangzhou.cr.aliyuncs.com/alinux3/alinux3:220901.1
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
ENV PYTHON_HOME=/usr/local/python3
ENV PATH="${PYTHON_HOME}/bin:$PATH"
WORKDIR /home/admin

RUN yum update -y && yum clean all; \
    rm -rf /usr/lib/python3.6;

COPY --from=builder /usr/local/python3 /usr/local/python3
# COPY 的目标目录不存在时会当成文件创建，需先建好 ~/.pip
RUN mkdir ~/.pip
COPY pip.conf ~/.pip/

RUN python3 -V; pip3 -V
