IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:system-alinux3
docker build -t "${IMAGE}" .
docker push "${IMAGE}"
