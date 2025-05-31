IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-dotnet9
docker build -t "${IMAGE}" .
docker push "${IMAGE}"
