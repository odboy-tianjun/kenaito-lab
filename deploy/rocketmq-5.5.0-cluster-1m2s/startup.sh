#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# 首次启动时 broker 以 root 运行，提前建好各 broker 的数据目录避免挂载后权限问题
mkdir -p ./broker-master/store ./broker-slave1/store ./broker-slave2/store
docker-compose -f docker-compose.yml -p rocketmq up -d
