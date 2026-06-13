#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
docker-compose -f docker-compose.yml -p python310-flask-demo up -d
