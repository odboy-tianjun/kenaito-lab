# 编译阶段：compile-go123（Go 1.23 + goproxy.cn）
FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-go123 AS build
WORKDIR /src

# 先只拷贝 go.mod / go.sum 预热依赖层；本示例只用标准库，没有 go.sum 也不影响
COPY go.mod go.sum* ./
RUN go mod download

COPY *.go ./
# 静态编译：运行镜像里不依赖 glibc 等动态库，也不必带 go 工具链
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /src/app .

# 运行阶段：runtime-go123（仅 Go 运行时）
FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-go123 AS runtime
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
ENV APP_PORT=8086
WORKDIR /home/admin
COPY --from=build /src/app ./app
EXPOSE 8086
# exec 形式，保证 docker stop 的 SIGTERM 能传到进程
ENTRYPOINT ["/home/admin/app"]
