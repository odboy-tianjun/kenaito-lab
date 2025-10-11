IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:proxy-tengine3
docker build -t "${IMAGE}" .
docker push "${IMAGE}"
