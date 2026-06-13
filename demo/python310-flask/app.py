import os
import platform
import socket
from datetime import datetime, timedelta, timezone

import flask

app = flask.Flask(__name__)
# 国内时区 UTC+8，容器内 TZ 即使没生效也能输出正确时间
TZ8 = timezone(timedelta(hours=8))
START_TIME = datetime.now(TZ8)


def runtime_info():
    return {
        "message": "python310-flask is running",
        "python": platform.python_version(),
        "flask": flask.__version__,
        "impl": platform.python_implementation(),
        "os": platform.platform(),
        "hostname": socket.gethostname(),
        "time": datetime.now(TZ8).strftime("%Y-%m-%d %H:%M:%S %z"),
        "uptime": str(datetime.now(TZ8) - START_TIME).split(".")[0],
    }


@app.get("/")
def index():
    return flask.jsonify(runtime_info())


@app.get("/health")
def health():
    return "ok"


@app.get("/api/hello/<name>")
def hello(name):
    return flask.jsonify({"message": f"Hello, {name}!", "time": datetime.now(TZ8).isoformat()})


@app.get("/page")
def page():
    return flask.render_template("index.html", info=runtime_info())


if __name__ == "__main__":
    # 容器内监听 8083，避免与 dotnet6/8/9 示例的 8080/8081/8082 冲突；可用环境变量 APP_PORT 覆盖
    port = int(os.environ.get("APP_PORT", "8083"))
    app.run(host="0.0.0.0", port=port)
