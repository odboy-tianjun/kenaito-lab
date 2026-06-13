# 单阶段：runtime-python310 已含 Python 3.10.0 + pip 镜像源（见 image/runtime-python310），编译与运行共用
FROM registry.cn-shanghai.aliyuncs.com/odboy/kenaito:runtime-python310
LABEL MAINTAINER="tianjun@odboy.cn"
ENV TimeZone=Asia/Shanghai
ENV PYTHONUNBUFFERED=1
ENV APP_PORT=8083
WORKDIR /home/admin

# 先只拷贝依赖清单，依赖不变时复用 pip 层缓存
COPY requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt

COPY app.py ./
COPY templates ./templates

EXPOSE 8083
# exec 形式，保证 docker stop 的 SIGTERM 能传到 python 进程
ENTRYPOINT ["python3", "app.py"]
