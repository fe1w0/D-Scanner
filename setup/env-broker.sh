#!/bin/bash

set -e

# 设置 Redis 认证
REDIS_PASSWORD=""
POSTGRES_PASSWORD=""

# 更新软件包列表和系统
sudo apt update
sudo apt upgrade -y

# 安装 Python 和 pip
sudo apt install -y python3 python3-pip

# 安装 Redis
sudo apt install -y redis-server

# 安装 nmap
sudo apt install -y nmap

# 安装 masscan
sudo apt --assume-yes install git make gcc
sudo mkdir -p /root/Downloads
sudo git clone https://github.com/robertdavidgraham/masscan /root/Downloads/masscan
sudo sh -c 'cd /root/Downloads/masscan && make && sudo make install'

# 安装 PostgreSQL
sudo apt install -y postgresql-16 postgresql-contrib

# 安装 Celery
sudo pip3 install celery redis python-masscan psycopg2-binary --break-system-packages

# 配置 Redis 允许外网访问
sudo sed -i "s/^bind 127.0.0.1 -::1/# bind 127.0.0.1 -::1/" /etc/redis/redis.conf
sudo sed -i "s/^protected-mode yes/protected-mode no/" /etc/redis/redis.conf
echo "bind 0.0.0.0" |sudo tee -a /etc/redis/redis.conf

echo "requirepass $REDIS_PASSWORD" | sudo tee -a /etc/redis/redis.conf

# 重启 Redis 服务以应用配置
sudo systemctl restart redis-server
echo "Finished setting up Redis."

# 配置 PostgreSQL 允许外网访问
sudo sed -i "s/^#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/16/main/postgresql.conf
echo "local   all             scanner                                 scram-sha-256" | sudo tee -a /etc/postgresql/16/main/pg_hba.conf
echo "host    all             all             0.0.0.0/0               scram-sha-256"| sudo tee -a /etc/postgresql/16/main/pg_hba.conf

sudo -u postgres psql -c "CREATE USER scanner WITH PASSWORD '$POSTGRES_PASSWORD';"
sudo -u postgres psql -c "ALTER USER scanner WITH SUPERUSER;"

# 创建 scan_results 数据库并赋予 scanner 用户权限
sudo -u postgres psql -c "CREATE DATABASE scan_results OWNER scanner;"
sudo -u postgres psql -d scan_results -c "GRANT ALL PRIVILEGES ON DATABASE scan_results TO scanner;"
sudo -u postgres psql -d scan_results -c "CREATE TABLE port_results (id SERIAL PRIMARY KEY, ip VARCHAR(255) NOT NULL UNIQUE, result JSONB NOT NULL);"

# 重启 PostgreSQL 服务以应用配置
sudo systemctl restart postgresql

# 更新PATH变量
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

echo "export REDIS_PASSWORD=$REDIS_PASSWORD" >> ~/.bashrc
echo "export POSTGRES_PASSWORD=$POSTGRES_PASSWORD" >> ~/.bashrc

source ~/.bashrc


# 提示用户配置完成
echo "环境配置完成。"
echo "Redis 密码: $REDIS_PASSWORD"
echo "PostgreSQL 密码: $POSTGRES_PASSWORD"
echo -e "Run broker:\nsudo celery -A scanner worker --loglevel=info --queues scan_queue,store_queue"