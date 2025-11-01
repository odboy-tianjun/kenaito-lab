# 使用示例

用 `image/` 下的自建镜像构建、部署应用的完整示例。每个示例目录都是独立可运行的项目（含 Dockerfile、构建与部署脚本、说明文档），
不参与 `image/` 镜像本身的构建，可以直接拷贝出去改造。

| 示例                                     | 使用的镜像                                        | 说明                                                      |
|----------------------------------------|----------------------------------------------|---------------------------------------------------------|
| [dotnet6](dotnet6/run.md)              | `compile-dotnet6` → `runtime-dotnet6`        | .NET 6 Web API，两阶段构建：编译镜像出产物、运行镜像只带运行时；含 compose 部署与健康检查 |

## 运行方式

以 dotnet6 为例（每个示例的 `run.md` 有完整说明）：

```shell
cd demo/dotnet6
sh build.sh        # 构建示例镜像
sh install.sh      # 启动
sh shutdown.sh     # 停止
```

## 约定

- 示例镜像统一推送到 `registry.cn-shanghai.aliyuncs.com/odboy/kenaito:demo-<名称>`，与 `image/` 的自建镜像区分开
- 示例所用基础镜像需先按 `image/<目录>/build.sh` 构建并推送
- 部署示例默认使用 compose，端口与 `app/` 中的部署编排错开（如 dotnet6 用 8080）
