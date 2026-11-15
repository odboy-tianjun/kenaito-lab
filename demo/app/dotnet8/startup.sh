#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
docker-compose -f docker-compose.yml -p dotnet8-demo up -d
