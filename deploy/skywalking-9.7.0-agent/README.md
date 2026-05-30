# SkyWalking Java Agent 9.1.0

SkyWalking 9.7.0 对应的 Java Agent 接入包，本目录不放二进制（`*.tgz` 已改为 OSS 下载，不再入 Git）：

```shell
# 下载 Agent 包
curl -fLO https://oss.odboy.cn/kenaito-lab/skywalking/apache-skywalking-java-agent-9.1.0.tgz

tar -xzf apache-skywalking-java-agent-9.1.0.tgz
java -javaagent:/path/to/skywalking-agent/skywalking-agent.jar \
     -Dskywalking.agent.service_name=<应用名> \
     -Dskywalking.collector.backend_service=<OAP 地址>:11800 \
     -jar app.jar
```

- Agent 包版本与 OAP 版本是两套编号，Agent 9.1.0 对应 OAP 9.7.0
- OAP 部署见 `deploy/skywalking-9.7.0-es` 或 `deploy/skywalking-9.7.0-mysql`
