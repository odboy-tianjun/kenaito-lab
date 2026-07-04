# ============================================================================
# GitLab 17.5.2 性能优化配置 - 专用于 4C8G 宿主机的 CI/CD 场景
# ============================================================================
#
# 宿主机配置: 4 CPU / 8GB RAM
# 内存预算分配 (目标总占用 ≤ 7GB):
#   PostgreSQL  ~2GB  (shared_buffers)
#   Redis       ~512MB
#   Puma        ~2GB  (2 workers x ~1GB)
#   Sidekiq     ~512MB
#   Gitaly      ~512MB
#   Nginx       ~256MB
#   其他/OS     ~1GB+
#
# 与默认配置相比的主要优化:
#   1. 禁用全部监控导出器 (节省 ~300MB 内存 + CPU)
#   2. 禁用 KAS / Pages / Registry / Mattermost / Geo / Spamcheck 等非必要服务
#   3. PostgreSQL 调优 (shared_buffers=2GB, work_mem=16MB, maintenance_work_mem=256MB)
#   4. Puma 2 workers (4C8G 下比 4 workers 更稳定，避免 OOM)
#   5. Sidekiq concurrency 10 (平衡 CI/CD 吞吐与内存)
#   6. Nginx worker_processes=4, worker_connections=10240
#   7. Redis maxmemory=512MB
#   8. Workhorse / Webhook 超时优化适配 CI/CD 大文件场景
# ============================================================================

# ----------------------------------------------------------------------------
# 基础配置
# ----------------------------------------------------------------------------
external_url 'http://gitlab.example.com'

gitlab_rails['time_zone'] = 'Asia/Shanghai'

# ----------------------------------------------------------------------------
# 禁用监控相关服务（节省约 300MB 内存 + CPU 开销）
# 如需使用外部 Prometheus，可保持禁用
# ----------------------------------------------------------------------------
alertmanager['enable'] = false
prometheus['enable'] = false
node_exporter['enable'] = false
redis_exporter['enable'] = false
postgres_exporter['enable'] = false
gitlab_rails['exporter_enabled'] = false
puma['exporter_enabled'] = false

# ----------------------------------------------------------------------------
# 禁用不需要的集成功能
# ----------------------------------------------------------------------------
# Kubernetes Agent Server
gitlab_kas['enable'] = false

# Pages 静态网站托管
gitlab_pages['enable'] = false

# Container Registry 容器镜像仓库
registry['enable'] = false
gitlab_rails['registry_enabled'] = false

# Mattermost 团队协作
mattermost['enable'] = false

# Geo 地理分布式
geo_postgresql['enable'] = false
geo_logcursor['enable'] = false

# Spamcheck 垃圾邮件检查
spamcheck['enable'] = false

# Service Desk 服务台
gitlab_rails['service_desk_email_enabled'] = false

# ----------------------------------------------------------------------------
# 禁用外部服务和遥测
# ----------------------------------------------------------------------------
# LDAP 认证（如不需要）
gitlab_rails['ldap_enabled'] = false

# OmniAuth 第三方登录（如只需本地账号）
gitlab_rails['omniauth_enabled'] = false

# Gravatar 头像（内网环境禁用以减少外部请求）
gitlab_rails['gravatar_plain_url'] = ''
gitlab_rails['gravatar_ssl_url'] = ''

# 使用统计上报
gitlab_rails['usage_ping_enabled'] = false

# Sentry 错误报告
gitlab_rails['sentry_enabled'] = false
gitlab_pages['sentry_enabled'] = false

# Feature Flags（GitLab 内部用，小规模部署可关闭）
gitlab_rails['feature_flags_unleash_enabled'] = false

# ----------------------------------------------------------------------------
# PostgreSQL 调优 (针对 8GB RAM)
# ----------------------------------------------------------------------------
# 建议值: 总内存的 1/4, 上限 14GB → 8GB * 1/4 = 2GB
postgresql['shared_buffers'] = "2GB"

# work_mem: 每个排序/哈希操作的内存，不宜过大（并发时会累乘）
postgresql['work_mem'] = "16MB"

# maintenance_work_mem: VACUUM / CREATE INDEX 等维护操作内存
postgresql['maintenance_work_mem'] = "256MB"

# effective_cache_size: 告诉查询规划器系统可用的缓存总量
postgresql['effective_cache_size'] = "6GB"

# max_connections: Puma workers + Sidekiq + 其他连接
# 2 workers x 4 threads + 10 sidekiq + 10 overhead = 28, 设为 200 留余量
postgresql['max_connections'] = 200

# autovacuum 并发
postgresql['autovacuum_max_workers'] = "3"

# checkpoint 调优
postgresql['checkpoint_timeout'] = "5min"
postgresql['checkpoint_completion_target'] = 0.9
postgresql['max_wal_size'] = "1GB"
postgresql['min_wal_size'] = "80MB"

# 并行查询（4 核下适度开启）
postgresql['max_worker_processes'] = 4
postgresql['max_parallel_workers_per_gather'] = 2

# IO 调优
postgresql['effective_io_concurrency'] = 200

# 统计采样
postgresql['default_statistics_target'] = 1000

# 超时与死锁
postgresql['statement_timeout'] = "60000"
postgresql['idle_in_transaction_session_timeout'] = "60000"
postgresql['deadlock_timeout'] = '5s'

# 日志
postgresql['log_lock_waits'] = 1

# ----------------------------------------------------------------------------
# Redis 调优
# ----------------------------------------------------------------------------
redis['maxclients'] = '10000'

# Redis 内存限制：512MB，8G 内存下给 Redis 适度空间
# CI/CD 场景用 allkeys-lru 可在内存满时自动淘汰最久未用的 key
redis['maxmemory'] = "512mb"
redis['maxmemory_policy'] = "allkeys-lru"

# 快照持久化频率（默认值即可，CI/CD 场景不需要太频繁）
redis['save'] = [ '900 1', '300 10', '60 10000' ]

# 线程 IO（Redis 6.0+，4 核下适度开启）
redis['io_threads'] = 2
redis['io_threads_do_reads'] = true

# TCP 超时
redis['tcp_timeout'] = "300"
redis['tcp_keepalive'] = "60"

# ----------------------------------------------------------------------------
# Nginx 优化（适配 4C8G + CI/CD 大文件传输）
# ----------------------------------------------------------------------------
nginx['enable'] = true
nginx['client_max_body_size'] = '250m'
nginx['gzip_enabled'] = true
nginx['worker_processes'] = 4
nginx['worker_connections'] = 10240

# CI/CD 场景大文件上传下载超时
nginx['proxy_read_timeout'] = 3600
nginx['proxy_connect_timeout'] = 300

# 开启 sendfile / tcp_nopush / tcp_nodelay 提升传输效率
nginx['sendfile'] = 'on'
nginx['tcp_nopush'] = 'on'
nginx['tcp_nodelay'] = 'on'

# keepalive 优化
nginx['keepalive_timeout'] = 65

# ----------------------------------------------------------------------------
# Puma 调优 (Web 服务进程)
# ----------------------------------------------------------------------------
# 4C8G 下: 2 workers x 4 threads = 8 并发, 每 worker ~1GB
# 不要设 4 workers（4x4=16 并发, 内存可能超 4GB 导致 OOM）
puma['worker_processes'] = 2
puma['max_threads'] = 4
puma['min_threads'] = 2
puma['worker_timeout'] = 60

# ----------------------------------------------------------------------------
# Sidekiq 调优 (后台任务处理)
# ----------------------------------------------------------------------------
# 4C8G 下 concurrency=10 是比较平衡的值
# CI/CD 场景有大量异步任务 (pipeline / artifact 清理等)
sidekiq['concurrency'] = 10

# ----------------------------------------------------------------------------
# GitLab Workhorse (反向代理 / 文件传输)
# ----------------------------------------------------------------------------
# CI/CD 场景不限制 API 并发
gitlab_workhorse['api_limit'] = 0
gitlab_workhorse['api_queue_limit'] = 0

# CI Runner 长轮询时间（默认 60s，适当延长减少请求频率）
gitlab_workhorse['api_ci_long_polling_duration'] = '300s'

# ----------------------------------------------------------------------------
# Git / Webhook / LFS 相关优化
# ----------------------------------------------------------------------------
# Git 操作超时（大仓库 clone / push）
gitlab_rails['gitlab_shell_git_timeout'] = 800

# LFS 大文件存储
gitlab_rails['lfs_enabled'] = true

# Webhook 超时（CI/CD 回调场景适当增大）
gitlab_rails['webhook_timeout'] = 300

# ----------------------------------------------------------------------------
# 数据库备份保留策略（默认 7 天）
# ----------------------------------------------------------------------------
gitlab_rails['backup_keep_time'] = 604800

# ----------------------------------------------------------------------------
# 日志优化（减少磁盘 I/O）
# ----------------------------------------------------------------------------
logging['logrotate_rotate'] = 14
logging['logrotate_frequency'] = "daily"

# Git log 级别（生产环境 warn 即可，减少日志量）
# gitaly 默认 level=warn，无需额外配置
