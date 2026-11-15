#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
docker-compose -f docker-compose.yml -p node-frontend-react-function-demo up -d
docker-compose -f docker-compose.yml -p node-frontend-react-function-demo ps
