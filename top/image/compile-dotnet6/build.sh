IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-dotnet6
docker build -t "${IMAGE}" .
docker push "${IMAGE}"
