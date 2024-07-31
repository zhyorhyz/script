#!/bin/bash

# 提示用户输入端口号，并使用默认值 60004
read -p "请输入要使用的端口号（默认为 60004）： " PORT

# 如果用户没有输入端口号，使用默认端口 60004
PORT=${PORT:-60004}

# 验证端口号是否为有效数字
if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
  echo "无效的端口号。请输入一个数字。"
  exit 1
fi

# 创建目录
mkdir -p /root/data/docker_data/Flare

# 进入目录
cd /root/data/docker_data/Flare

# 创建 docker-compose.yml 文件
cat <<EOL > docker-compose.yml
services:
  flare:
    image: soulteary/flare
    restart: always
    command: flare --nologin=0
    environment:
      - FLARE_USER=flare
      - FLARE_PASS=flare
      - FLARE_GUIDE=1
    ports:
      - ${PORT}:5005
    volumes:
      - ./app:/app
EOL

# 启动容器
docker-compose up -d

echo "Flare setup completed on port ${PORT}."
