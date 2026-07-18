# 常见语言的 .gitignore 配置参考

按语言/工具分目录，每个目录一个可直接复制到项目根目录的 `.gitignore`：

| 目录 | 适用场景 |
| --- | --- |
| `base` | 通用：操作系统、编辑器、日志、压缩包（各语言配置都会引用它） |
| `java` | Maven / Gradle 项目，含 IDE 工程文件（`.idea`、`*.iml`） |
| `dotnet` | .NET 项目（`bin/`、`obj/`、`*.user`） |
| `go` | Go 模块项目（编译产物、覆盖率、`vendor/` 按需启用） |
| `nodejs` | Node.js / 前端项目（`node_modules/`、构建产物、日志） |
| `python` | Python 项目（`__pycache__/`、虚拟环境、测试与打包缓存） |

各文件内容取自 GitHub 官方 `github/gitignore` 模板并做了精简，保持了与 `configs/dockerignore` 一致的目录结构：
需要哪种语言就复制对应目录的 `.gitignore`，跨语言的项目可把多个文件内容合并到项目根目录的 `.gitignore`。

> 说明：仓库根目录自己的 `.gitignore` 已经存在，不要把这里的文件直接覆盖过去，按需合并即可。
