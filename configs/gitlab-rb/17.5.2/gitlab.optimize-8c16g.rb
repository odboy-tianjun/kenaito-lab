# ============================================================================
# GitLab 17.5.2 性能优化配置 - 专用于 8C16G 宿主机的 CI/CD 场景
# ============================================================================
#
# 宿主机配置: 8 CPU / 16GB RAM
# 内存预算分配 (目标总占用 ≤ 13GB，预留 ~3GB 给 OS / 其他进程):
#   PostgreSQL  ~4GB  (shared_buffers)
#   Puma        ~4GB  (4 workers x ~1GB)
#   Redis       ~1GB
#   Sidekiq     ~1GB
#   Gitaly      ~1GB
#   Nginx       ~512MB
#   监控组件    ~512MB  (可选启用)
#   其他/OS     ~3GB+
#
# 与 4C8G 版本的主要差异:
#   1. PostgreSQL shared_buffers=4GB, max_connections=400, 并行查询全开
#   2. Puma 4 workers x 4 threads = 16 并发
#   3. Sidekiq concurrency=20
#   4. Redis maxmemory=1GB
#   5. Nginx worker_processes=8, worker_connections=10240
#   6. 可选启用 Prometheus 监控（已默认禁用，按需开启）
#   7. 更宽松的超时和连接限制
# ============================================================================
# 使用前请先执行:
#   sudo gitlab-ctl stop
#   sudo cp /etc/gitlab/gitlab.rb /etc/gitlab/gitlab.rb.bak
#   sudo cp gitlab.optimize-8c16g.rb /etc/gitlab/gitlab.rb
#   sudo gitlab-ctl reconfigure
#   sudo gitlab-ctl start
# ============================================================================

# ----------------------------------------------------------------------------
# 基础配置
# ----------------------------------------------------------------------------
external_url 'http://gitlab.example.com'

gitlab_rails['time_zone'] = 'Asia/Shanghai'

# ----------------------------------------------------------------------------
# 监控服务（16GB 内存下可选择性启用）
# 默认禁用以节省资源；如需内置监控面板，取消对应注释即可
# ----------------------------------------------------------------------------
alertmanager['enable'] = false
prometheus['enable'] = false
node_exporter['enable'] = false
redis_exporter['enable'] = false
postgres_exporter['enable'] = false
gitlab_rails['exporter_enabled'] = false
puma['exporter_enabled'] = false

# 如需启用 Prometheus 监控（约额外占用 300-500MB），取消下面注释:
# prometheus['enable'] = true
# node_exporter['enable'] = true
# redis_exporter['enable'] = true
# postgres_exporter['enable'] = true
# gitlab_rails['exporter_enabled'] = true
# puma['exporter_enabled'] = true

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
# LDAP 认证
gitlab_rails['ldap_enabled'] = false

# OmniAuth 第三方登录
gitlab_rails['omniauth_enabled'] = false

# Gravatar 头像
gitlab_rails['gravatar_plain_url'] = ''
gitlab_rails['gravatar_ssl_url'] = ''

# 使用统计上报
gitlab_rails['usage_ping_enabled'] = false

# Sentry 错误报告
gitlab_rails['sentry_enabled'] = false
gitlab_pages['sentry_enabled'] = false

# Feature Flags
gitlab_rails['feature_flags_unleash_enabled'] = false

# ----------------------------------------------------------------------------
# PostgreSQL 调优 (针对 16GB RAM)
# ----------------------------------------------------------------------------
# 总内存的 1/4 → 16GB * 1/4 = 4GB
postgresql['shared_buffers'] = "4GB"

# 16GB 下可以给更多 work_mem
postgresql['work_mem'] = "32MB"

# 维护操作内存
postgresql['maintenance_work_mem'] = "512MB"

# 告诉查询规划器可用缓存
postgresql['effective_cache_size'] = "12GB"

# 4 workers x 4 threads + 20 sidekiq + 20 overhead = ~56, 设为 400 留余量
postgresql['max_connections'] = 400

# autovacuum（8 核下多开几个）
postgresql['autovacuum_max_workers'] = "4"

# checkpoint
postgresql['checkpoint_timeout'] = "10min"
postgresql['checkpoint_completion_target'] = 0.9
postgresql['max_wal_size'] = "2GB"
postgresql['min_wal_size'] = "1GB"

# 并行查询（8 核全开）
postgresql['max_worker_processes'] = 8
postgresql['max_parallel_workers_per_gather'] = 4

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
redis['maxclients'] = '20000'

# 16GB 下 Redis 给 1GB 足够 CI/CD 场景
redis['maxmemory'] = "1gb"
redis['maxmemory_policy'] = "allkeys-lru"

# 快照持久化
redis['save'] = [ '900 1', '300 10', '60 10000' ]

# 线程 IO（8 核下开启以提升并发性能）
redis['io_threads'] = 4
redis['io_threads_do_reads'] = true

# TCP 超时
redis['tcp_timeout'] = "300"
redis['tcp_keepalive'] = "60"

# ----------------------------------------------------------------------------
# Nginx 优化（8C16G 充分利用多核）
# ----------------------------------------------------------------------------
nginx['enable'] = true
nginx['client_max_body_size'] = '512m'
nginx['gzip_enabled'] = true
nginx['worker_processes'] = 8
nginx['worker_connections'] = 10240

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
# 16GB 下: 4 workers x 4 threads = 16 并发, 每 worker ~1GB
puma['worker_processes'] = 4
puma['max_threads'] = 4
puma['min_threads'] = 4
puma['worker_timeout'] = 60

# ----------------------------------------------------------------------------
# Sidekiq 调优 (后台任务处理)
# ----------------------------------------------------------------------------
# 16GB 下 concurrency=20 可以充分利用资源
sidekiq['concurrency'] = 20

# ----------------------------------------------------------------------------
# GitLab Workhorse (反向代理 / 文件传输)
# ----------------------------------------------------------------------------
# 16GB 下不限制 API 并发
gitlab_workhorse['api_limit'] = 0
gitlab_workhorse['api_queue_limit'] = 0
gitlab_workhorse['api_ci_long_polling_duration'] = '300s'

# ----------------------------------------------------------------------------
# Git / Webhook / LFS 相关优化
# ----------------------------------------------------------------------------
# 大仓库操作超时
gitlab_rails['gitlab_shell_git_timeout'] = 800

# LFS 大文件存储
gitlab_rails['lfs_enabled'] = true

# Webhook 超时（CI/CD 回调场景）
gitlab_rails['webhook_timeout'] = 300

# ----------------------------------------------------------------------------
# 数据库备份保留策略
# ----------------------------------------------------------------------------
gitlab_rails['backup_keep_time'] = 604800

# ----------------------------------------------------------------------------
# 日志优化
# ----------------------------------------------------------------------------
logging['logrotate_rotate'] = 14
logging['logrotate_frequency'] = "daily"
