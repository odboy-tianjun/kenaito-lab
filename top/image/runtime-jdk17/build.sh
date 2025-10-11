curl -O https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz
tar -xzvf openjdk-17.0.2_linux-x64_bin.tar.gz
rm -f openjdk-17.0.2_linux-x64_bin.tar.gz
rm -f jdk-17.0.2/lib/src.zip
tar -czvf jdk-17.0.2.tar.gz jdk-17.0.2
rm -rf jdk-17.0.2
IMAGE=registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-jdk17
docker build -t "${IMAGE}" .
docker push "${IMAGE}"
