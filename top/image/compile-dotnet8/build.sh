IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-dotnet8
docker build -t "${IMAGE}" .
docker push "${IMAGE}"
