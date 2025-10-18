# SkyWalking Java Agent 9.3.0

SkyWalking 10.0.1 对应的 Java Agent 接入包，无 Docker 编排，直接取本目录的 `apache-skywalking-java-agent-9.3.0.tgz` 注入应用：

```shell
tar -xzf apache-skywalking-java-agent-9.3.0.tgz
java -javaagent:/path/to/skywalking-agent/skywalking-agent.jar \
     -Dskywalking.agent.service_name=<应用名> \
     -Dskywalking.collector.backend_service=<OAP 地址>:11800 \
     -jar app.jar
```

- Agent 包版本与 OAP 版本是两套编号，Agent 9.3.0 对应 OAP 10.0.1
- OAP 部署见 `app/skywalking-10.0.1-es` 或 `app/skywalking-10.0.1-mysql`
