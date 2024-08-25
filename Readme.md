# D-Scanner

实现 分布式扫描器，基于 Celery 实现分布式任务调度，使用 Redis Cluster 作为消息队列，使用 Redis 作为任务状态存储，以及使用 PostgreSQL 作为扫描结果存储。

其中 Broker 负责 数据储存、消息队列、任务管理等，为分布式场景下的任务管理和结果存储单元；Worker 负责实际的扫描工作，为分布式场景下的任务执行单元。

```
+-------------------+
|      Celery       |
|      Broker       |
| (Initiate Tasks)  |
+--------+----------+
         |
         v
+-------------------+
|      Redis        |
|   (Tasks Queue)   |
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

执行 `setup/env-broker.sh` 配置 broker 环境。

此外，需要 targets.txt 中按行添加目标，并修改 worker.py 实现简单的自定义，如以下方式可以自定义扫描的端口和MASSCAN_RATE

```python
TARGETS_PORTS = '22,23,80,888,443,8000,8888,8080'
MASSCAN_RATE = 3
```

### Worker

在 setup/env-worker.sh 文件开始处 添加 redis 和 postgresql 密码

```bash
# 设置 Redis 认证
REDIS_PASSWORD=""
POSTGRES_PASSWORD=""
```

执行 `setup/env-worker.sh` 配置 worker 环境。

### Total Config

在 scanner/config.py 中同样 添加 redis 和 postgresql 密码

```python
REDIS_PASSWORD = ''
POSTGRESQL_USER = ''
POSTGRESQL_DBNAME = ''
POSTGRESQL_PASSWORD = ''

BROKER_IP = ''
```

## Usage

### Broker

在启动 Redis 和 PostgerSQL 的基础上，使用以下命令启动 在项目目录下执行 celery-broker 程序

```bash
sudo systemctl restart redis-server
sudo systemctl restart postgresql
python worker.py
```

### Wroker

```bash
cd D-Scanner
sudo celery -A scanner worker --loglevel=info --queues scan_queue,store_queue
```
