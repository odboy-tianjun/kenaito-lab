IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-alinux3
docker build -t "${IMAGE}" .
docker push "${IMAGE}"
