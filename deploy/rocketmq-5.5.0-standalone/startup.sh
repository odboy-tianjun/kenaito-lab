#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# 首次启动时 broker 以 root 运行，提前建好数据目录避免挂载后权限问题
mkdir -p ./master/store
docker-compose -f docker-compose.yml -p rocketmq up -d
