# 编译阶段：使用编译环境镜像 compile-dotnet8（含 SDK 8.0.403）
FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:compile-dotnet8 AS build
WORKDIR /src
COPY Demo.csproj ./
RUN dotnet restore Demo.csproj
COPY . ./
RUN dotnet publish Demo.csproj -c Release -o /app/publish --no-restore

# 运行阶段：使用运行环境镜像 runtime-dotnet8（仅含 ASP.NET Core 运行时 8.0.10）
FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-dotnet8 AS runtime
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
ENV ASPNETCORE_URLS=http://0.0.0.0:8081
ENV DOTNET_RUNNING_IN_CONTAINER=true
WORKDIR /home/admin
COPY --from=build /app/publish ./
EXPOSE 8081
ENTRYPOINT ["dotnet", "Demo.dll"]
