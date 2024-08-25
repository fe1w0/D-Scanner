#!/bin/bash

set -e

# 更新软件包列表和系统
sudo apt update
sudo apt upgrade -y

# 安装 Python 和 pip
sudo apt install -y python3 python3-pip

# 安装 Redis
sudo apt install -y redis-tools

# 安装 nmap 和 masscan
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

# 更新PATH变量
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 提示用户配置完成
echo "环境配置完成。"
echo -e "Run broker:\nsudo celery -A scanner worker --loglevel=info --queues scan_queue,store_queue"