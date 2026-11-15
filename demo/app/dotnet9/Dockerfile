# 编译阶段：使用编译环境镜像 compile-dotnet9（含 SDK 9.0.100-rc.2.24474.11）
FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-dotnet9 AS build
WORKDIR /src
COPY Demo.csproj ./
RUN dotnet restore Demo.csproj
COPY . ./
RUN dotnet publish Demo.csproj -c Release -o /app/publish --no-restore

# 运行阶段：使用运行环境镜像 runtime-dotnet9（仅含 ASP.NET Core 运行时 9.0.0-rc.2.24474.3）
FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-dotnet9 AS runtime
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
ENV ASPNETCORE_URLS=http://0.0.0.0:8082
ENV DOTNET_RUNNING_IN_CONTAINER=true
WORKDIR /home/admin
COPY --from=build /app/publish ./
EXPOSE 8082
ENTRYPOINT ["dotnet", "Demo.dll"]
