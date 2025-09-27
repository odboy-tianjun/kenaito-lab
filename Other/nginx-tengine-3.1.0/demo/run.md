# Tengine 3.1.0

基于 alinux3 源码编译的 Tengine 3.1.0 反向代理 / Web 服务器，镜像由同目录 `build.sh` 构建（
`registry.cn-shanghai.aliyuncs.com/odboy/kenaito:proxy-tengine3`）

- https://tengine.taobao.org
- 以 root 启动，worker 进程自动降权；日志输出到 stdout/stderr，交给 docker 日志驱动收集
- 编译参数见 `Dockerfile`，默认配置文件见 `nginx.conf`（`user root`、`worker_processes auto`、`access_log /dev/stdout`、
  `include conf.d/*.conf`）

### 目录映射

| 宿主机              | 容器                             | 说明                         |
|------------------|--------------------------------|----------------------------|
| `./nginx/conf.d` | `/usr/local/nginx/conf/conf.d` | 站点配置，`*.conf` 被主配置 include |
| `./nginx/ssl`    | `/usr/local/nginx/conf/ssl`    | https 证书（`*.pem`、`*.key`）  |
| `./nginx/html`   | `/usr/local/nginx/html`        | 静态资源                       |
| `./nginx/logs`   | `/usr/local/nginx/logs`        | 备用日志目录（实际访问日志已输出到 stdout）  |

`nginx.conf` 本身没有挂载：如需修改主配置，建议 `docker cp` 出来改好后 `docker commit`/重新构建，避免单文件挂载导致宿主机编辑后容器内不生效

### 部署方式

```shell
docker build -t registry.cn-shanghai.aliyuncs.com/odboy/kenaito:proxy-tengine3 .
sh install.sh
```

等同：`docker-compose -f docker-compose.yml -p tengine up -d`

访问 http://192.168.235.104 （http 80）、https://192.168.235.104 （https 443），
如 `demo.odboy.cn` 已解析到该机器，可用 `-H "Host: demo.odboy.cn"` 或直接访问域名

### 常用命令

```shell
# 查看日志（访问/错误日志均走 stdout/stderr）
docker logs -f tengine

# 修改 conf.d 下的站点配置后，先校验再平滑重载（不中断连接）
docker exec tengine nginx -t
docker exec tengine nginx -s reload

# 查看编译模块
docker exec tengine nginx -V
```

### 请求本容器之前挂了 Nacos / 其它服务？

`demo.odboy.cn.conf` 中已经给出了反向代理写法注释，同一网段内可直接用 IP 或服务名：

```nginx
location /api/ {
    proxy_pass  http://172.25.0.21:8848/;
    proxy_set_header  Host  $host;
    proxy_set_header  X-Real-IP  $remote_addr;
    proxy_set_header  X-Forwarded-For  $proxy_add_x_forwarded_for;
}
```

若需要容器名互通，把其它服务的 `container_name` 加入同一网络 `tengine`，或直接用上面固定的 `ipv4_address`

### 停止

```shell
sh shutdown.sh    # docker-compose -f docker-compose.yml -p tengine down
```
