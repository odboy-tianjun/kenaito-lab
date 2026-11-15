# 编译阶段：compile-node22（Vite 7 需要 Node >= 20.19）
FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-node22 AS build
WORKDIR /src

COPY package.json package-lock.json* ./
# npm 源由镜像的 /usr/local/node/etc/npmrc 指向 npmmirror，无需额外换源
RUN npm install --no-audit --no-fund

COPY . ./
RUN npm run build && ls -lh dist/ dist/assets/

# 运行阶段：Tengine 3.1.0（自建 proxy-tengine3 镜像）托管静态文件
FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:proxy-tengine3 AS runtime
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
# 站点配置与构建产物都放进镜像：conf.d/*.conf 由主配置 include，html/ 为站点根目录
COPY nginx/node-frontend-react-class.conf /usr/local/nginx/conf/conf.d/node-frontend-react-class.conf
COPY --from=build /src/dist/ /usr/local/nginx/html/
# 构建期自检：配置语法错误直接让镜像构建失败；纯静态站点没有上游主机名，nginx -t 可直接通过
RUN /usr/local/nginx/sbin/nginx -t -c /usr/local/nginx/conf/nginx.conf
EXPOSE 80
STOPSIGNAL SIGQUIT
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
