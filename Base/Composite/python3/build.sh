IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-python3
docker build -t "${IMAGE}" .
docker push "${IMAGE}"
