IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:tools-ansible
docker build -t "${IMAGE}" .
docker push "${IMAGE}"
