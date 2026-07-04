# ============================================================================
# GitLab 17.5.2 性能优化配置 - 专用于 4C4G 宿主机的 CI/CD 场景
# ============================================================================
#
# 宿主机配置: 4 CPU / 4GB RAM
# 内存预算分配 (目标总占用 ≤ 3.5GB，预留 ~500MB 给 OS):
#   PostgreSQL  ~1GB  (shared_buffers)
#   Puma        ~512MB (1 worker，省内存优先)
#   Redis       ~256MB
#   Sidekiq     ~256MB
#   Gitaly      ~256MB
#   Nginx       ~128MB
#   其他/OS     ~1GB+
#
# 与 4C8G 版本的主要差异:
#   1. Puma 1 worker (4GB 下 2 workers 会 OOM)
#   2. Sidekiq concurrency 5 (压到最低可用值)
#   3. PostgreSQL shared_buffers=1GB, work_mem=8MB
#   4. Redis maxmemory=256MB
#   5. Nginx worker_processes=2 (减少进程数省内存)
#   6. 更激进的日志轮转策略 (节省磁盘 I/O)
# ============================================================================
# 使用前请先执行:
#   sudo gitlab-ctl stop
#   sudo cp /etc/gitlab/gitlab.rb /etc/gitlab/gitlab.rb.bak
#   sudo cp gitlab.optimize-4c4g.rb /etc/gitlab/gitlab.rb
#   sudo gitlab-ctl reconfigure
#   sudo gitlab-ctl start
# ============================================================================

# ----------------------------------------------------------------------------
# 基础配置
# ----------------------------------------------------------------------------
external_url 'http://gitlab.example.com'

gitlab_rails['time_zone'] = 'Asia/Shanghai'

# ----------------------------------------------------------------------------
# 禁用监控相关服务（4GB 内存下必须禁用，节省约 300MB+）
# ----------------------------------------------------------------------------
alertmanager['enable'] = false
prometheus['enable'] = false
node_exporter['enable'] = false
redis_exporter['enable'] = false
postgres_exporter['enable'] = false
gitlab_rails['exporter_enabled'] = false
puma['exporter_enabled'] = false

# ----------------------------------------------------------------------------
# 禁用不需要的集成功能（减少内存占用）
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
# LDAP 认证
gitlab_rails['ldap_enabled'] = false

# OmniAuth 第三方登录
gitlab_rails['omniauth_enabled'] = false

# Gravatar 头像（内网环境禁用以减少外部请求）
gitlab_rails['gravatar_plain_url'] = ''
gitlab_rails['gravatar_ssl_url'] = ''

# 使用统计上报（关闭以节省网络和 CPU）
gitlab_rails['usage_ping_enabled'] = false

# Sentry 错误报告
gitlab_rails['sentry_enabled'] = false
gitlab_pages['sentry_enabled'] = false

# Feature Flags
gitlab_rails['feature_flags_unleash_enabled'] = false

# ----------------------------------------------------------------------------
# PostgreSQL 调优 (针对 4GB RAM)
# ----------------------------------------------------------------------------
# 总内存的 1/4 → 4GB * 1/4 = 1GB
postgresql['shared_buffers'] = "1GB"

# 4GB 内存下 work_mem 必须保守，避免并发时 OOM
postgresql['work_mem'] = "8MB"

# 维护操作内存
postgresql['maintenance_work_mem'] = "128MB"

# 告诉查询规划器可用缓存（含 OS page cache）
postgresql['effective_cache_size'] = "3GB"

# 4GB 下 max_connections 不宜过大
# 1 worker x 4 threads + 5 sidekiq + 10 overhead = 19, 设为 100
postgresql['max_connections'] = 100

# autovacuum
postgresql['autovacuum_max_workers'] = "2"

# checkpoint
postgresql['checkpoint_timeout'] = "5min"
postgresql['checkpoint_completion_target'] = 0.9
postgresql['max_wal_size'] = "512MB"
postgresql['min_wal_size'] = "80MB"

# 并行查询（4 核下保持适度）
postgresql['max_worker_processes'] = 2
postgresql['max_parallel_workers_per_gather'] = 1

# IO
postgresql['effective_io_concurrency'] = 200

# 统计
postgresql['default_statistics_target'] = 1000

# 超时
postgresql['statement_timeout'] = "60000"
postgresql['idle_in_transaction_session_timeout'] = "60000"
postgresql['deadlock_timeout'] = '5s'

# 日志
postgresql['log_lock_waits'] = 1

# ----------------------------------------------------------------------------
# Redis 调优
# ----------------------------------------------------------------------------
redis['maxclients'] = '5000'

# 4GB 下 Redis 内存限制 256MB，allkeys-lru 自动淘汰
redis['maxmemory'] = "256mb"
redis['maxmemory_policy'] = "allkeys-lru"

# 快照持久化
redis['save'] = [ '900 1', '300 10', '60 10000' ]

# 线程 IO（4GB 下不开启 io_threads，节省内存）
# redis['io_threads'] = 2
# redis['io_threads_do_reads'] = true

# TCP 超时
redis['tcp_timeout'] = "300"
redis['tcp_keepalive'] = "60"

# ----------------------------------------------------------------------------
# Nginx 优化（4GB 下适当降低 worker 数）
# ----------------------------------------------------------------------------
nginx['enable'] = true
nginx['client_max_body_size'] = '250m'
nginx['gzip_enabled'] = true
# 4GB 内存下 nginx worker 减为 2，节省 ~100MB
nginx['worker_processes'] = 2
nginx['worker_connections'] = 5120

# CI/CD 场景大文件上传下载超时
nginx['proxy_read_timeout'] = 3600
nginx['proxy_connect_timeout'] = 300

# 传输效率优化
nginx['sendfile'] = 'on'
nginx['tcp_nopush'] = 'on'
nginx['tcp_nodelay'] = 'on'

# keepalive
nginx['keepalive_timeout'] = 65

# ----------------------------------------------------------------------------
# Puma 调优 (Web 服务进程)
# ----------------------------------------------------------------------------
# 4GB 内存: 1 worker x 4 threads = 4 并发
# 绝对不要设 2+ workers（4GB 下必然 OOM）
puma['worker_processes'] = 1
puma['max_threads'] = 4
puma['min_threads'] = 2
puma['worker_timeout'] = 60

# ----------------------------------------------------------------------------
# Sidekiq 调优 (后台任务处理)
# ----------------------------------------------------------------------------
# 4GB 内存下 concurrency=5 是比较安全的值
# 过高会导致 Sidekiq 内存占用激增
sidekiq['concurrency'] = 5

# ----------------------------------------------------------------------------
# GitLab Workhorse (反向代理 / 文件传输)
# ----------------------------------------------------------------------------
gitlab_workhorse['api_limit'] = 0
gitlab_workhorse['api_queue_limit'] = 0
gitlab_workhorse['api_ci_long_polling_duration'] = '300s'

# ----------------------------------------------------------------------------
# Git / Webhook / LFS 相关优化
# ----------------------------------------------------------------------------
gitlab_rails['gitlab_shell_git_timeout'] = 800
gitlab_rails['lfs_enabled'] = true
gitlab_rails['webhook_timeout'] = 300

# ----------------------------------------------------------------------------
# 数据库备份保留策略
# ----------------------------------------------------------------------------
gitlab_rails['backup_keep_time'] = 604800

# ----------------------------------------------------------------------------
# 日志优化（4GB 下更激进的日志策略）
# ----------------------------------------------------------------------------
logging['logrotate_rotate'] = 7
logging['logrotate_frequency'] = "daily"
