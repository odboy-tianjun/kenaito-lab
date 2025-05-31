IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-dotnet6
docker build -t "${IMAGE}" .
docker push "${IMAGE}"
