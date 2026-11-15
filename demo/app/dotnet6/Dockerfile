# 编译阶段：使用编译环境镜像 compile-dotnet6（含 SDK 6.0.427）
FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-dotnet6 AS build
WORKDIR /src
COPY Demo.csproj ./
RUN dotnet restore Demo.csproj
COPY . ./
RUN dotnet publish Demo.csproj -c Release -o /app/publish --no-restore

# 运行阶段：使用运行环境镜像 runtime-dotnet6（仅含 ASP.NET Core 运行时 6.0.35）
FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-dotnet6 AS runtime
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
ENV ASPNETCORE_URLS=http://0.0.0.0:8080
ENV DOTNET_RUNNING_IN_CONTAINER=true
WORKDIR /home/admin
COPY --from=build /app/publish ./
EXPOSE 8080
ENTRYPOINT ["dotnet", "Demo.dll"]
