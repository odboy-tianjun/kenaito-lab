IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-dotnet8
docker build -t "${IMAGE}" .
docker push "${IMAGE}"
