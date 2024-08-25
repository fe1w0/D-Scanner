# D-Scanner

实现 分布式扫描器，基于 Celery 实现分布式任务调度，使用 Redis Cluster 作为消息队列，使用 Redis 作为任务状态存储，以及使用 PostgreSQL 作为扫描结果存储。

```
+-------------------+
|      Clients      |
| (Initiate Tasks)  |
+--------+----------+
         |
         v
+-------------------+
|   Redis Cluster   |
| (Message Queue)   |
+--------+----------+
         |
         v
+-------------------+
|      Celery       |
|      Workers      |
| (Task Processing) |
+--------+----------+
         |
         |-----------------------------+
         |                             |
         v                             v
+-------------------+     +---------------------+
|      Redis        |     | PostgreSQL Database |
| (Task State Store)|     | (Masscan Results)   |
+-------------------+     |   (Data Storage)    |
                          +---------------------+
```

## 设置

### Broker

在 setup/env-broker.sh 文件开始处 添加 redis 和 postgresql 密码
```bash
# 设置 Redis 认证
REDIS_PASSWORD=""
POSTGRES_PASSWORD=""
```
### Worker

在 setup/env-worker.sh 文件开始处 添加 redis 和 postgresql 密码
```bash
# 设置 Redis 认证
REDIS_PASSWORD=""
POSTGRES_PASSWORD=""
```

在 targets.txt 中按行添加目标，且可以修改 worker.py 实现简单的自定义，如以下方式可以自定义扫描的端口和MASSCAN_RATE

```python
TARGETS_PORTS='22,23,80,888,443,8000,8888,8080'
MASSCAN_RATE=3
```

### Total Config

在 scanner/config.py 中同样 添加 redis 和 postgresql 密码

```python
REDIS_PASSWORD = ''
POSTGRESQL_PASSWORD = ''

BROKER_IP = ''
```