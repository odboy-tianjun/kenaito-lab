IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:alinux3-update20261111
docker build -t "${IMAGE}" .
docker push "${IMAGE}"
