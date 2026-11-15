# 编译阶段：compile-node22（npm 源由镜像的 /usr/local/node/etc/npmrc 指向 npmmirror）
FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-node22 AS build
WORKDIR /src

COPY package.json package-lock.json* ./
# 本示例没有第三方依赖：package.json 里 devDependencies/dependencies 都为空时 npm 不会生成 node_modules，
# 此时跳过安装，避免后续 COPY 失败；真实项目加了依赖后这一步会自动生效
RUN if grep -qE '"dependencies"|"devDependencies"' package.json; then \
      npm install --omit=dev --no-audit --no-fund; \
    else \
      echo "no dependencies declared, skip npm install"; \
    fi

COPY server.js ./
# 构建期自检：语法错误在构建阶段就失败，而不是等容器启动
RUN node --check server.js

# 运行阶段：runtime-node22（仅 Node 运行时，不含 npm 安装能力）
FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-node22 AS runtime
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
ENV APP_PORT=8087
ENV NODE_ENV=production
WORKDIR /home/admin
# 有依赖时 node_modules 会一起拷进运行镜像；无依赖时只拷源码
COPY --from=build /src/package.json ./
COPY --from=build /src/node_modules* ./
COPY --from=build /src/server.js ./
EXPOSE 8087
# exec 形式：node 作为 PID 1 接收 SIGTERM，server.js 里做了优雅关闭
ENTRYPOINT ["node", "/home/admin/server.js"]
