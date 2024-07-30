#!/bin/bash

# 设置默认端口
DEFAULT_PORT=60003

# 读取用户输入端口
read -p "请输入端口号（默认值 ${DEFAULT_PORT}）: " PORT
PORT=${PORT:-$DEFAULT_PORT}

# 设置变量
DATA_DIR="/root/data/docker_data/uptime_kuma"
COMPOSE_FILE="${DATA_DIR}/docker-compose.yml"

# 创建目录
mkdir -p "$DATA_DIR"

# 创建 docker-compose.yml 文件
cat > "$COMPOSE_FILE" <<EOF
version: '3'
services:
  uptime-kuma:
    image: louislam/uptime-kuma
    container_name: uptime-kuma
    volumes:
      - ./uptime-kuma:/app/data
    ports:
      - ${PORT}:3001
EOF

# 进入目录
cd "$DATA_DIR"

# 启动服务
docker-compose up -d

echo "Uptime Kuma 服务已经在端口 ${PORT} 上启动。"
