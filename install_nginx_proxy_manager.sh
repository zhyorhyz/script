#!/bin/bash

set -e  # 确保脚本在遇到错误时停止执行

# 显示帮助信息
function show_help() {
    echo "用法: $0 [选项]"
    echo
    echo "选项:"
    echo "  -h, --help         显示此帮助信息"
}

# 解析命令行选项
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) show_help; exit 0 ;;
        *) echo "未知选项: $1"; show_help; exit 1 ;;
    esac
    shift
done

# 创建 Nginx Proxy Manager 数据目录
echo "创建 Nginx Proxy Manager 数据目录..."
sudo mkdir -p /root/data/docker_data/npm

# 进入数据目录
cd /root/data/docker_data/npm

# 询问用户输入管理界面端口
read -p "请输入 Nginx Proxy Manager 管理界面端口（例如 60000）： " PORT

# 确保用户输入的是有效的端口号
if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
    echo "无效的端口号。请提供一个介于 1 到 65535 之间的端口号。"
    exit 1
fi

# 创建 docker-compose.yml 文件
echo "创建 docker-compose.yml 文件..."
cat > docker-compose.yml <<EOF
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '80:80'  # 保持默认即可，不建议修改左侧的80
      - '${PORT}:81'  # 管理界面端口，用户指定的端口
      - '443:443' # 保持默认即可，不建议修改左侧的443
    volumes:
      - ./data:/data # 映射到本地
      - ./letsencrypt:/etc/letsencrypt  # 映射到本地
EOF

# 启动 Nginx Proxy Manager 服务
echo "启动 Nginx Proxy Manager 服务..."
sudo docker-compose up -d

# 检查 Docker Compose 状态
echo "检查 Docker Compose 状态..."
sudo docker-compose ps

echo "Nginx Proxy Manager 服务已启动。"
