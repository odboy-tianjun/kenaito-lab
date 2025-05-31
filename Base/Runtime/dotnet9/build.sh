IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-dotnet9
docker build -t "${IMAGE}" .
docker push "${IMAGE}"
