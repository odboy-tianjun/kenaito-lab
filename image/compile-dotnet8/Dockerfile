FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:system-alinux3
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
ENV DOTNET_HOME=/usr/local/dotnet
ENV PATH="${DOTNET_HOME}:$PATH"
WORKDIR /home/admin
# https://dotnet.microsoft.com/en-us/download/dotnet/thank-you/sdk-8.0.403-linux-x64-binaries
# 由 build.sh 预先下载到本目录
ADD dotnet-sdk-8.0.403-linux-x64.tar.gz /usr/local/dotnet/
# gcc/make 用于编译含原生代码的 NuGet 包；sysstat/net-tools 用于排障
# libicu：.NET 全球化（CultureInfo/TimeZoneInfo）必需，缺了 dotnet 命令会直接 Abort
RUN yum install \
    gcc \
    make \
    libicu \
    sysstat \
    net-tools -y; \
    dotnet --info;
