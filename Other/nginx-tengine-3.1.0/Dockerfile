FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:alinux3-update20261111
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
ENV TENGINE_VERSION=3.1.0
ENV NGINX_HOME=/usr/local/nginx
ENV PATH="${NGINX_HOME}/sbin:$PATH"
WORKDIR /home/admin
# https://tengine.taobao.org/download/tengine-3.1.0.tar.gz
ADD https://tengine.taobao.org/download/tengine-${TENGINE_VERSION}.tar.gz ./
RUN yum install \
    gcc \
    gcc-c++ \
    make \
    tar \
    pcre-devel \
    zlib-devel \
    openssl-devel \
    libxml2-devel \
    libxslt-devel \
    gd-devel \
    geoip-devel \
    sysstat \
    net-tools -y; \
    tar -xzvf tengine-${TENGINE_VERSION}.tar.gz; \
    cd tengine-${TENGINE_VERSION}; \
    ./configure \
    --prefix=${NGINX_HOME} \
    --with-http_stub_status_module \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_gzip_static_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_geoip_module \
    --with-http_xslt_module \
    --with-http_image_filter_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    --with-pcre-jit; \
    make && make install; \
    mkdir -p ${NGINX_HOME}/conf/ssl ${NGINX_HOME}/conf/conf.d; \
    nginx -V; \
    rm -rf /home/admin/tengine-${TENGINE_VERSION} /home/admin/tengine-${TENGINE_VERSION}.tar.gz

# tengine 默认以 nobody 用户运行 worker 进程，root 启动后自动降权，可直接监听 80/443
EXPOSE 80 443
STOPSIGNAL SIGQUIT
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
