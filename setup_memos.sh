#!/bin/bash

# 创建目录
mkdir -p /root/data/docker_data/memos

# 进入目录
cd /root/data/docker_data/memos

# 提示用户输入外部端口并验证输入
while true; do
  # 提示用户输入端口
  read -p "请输入要映射的外部端口 (例如 5230): " EXTERNAL_PORT

  # 检查输入是否为有效的端口号（1-65535）
  if [[ $EXTERNAL_PORT =~ ^[0-9]+$ ]] && [ $EXTERNAL_PORT -ge 1 ] && [ $EXTERNAL_PORT -le 65535 ]; then
    break
  else
    echo "无效的端口号。请输入一个介于 1 和 65535 之间的数字。"
    # 如果需要，可以选择清除当前行的输入
    # echo -ne "\033[2K\r"
  fi
done

# 创建 docker-compose.yml 文件
cat <<EOF > docker-compose.yml
version: '3.8'

services:
  memos:
    image: neosmemo/memos:stable
    container_name: memos
    volumes:
      - ~/.memos/:/var/opt/memos
    ports:
      - ${EXTERNAL_PORT}:5230
EOF

# 启动 Docker 容器
docker-compose up -d
