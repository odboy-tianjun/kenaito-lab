# 编译阶段：compile-rust（Rust 1.100 + gcc/make，crates 源走 USTC 镜像）
FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-rust AS build
WORKDIR /src

# 先只拷贝清单文件，预热依赖层；本示例无第三方依赖，有依赖时会走 CARGO_HOME 里的镜像源
COPY Cargo.toml Cargo.lock* ./
# 用单独的 target-dir 放桩产物，不要落在 /src/target：
# 否则后面的正式编译会看到“产物比源码新”而跳过重编，把桩二进制拷进运行镜像。
RUN mkdir -p src && echo 'fn main() {}' > src/main.rs \
    && cargo build --release --target-dir /tmp/deps-target \
    && rm -rf src

COPY src ./src
# 先只读离线编译，失败再回退联网（无第三方依赖时 --offline 一定成功）
RUN cargo build --release --target-dir /src/target --offline \
    || cargo build --release --target-dir /src/target

# 运行阶段：runtime-rust（rustc/cargo 运行时基础，自带 glibc）
FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-rust AS runtime
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
ENV APP_PORT=8088
WORKDIR /home/admin
COPY --from=build /src/target/release/rust-demo ./rust-demo
# 构建期自检：二进制里必须有启动日志，否则说明拷进来的是桩程序，让构建直接失败
RUN grep -q "rust demo listening on" /home/admin/rust-demo || \
    (echo "stale/stub binary copied into runtime image" >&2 && exit 1)
EXPOSE 8088
# exec 形式，示例只用标准库，不依赖 tokio；SIGTERM 由内核默认终止，无额外清理逻辑
ENTRYPOINT ["/home/admin/rust-demo"]
