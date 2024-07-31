#!/bin/bash

# 提示用户输入端口号，并使用默认值 60005
read -p "请输入要使用的端口号（默认为 60005）： " PORT

# 如果用户没有输入端口号，使用默认端口 60005
PORT=${PORT:-60005}

# 验证端口号是否为有效数字
if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
  echo "无效的端口号。请输入一个数字。"
  exit 1
fi

# 创建目录
mkdir -p /root/data/docker_data/cryptgeon

# 进入目录
cd /root/data/docker_data/cryptgeon

# 创建 docker-compose.yml 文件
cat <<EOL > docker-compose.yml
services:
  redis:
    image: redis:7-alpine

  app:
    image: cupcakearmy/cryptgeon:latest
    depends_on:
      - redis
    environment:
      SIZE_LIMIT: 25m
    ports:
      - ${PORT}:8000
EOL

# 启动容器
docker-compose up -d

echo "CryptGeon setup completed on port ${PORT}."
