FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:system-alinux4
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
ENV TENGINE_VERSION=3.1.0
ENV NGINX_HOME=/usr/local/nginx
ENV PATH="${NGINX_HOME}/sbin:$PATH"
WORKDIR /home/admin
# 使用自定义配置覆盖默认可映射的目录：conf/nginx.conf、conf/conf.d、conf/ssl
COPY nginx.conf ${NGINX_HOME}/conf/nginx.conf
# https://tengine.taobao.org/download/tengine-3.1.0.tar.gz
# 由 build.sh 预先下载到本目录
ADD tengine-${TENGINE_VERSION}.tar.gz ./
# gcc/gcc-c++/make 用于编译 tengine；sysstat/net-tools 用于排障
RUN set -e && yum install \
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
    make; \
    make install; \
    mkdir -p ${NGINX_HOME}/conf/ssl ${NGINX_HOME}/conf/conf.d; \
    ls -l ${NGINX_HOME}/sbin; \
    ${NGINX_HOME}/sbin/nginx -t -c ${NGINX_HOME}/conf/nginx.conf; \
    rm -rf /home/admin/tengine-${TENGINE_VERSION}

# tengine 默认以 nobody 用户运行 worker 进程，root 启动后自动降权，可直接监听 80/443
EXPOSE 80 443
STOPSIGNAL SIGQUIT
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
